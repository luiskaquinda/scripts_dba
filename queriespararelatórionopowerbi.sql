-- Monitoramento Operacional

--		Backups
--		Jobs
--		AlwaysOn
--		Capacity
--		Availability

-- 1. DBA_AVAILABILITY_Audit

CREATE TABLE dbo.DBA_AVAILABILITY_Audit (
    ServerName NVARCHAR(128),
    ServiceName NVARCHAR(128),
    DataDaVerificacao DATETIME,

    AlwaysOnStatus NVARCHAR(20),

    BaseDados NVARCHAR(128),
    EstadoBase NVARCHAR(60),
    RecoveryModel NVARCHAR(60),
    Acesso NVARCHAR(60),
    CriadaEm DATETIME,

    TamanhoMB BIGINT,
    EspacoLivreMB BIGINT,

    UltimoBackup DATETIME,
    TipoBackup NVARCHAR(20),

    AvailabilityGroup NVARCHAR(128),
    PapelReplica NVARCHAR(60),
    EstadoSincronizacao NVARCHAR(60),
    SaudeHA NVARCHAR(60),
    ReplicaSuspensa NVARCHAR(10)
);

INSERT INTO dbo.DBA_Availability_Stats

DECLARE @IsHadrEnabled BIT = CAST(SERVERPROPERTY('IsHadrEnabled') AS BIT);

;WITH UltimoBackup AS
(
    SELECT 
        bs.database_name,
        MAX(bs.backup_finish_date) AS UltimoBackup,
        CASE MAX(bs.type)
            WHEN 'D' THEN 'Full'
            WHEN 'I' THEN 'Diferencial'
            WHEN 'L' THEN 'Log'
        END AS TipoBackup
    FROM msdb.dbo.backupset bs
    GROUP BY bs.database_name
),
Tamanho AS
(
    SELECT  
        database_id,
        SUM(CAST(size AS BIGINT)) * 8 / 1024 AS TamanhoMB,
        SUM(
            (CAST(size AS BIGINT) * 8 / 1024) - 
            (CAST(FILEPROPERTY(name,'SpaceUsed') AS BIGINT) * 8 / 1024)
        ) AS EspacoLivreMB
    FROM sys.master_files
    GROUP BY database_id
)
SELECT
    @@SERVERNAME AS ServerName,
    @@SERVICENAME AS ServiceName,
    GETDATE() AS DataDaVerificacao,

    -- Flag global
    CASE 
        WHEN @IsHadrEnabled = 1 THEN 'Enabled'
        ELSE 'Disabled'
    END AS AlwaysOnStatus,

    -- Base de dados
    d.name AS BaseDados,
    d.state_desc AS EstadoBase,
    d.recovery_model_desc AS RecoveryModel,
    d.user_access_desc AS Acesso,
    d.create_date AS CriadaEm,

    -- Espaço
    t.TamanhoMB,
    t.EspacoLivreMB,

    -- Backup
    ub.UltimoBackup,
    ub.TipoBackup,

    -- Availability Group (somente se Always On ativo)
    CASE 
        WHEN @IsHadrEnabled = 1 THEN ag.name
        ELSE 'Not Applicable'
    END AS AvailabilityGroup,

    CASE 
        WHEN @IsHadrEnabled = 1 THEN ar.role_desc
        ELSE 'Standalone'
    END AS PapelReplica,

    CASE 
        WHEN @IsHadrEnabled = 1 THEN drs.synchronization_state_desc
        ELSE 'Not Applicable'
    END AS EstadoSincronizacao,

    CASE 
        WHEN @IsHadrEnabled = 1 THEN drs.synchronization_health_desc
        ELSE 'Not Applicable'
    END AS SaudeHA,

    CASE 
        WHEN @IsHadrEnabled = 1 THEN CAST(drs.is_suspended AS varchar)
        ELSE '0'
    END AS ReplicaSuspensa

FROM sys.databases d

LEFT JOIN Tamanho t 
    ON d.database_id = t.database_id

LEFT JOIN UltimoBackup ub 
    ON d.name = ub.database_name

-- Availability Group (só retorna dados se Always On estiver enabled)
LEFT JOIN sys.availability_databases_cluster adc
    ON @IsHadrEnabled = 1
   AND d.name = adc.database_name

LEFT JOIN sys.availability_groups ag
    ON @IsHadrEnabled = 1
   AND adc.group_id = ag.group_id

LEFT JOIN sys.dm_hadr_database_replica_states drs
    ON @IsHadrEnabled = 1
   AND d.database_id = drs.database_id

LEFT JOIN sys.dm_hadr_availability_replica_states ar
    ON @IsHadrEnabled = 1
   AND drs.replica_id = ar.replica_id
   AND ar.is_local = 1

ORDER BY
    d.name;

-- 2. DBA_CAPACITY_Audit

CREATE TABLE dbo.DBA_CAPACITY_Audit (
    HostName NVARCHAR(128),
    InstanceName NVARCHAR(128),

    DatabaseName NVARCHAR(128),
    DatabaseState NVARCHAR(60),

    LogicalFileName NVARCHAR(128),
    FileType NVARCHAR(30),
    UsageType NVARCHAR(30),

    PhysicalPath NVARCHAR(500),
    Volume NVARCHAR(100),

    TotalGB DECIMAL(12,2),
    UsedGB DECIMAL(12,2),
    FreeGB DECIMAL(12,2),
    FreePct DECIMAL(5,2),

    CapacityStatus NVARCHAR(20),
    DataConsulta DATETIME
);


INSERT INTO dbo.DBA_Capacity_Stats

;WITH FileInfo AS
(
    SELECT
        SERVERPROPERTY('MachineName') AS HostName,
        @@SERVERNAME AS InstanceName,

        d.database_id,
        d.name AS DatabaseName,
        d.state_desc AS DatabaseState,

        mf.file_id,
        mf.name AS LogicalFileName,
        mf.type_desc,

        CASE
            WHEN d.name = 'tempdb' THEN 'TEMPDB'
            WHEN mf.type_desc = 'LOG' THEN 'LOG'
            ELSE 'DATA'
        END AS UsageType,

        CASE
            WHEN mf.type_desc = 'ROWS' AND mf.file_id = 1 THEN 'DATA_MDF'
            WHEN mf.type_desc = 'ROWS' AND mf.file_id > 1 THEN 'DATA_NDF'
            WHEN mf.type_desc = 'LOG' THEN 'LOG_LDF'
        END AS FileType,

        mf.physical_name AS PhysicalPath,

        vs.volume_mount_point AS Volume
    FROM sys.master_files mf
    JOIN sys.databases d
        ON d.database_id = mf.database_id
    CROSS APPLY sys.dm_os_volume_stats(mf.database_id, mf.file_id) vs
),
VolumeInfo AS
(
    SELECT DISTINCT
        SERVERPROPERTY('MachineName') AS HostName,
        @@SERVERNAME AS InstanceName,

        vs.volume_mount_point AS Volume,

        CAST(vs.total_bytes / 1024.0 / 1024 / 1024 AS DECIMAL(12,2)) AS TotalGB,
        CAST((vs.total_bytes - vs.available_bytes) / 1024.0 / 1024 / 1024 AS DECIMAL(12,2)) AS UsedGB,
        CAST(vs.available_bytes / 1024.0 / 1024 / 1024 AS DECIMAL(12,2)) AS FreeGB,
        CAST(vs.available_bytes * 100.0 / vs.total_bytes AS DECIMAL(5,2)) AS FreePct
    FROM sys.master_files mf
    CROSS APPLY sys.dm_os_volume_stats(mf.database_id, mf.file_id) vs
),
BackupVolumes AS
(
    SELECT DISTINCT
        SERVERPROPERTY('MachineName') AS HostName,
        @@SERVERNAME AS InstanceName,

        CASE
            WHEN bmf.physical_device_name LIKE '\\%' THEN
                LEFT(bmf.physical_device_name,
                    CHARINDEX('\', bmf.physical_device_name, 3) - 1)
            ELSE LEFT(bmf.physical_device_name, 3)
        END AS Volume,

        'BACKUP' AS UsageType
    FROM msdb.dbo.backupmediafamily bmf
),

AllUsage AS
(
    SELECT DISTINCT
        HostName,
        InstanceName,
        Volume,
        UsageType
    FROM FileInfo

    UNION

    SELECT
        HostName,
        InstanceName,
        Volume,
        UsageType
    FROM BackupVolumes
)
SELECT
    fi.HostName,
    fi.InstanceName,

    fi.DatabaseName,
    fi.DatabaseState,

    fi.LogicalFileName,
    fi.FileType,
    fi.UsageType,

    fi.PhysicalPath,
    fi.Volume,

    vi.TotalGB,
    vi.UsedGB,
    vi.FreeGB,
    vi.FreePct,

    CASE
        WHEN vi.FreePct < 10 THEN 'CRITICAL'
        WHEN vi.FreePct BETWEEN 10 AND 20 THEN 'WARNING'
        ELSE 'OK'
    END AS CapacityStatus, 
    GETDATE() AS DataConsulta
FROM FileInfo fi
JOIN VolumeInfo vi
    ON fi.HostName = vi.HostName
   AND fi.InstanceName = vi.InstanceName
   AND fi.Volume = vi.Volume
LEFT JOIN AllUsage au
    ON fi.HostName = au.HostName
   AND fi.InstanceName = au.InstanceName
   AND fi.Volume = au.Volume
   AND fi.UsageType = au.UsageType
ORDER BY
    vi.FreePct ASC,
    fi.DatabaseName,
    fi.FileType;
	
-- 3. DBA_BACKUP_Audit
CREATE TABLE dbo.DBA_BACKUP_Audit (
    Date DATETIME,
    HostName NVARCHAR(128),
    InstanceName NVARCHAR(128),

    DatabaseName NVARCHAR(128),
    BackupTypeCode CHAR(1),
    BackupType NVARCHAR(20),

    BackupStartDate DATETIME,
    BackupFinishDate DATETIME,

    BackupFilePath NVARCHAR(500),
    DriveLetter NVARCHAR(10),
    BackupSizeMB BIGINT,

    BackupStatus NVARCHAR(20),
    LastFullBackupDate DATETIME,
    BackupHealthStatus NVARCHAR(50),

    JobName NVARCHAR(128),
    JobRunDateTime DATETIME,
    JobRunStatus NVARCHAR(20)
);

INSERT INTO dbo.DBA_Backup_Stats

WITH LastFullBackup AS (
    SELECT
        database_name,
        MAX(backup_finish_date) AS LastFullBackupDate
    FROM msdb.dbo.backupset
    WHERE type = 'D'
    GROUP BY database_name
),
JobHistory AS (
    SELECT
        j.job_id,
        j.name AS JobName,
        h.run_date,
        h.run_time,
        h.run_status,
        msdb.dbo.agent_datetime(h.run_date, h.run_time) AS JobRunDateTime,
        CASE h.run_status
            WHEN 0 THEN 'FAILED'
            WHEN 1 THEN 'SUCCEEDED'
            WHEN 2 THEN 'RETRY'
            WHEN 3 THEN 'CANCELED'
            WHEN 4 THEN 'IN PROGRESS'
        END AS JobRunStatus
    FROM msdb.dbo.sysjobhistory h
    JOIN msdb.dbo.sysjobs j
        ON h.job_id = j.job_id
    WHERE h.step_id = 0 -- Resultado final do Job
)

SELECT
    -- Identificação
    GETDATE() AS Date,
    SERVERPROPERTY('MachineName') AS HostName,
    @@SERVERNAME AS InstanceName,

    -- Backup (Original)
    bs.database_name        AS DatabaseName,
    bs.type                 AS BackupTypeCode,
    CASE bs.type
        WHEN 'D' THEN 'FULL'
        WHEN 'I' THEN 'DIFFERENTIAL'
        WHEN 'L' THEN 'LOG'
    END                     AS BackupType,

    bs.backup_start_date    AS BackupStartDate,
    bs.backup_finish_date   AS BackupFinishDate,

    bmf.physical_device_name AS BackupFilePath,
    LEFT(bmf.physical_device_name, 3) AS DriveLetter,
    bs.backup_size / 1024 / 1024 AS BackupSizeMB,

    -- NOVO: Status do Backup
    CASE
        WHEN bs.backup_finish_date IS NOT NULL THEN 'SUCCEEDED'
        ELSE 'FAILED'
    END AS BackupStatus,

    -- NOVO: Último FULL Backup
    lf.LastFullBackupDate,

    -- NOVO: Alerta de Perigo (> 1 dia sem FULL)
    CASE
        WHEN lf.LastFullBackupDate IS NULL THEN 'CRITICAL - NO FULL BACKUP'
        WHEN DATEDIFF(DAY, lf.LastFullBackupDate, GETDATE()) > 1 THEN 'DANGER'
        ELSE 'OK'
    END AS BackupHealthStatus,

    -- NOVO: Job associado (por proximidade temporal)
    jh.JobName,
    jh.JobRunDateTime,
    jh.JobRunStatus

FROM msdb.dbo.backupset bs
JOIN msdb.dbo.backupmediafamily bmf
    ON bs.media_set_id = bmf.media_set_id

LEFT JOIN LastFullBackup lf
    ON bs.database_name = lf.database_name

LEFT JOIN JobHistory jh
    ON jh.JobRunDateTime BETWEEN
       DATEADD(MINUTE, -10, bs.backup_start_date)
       AND
       DATEADD(MINUTE, 10, bs.backup_finish_date)

WHERE (bs.backup_finish_date >= (GETDATE() - 5)) -- Só traz registos de backups de cinco dias pra aqui 

ORDER BY
    DatabaseName,
    bs.backup_finish_date DESC;

-- 4. DBA_JOBS_Audit

CREATE TABLE dbo.DBA_JOBS_Audit (
    Servidor NVARCHAR(128),
    DataConsulta DATETIME,

    NomeJob NVARCHAR(128),
    CategoriaJob NVARCHAR(128),
    ProprietarioJob NVARCHAR(128),

    StatusJob NVARCHAR(30),
    DataHoraExecucao DATETIME,

    DuracaoExecucao NVARCHAR(20),
    DuracaoEmSegundos INT,

    MensagemExecucao NVARCHAR(MAX),
    SqlMessageID INT,
    SqlSeverity INT,

    UltimoStepID INT,
    UltimoStepNome NVARCHAR(128)
);

INSERT INTO dbo.DBA_Jobs_Stats

SELECT
    @@SERVERNAME AS Servidor,
    GETDATE() AS DataConsulta,

    -- Identificação do Job
    j.name AS NomeJob,
    c.name AS CategoriaJob,
    SUSER_SNAME(j.owner_sid) AS ProprietarioJob,

    -- Status interpretado
    CASE h.run_status
        WHEN 0 THEN 'Failed'
        WHEN 1 THEN 'Succeeded'
        WHEN 2 THEN 'Retry'
        WHEN 3 THEN 'Canceled'
        WHEN 4 THEN 'In Progress'
        ELSE 'Unknown'
    END AS StatusJob,

    -- Data e hora convertidas corretamente
    CONVERT(datetime,
        STUFF(STUFF(CAST(h.run_date AS char(8)),7,0,'-'),5,0,'-') + ' ' +
        STUFF(STUFF(RIGHT('000000' + CAST(h.run_time AS varchar(6)),6),5,0,':'),3,0,':')
    ) AS DataHoraExecucao,

    -- Duração convertida
    FORMAT(
        DATEADD(SECOND,
            (h.run_duration / 10000) * 3600 +
            ((h.run_duration % 10000) / 100) * 60 +
            (h.run_duration % 100),
            '19000101'
        ),
        'HH:mm:ss'
    ) AS DuracaoExecucao,

    -- Duração em segundos (útil para análise)
    (
        (h.run_duration / 10000) * 3600 +
        ((h.run_duration % 10000) / 100) * 60 +
        (h.run_duration % 100)
    ) AS DuracaoEmSegundos,

    -- Diagnóstico
    h.message AS MensagemExecucao,
    h.sql_message_id AS SqlMessageID,
    h.sql_severity AS SqlSeverity,

    -- Informação da última etapa executada
    h.step_id AS UltimoStepID,
    h.step_name AS UltimoStepNome

FROM msdb.dbo.sysjobs j
JOIN msdb.dbo.sysjobhistory h
    ON j.job_id = h.job_id
LEFT JOIN msdb.dbo.syscategories c
    ON j.category_id = c.category_id

WHERE
    h.step_id = 0  -- somente resultado final do job
    AND (
        j.name LIKE '%Backup%'
        OR j.name LIKE '%backup%'
        OR j.name LIKE '%Plan%'
OR j.name LIKE '%BACKUP%'
OR j.name LIKE '%backup%'
OR j.name LIKE '%plan%'
    )
ORDER BY DataHoraExecucao DESC;

-- 5. DBA_AlwaysOn_Audit

CREATE TABLE dbo.DBA_ALWAYSON_AVAILABILITYGROUP_Audit (
    DataConsulta DATETIME,
    ServerName NVARCHAR(128),
    InstanceName NVARCHAR(128),

    Edition NVARCHAR(128),
    ProductVersion NVARCHAR(50),

    AlwaysOnStatus NVARCHAR(30),
    AvailabilityGroup NVARCHAR(128),

    ReplicaServer NVARCHAR(128),
    ReplicaRole NVARCHAR(50),
    ConnectionState NVARCHAR(50),
    ReplicaHealth NVARCHAR(50),

    IsLocalReplica NVARCHAR(5),

    DatabaseName NVARCHAR(128),
    DatabaseSyncState NVARCHAR(50),
    DatabaseHealth NVARCHAR(50),
    IsSuspended BIT
);

INSERT INTO dbo.DBA_AlwaysOn_Stats

WITH ServerInfo AS (
    SELECT  
        SERVERPROPERTY('MachineName')        AS ServerName,
        SERVERPROPERTY('ServerName')         AS InstanceName,
        SERVERPROPERTY('Edition')            AS Edition,
        SERVERPROPERTY('ProductVersion')     AS ProductVersion,
        CAST(SERVERPROPERTY('IsHadrEnabled') AS INT) AS IsAlwaysOnEnabled
),
AGInfo AS (
    SELECT  
        ag.group_id,
        ag.name AS AvailabilityGroup
    FROM sys.availability_groups ag
),
ReplicaInfo AS (
    SELECT  
        ar.group_id,
        ar.replica_server_name,
        rs.role_desc                    AS ReplicaRole,
        rs.connected_state_desc         AS ConnectionState,
        rs.synchronization_health_desc  AS ReplicaHealth,
        rs.is_local
    FROM sys.availability_replicas ar
    LEFT JOIN sys.dm_hadr_availability_replica_states rs
        ON ar.replica_id = rs.replica_id
),
DatabaseInfo AS (
    SELECT  
        drs.group_id,
        DB_NAME(drs.database_id)            AS DatabaseName,
        drs.synchronization_state_desc      AS DatabaseSyncState,
        drs.synchronization_health_desc     AS DatabaseHealth,
        drs.is_suspended                    AS IsSuspended
    FROM sys.dm_hadr_database_replica_states drs
)

SELECT 
    GETDATE() AS DataConsulta,
    si.ServerName,
    si.InstanceName,
    si.Edition,
    si.ProductVersion,

    CASE si.IsAlwaysOnEnabled
        WHEN 1 THEN 'ENABLED'
        WHEN 0 THEN 'DISABLED'
        ELSE 'NOT SUPPORTED'
    END AS AlwaysOnStatus,

    ag.AvailabilityGroup,

    r.replica_server_name AS ReplicaServer,
    r.ReplicaRole,
    r.ConnectionState,
    r.ReplicaHealth,

    CASE WHEN r.is_local = 1 THEN 'YES' ELSE 'NO' END AS IsLocalReplica,

    d.DatabaseName,
    d.DatabaseSyncState,
    d.DatabaseHealth,
    d.IsSuspended

FROM ServerInfo si
LEFT JOIN AGInfo ag
    ON 1 = 1
LEFT JOIN ReplicaInfo r
    ON ag.group_id = r.group_id
LEFT JOIN DatabaseInfo d
    ON ag.group_id = d.group_id

ORDER BY  
    ag.AvailabilityGroup,
    r.is_local DESC,
    r.ReplicaRole DESC,
    d.DatabaseName;


-- Performance

	--	CPU
	--	IO
	--	Memory
	--	Connections

-- 1. CPU por Database

CREATE TABLE dbo.CPU_Stats (
    SnapshotTime DATETIME NOT NULL,
    ServerName NVARCHAR(128),
    DatabaseName NVARCHAR(128),

    CPU_Time_ms BIGINT,
    ExecutionCount BIGINT,
    CPUPercent DECIMAL(5,2)
);

INSERT INTO dbo.CPU_Stats
SELECT
    GETDATE(),
    @@SERVERNAME,
    DB_NAME(CONVERT(int, pa.value)),

    SUM(qs.total_worker_time) / 1000,
    SUM(qs.execution_count),
    SUM(qs.total_worker_time) * 1.0 /
        SUM(SUM(qs.total_worker_time)) OVER() * 100
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_plan_attributes(qs.plan_handle) pa
WHERE pa.attribute = 'dbid'
GROUP BY CONVERT(int, pa.value)
HAVING CONVERT(int, pa.value) > 4;

-- 2. IO por Database

CREATE TABLE dbo.IO_Stats (
    SnapshotTime DATETIME NOT NULL,
    ServerName NVARCHAR(128),
    DatabaseName NVARCHAR(128),

    TotalReads BIGINT,
    TotalWrites BIGINT,
    ReadMB BIGINT,
    WriteMB BIGINT,
    TotalIOMB BIGINT,
    IOPercent DECIMAL(5,2)
);

INSERT INTO dbo.IO_Stats
SELECT
    GETDATE(),
    @@SERVERNAME,
    DB_NAME(mf.database_id),

    SUM(vfs.num_of_reads),
    SUM(vfs.num_of_writes),
    SUM(vfs.num_of_bytes_read) / 1024 / 1024,
    SUM(vfs.num_of_bytes_written) / 1024 / 1024,
    SUM(vfs.num_of_bytes_read + vfs.num_of_bytes_written) / 1024 / 1024,
    SUM(vfs.num_of_bytes_read + vfs.num_of_bytes_written) * 1.0 /
        SUM(SUM(vfs.num_of_bytes_read + vfs.num_of_bytes_written)) OVER() * 100
FROM sys.dm_io_virtual_file_stats(NULL, NULL) vfs
JOIN sys.master_files mf
    ON vfs.database_id = mf.database_id
    AND vfs.file_id = mf.file_id
GROUP BY mf.database_id;

-- 3. Memória (Buffer Cache)

CREATE TABLE dbo.Memory_Stats (
    SnapshotTime DATETIME NOT NULL,
    ServerName NVARCHAR(128),
    DatabaseName NVARCHAR(128),

    BufferPages BIGINT,
    BufferSizeMB DECIMAL(10,2),
    DirtyPages BIGINT
);

INSERT INTO dbo.Memory_Stats
SELECT
    GETDATE(),
    @@SERVERNAME,
    DB_NAME(database_id),

    COUNT(*),
    COUNT(*) * 8.0 / 1024,
    SUM(CASE WHEN is_modified = 1 THEN 1 ELSE 0 END)
FROM sys.dm_os_buffer_descriptors
GROUP BY database_id;

-- 4. Conexões

CREATE TABLE dbo.Connection_Stats (
    SnapshotTime DATETIME NOT NULL,
    ServerName NVARCHAR(128),
    DatabaseName NVARCHAR(128),

    NumberOfConnections INT
);


INSERT INTO dbo.Connection_Stats
SELECT
    GETDATE(),
    @@SERVERNAME,
    DB_NAME(database_id),

    COUNT(*)
FROM sys.dm_exec_sessions
WHERE is_user_process = 1
GROUP BY database_id;

CREATE INDEX IX_CPU ON dbo.CPU_Stats (SnapshotTime, DatabaseName);
CREATE INDEX IX_IO ON dbo.IO_Stats (SnapshotTime, DatabaseName);
CREATE INDEX IX_MEM ON dbo.Memory_Stats (SnapshotTime, DatabaseName);
CREATE INDEX IX_CONN ON dbo.Connection_Stats (SnapshotTime, DatabaseName);





-- IO Stall por ficheiro

CREATE TABLE dbo.DBA_IO_Stall_Stats (
    [datetime] DATETIME,
    [Database Name] NVARCHAR(128),
    physical_name NVARCHAR(500),

    io_stall_read_ms BIGINT,
    num_of_reads BIGINT,
    avg_read_stall_ms NUMERIC(10,1),

    io_stall_write_ms BIGINT,
    num_of_writes BIGINT,
    avg_write_stall_ms NUMERIC(10,1),

    io_stalls BIGINT,
    total_io BIGINT,
    avg_io_stall_ms NUMERIC(10,1)
);

INSERT INTO dbo.DBA_IO_Stall_Stats
SELECT
    GETDATE() AS 'datetime',
    DB_NAME(fs.database_id) AS [Database Name],
    mf.physical_name,
    io_stall_read_ms,
    num_of_reads,
    CAST(io_stall_read_ms / ( 1.0 + num_of_reads ) AS NUMERIC(10, 1)) AS [avg_read_stall_ms],
    io_stall_write_ms,
    num_of_writes,
    CAST(io_stall_write_ms / ( 1.0 + num_of_writes ) AS NUMERIC(10, 1)) AS [avg_write_stall_ms],
    io_stall_read_ms + io_stall_write_ms AS [io_stalls],
    num_of_reads + num_of_writes AS [total_io],
    CAST(( io_stall_read_ms + io_stall_write_ms ) / ( 1.0 + num_of_reads + num_of_writes ) AS NUMERIC(10, 1)) AS [avg_io_stall_ms]
FROM
    sys.dm_io_virtual_file_stats(NULL, NULL) AS fs
    INNER JOIN sys.master_files AS mf WITH ( NOLOCK ) ON fs.database_id = mf.database_id AND fs.[file_id] = mf.[file_id]
ORDER BY
    avg_io_stall_ms DESC;

USE [Traces];
GO

IF OBJECT_ID('dbo.DBA_CAPACITY_Audit', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.DBA_CAPACITY_Audit
    (
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
END;
GO

WITH FileInfo AS
(
    SELECT
        CAST(SERVERPROPERTY('MachineName') AS NVARCHAR(128)) AS HostName,
        CAST(@@SERVERNAME AS NVARCHAR(128)) AS InstanceName,

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
            WHEN mf.type_desc = 'ROWS'
                 AND mf.file_id = 1
            THEN 'DATA_MDF'

            WHEN mf.type_desc = 'ROWS'
                 AND mf.file_id > 1
            THEN 'DATA_NDF'

            WHEN mf.type_desc = 'LOG'
            THEN 'LOG_LDF'
        END AS FileType,

        mf.physical_name AS PhysicalPath,

        CAST(vs.volume_mount_point AS NVARCHAR(100)) AS Volume

    FROM sys.master_files mf

    INNER JOIN sys.databases d
        ON d.database_id = mf.database_id

    CROSS APPLY sys.dm_os_volume_stats
    (
        mf.database_id,
        mf.file_id
    ) vs
),

VolumeInfo AS
(
    SELECT DISTINCT

        CAST(SERVERPROPERTY('MachineName') AS NVARCHAR(128)) AS HostName,
        CAST(@@SERVERNAME AS NVARCHAR(128)) AS InstanceName,

        CAST(vs.volume_mount_point AS NVARCHAR(100)) AS Volume,

        CAST(
            vs.total_bytes / 1024.0 / 1024 / 1024
            AS DECIMAL(12,2)
        ) AS TotalGB,

        CAST(
            (vs.total_bytes - vs.available_bytes)
            / 1024.0 / 1024 / 1024
            AS DECIMAL(12,2)
        ) AS UsedGB,

        CAST(
            vs.available_bytes
            / 1024.0 / 1024 / 1024
            AS DECIMAL(12,2)
        ) AS FreeGB,

        CAST(
            (vs.available_bytes * 100.0)
            / NULLIF(vs.total_bytes,0)
            AS DECIMAL(5,2)
        ) AS FreePct

    FROM sys.master_files mf

    CROSS APPLY sys.dm_os_volume_stats
    (
        mf.database_id,
        mf.file_id
    ) vs
),

BackupVolumes AS
(
    SELECT DISTINCT

        CAST(SERVERPROPERTY('MachineName') AS NVARCHAR(128)) AS HostName,
        CAST(@@SERVERNAME AS NVARCHAR(128)) AS InstanceName,

        CAST(
            CASE
                WHEN bmf.physical_device_name LIKE '\\%'
                THEN LEFT
                (
                    bmf.physical_device_name,
                    CHARINDEX('\', bmf.physical_device_name, 3) - 1
                )

                ELSE LEFT(bmf.physical_device_name, 3)
            END
            AS NVARCHAR(100)
        ) AS Volume,

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

    SELECT DISTINCT
        HostName,
        InstanceName,
        Volume,
        UsageType
    FROM BackupVolumes
)

INSERT INTO dbo.DBA_CAPACITY_Audit
(
    HostName,
    InstanceName,

    DatabaseName,
    DatabaseState,

    LogicalFileName,
    FileType,
    UsageType,

    PhysicalPath,
    Volume,

    TotalGB,
    UsedGB,
    FreeGB,
    FreePct,

    CapacityStatus,
    DataConsulta
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

INNER JOIN VolumeInfo vi
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

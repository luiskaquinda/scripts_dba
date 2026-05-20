USE [Traces];
GO

IF OBJECT_ID('dbo.DBA_BACKUP_Audit', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.DBA_BACKUP_Audit
    (
        [Date] DATETIME,

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
END;
GO

WITH LastFullBackup AS
(
    SELECT
        database_name,
        MAX(backup_finish_date) AS LastFullBackupDate
    FROM msdb.dbo.backupset
    WHERE type = 'D'
    GROUP BY database_name
),

JobHistory AS
(
    SELECT
        j.job_id,
        j.name AS JobName,

        h.run_date,
        h.run_time,
        h.run_status,

        msdb.dbo.agent_datetime
        (
            h.run_date,
            h.run_time
        ) AS JobRunDateTime,

        CASE h.run_status
            WHEN 0 THEN 'FAILED'
            WHEN 1 THEN 'SUCCEEDED'
            WHEN 2 THEN 'RETRY'
            WHEN 3 THEN 'CANCELED'
            WHEN 4 THEN 'IN PROGRESS'
            ELSE 'UNKNOWN'
        END AS JobRunStatus

    FROM msdb.dbo.sysjobhistory h

    INNER JOIN msdb.dbo.sysjobs j
        ON h.job_id = j.job_id

    WHERE h.step_id = 0
)

INSERT INTO dbo.DBA_BACKUP_Audit
(
    [Date],

    HostName,
    InstanceName,

    DatabaseName,
    BackupTypeCode,
    BackupType,

    BackupStartDate,
    BackupFinishDate,

    BackupFilePath,
    DriveLetter,
    BackupSizeMB,

    BackupStatus,
    LastFullBackupDate,
    BackupHealthStatus,

    JobName,
    JobRunDateTime,
    JobRunStatus
)

SELECT
    GETDATE() AS [Date],

    CAST
    (
        SERVERPROPERTY('MachineName')
        AS NVARCHAR(128)
    ) AS HostName,

    CAST(@@SERVERNAME AS NVARCHAR(128)) AS InstanceName,

    bs.database_name AS DatabaseName,

    bs.type AS BackupTypeCode,

    CASE bs.type
        WHEN 'D' THEN 'FULL'
        WHEN 'I' THEN 'DIFFERENTIAL'
        WHEN 'L' THEN 'LOG'
        ELSE 'UNKNOWN'
    END AS BackupType,

    bs.backup_start_date AS BackupStartDate,
    bs.backup_finish_date AS BackupFinishDate,

    CAST
    (
        bmf.physical_device_name
        AS NVARCHAR(500)
    ) AS BackupFilePath,

    CAST
    (
        LEFT(bmf.physical_device_name, 3)
        AS NVARCHAR(10)
    ) AS DriveLetter,

    CAST
    (
        bs.backup_size / 1024 / 1024
        AS BIGINT
    ) AS BackupSizeMB,

    CASE
        WHEN bs.backup_finish_date IS NOT NULL
        THEN 'SUCCEEDED'
        ELSE 'FAILED'
    END AS BackupStatus,

    lf.LastFullBackupDate,

    CASE
        WHEN lf.LastFullBackupDate IS NULL
        THEN 'CRITICAL - NO FULL BACKUP'

        WHEN DATEDIFF
        (
            DAY,
            lf.LastFullBackupDate,
            GETDATE()
        ) > 1
        THEN 'DANGER'

        ELSE 'OK'
    END AS BackupHealthStatus,

    jh.JobName,
    jh.JobRunDateTime,
    jh.JobRunStatus

FROM msdb.dbo.backupset bs

INNER JOIN msdb.dbo.backupmediafamily bmf
    ON bs.media_set_id = bmf.media_set_id

LEFT JOIN LastFullBackup lf
    ON bs.database_name = lf.database_name

LEFT JOIN JobHistory jh
    ON jh.JobRunDateTime BETWEEN
       DATEADD(MINUTE, -10, bs.backup_start_date)
       AND
       DATEADD(MINUTE, 10, bs.backup_finish_date)

WHERE bs.backup_finish_date >= DATEADD(DAY, -5, GETDATE())

ORDER BY
    bs.database_name,
    bs.backup_finish_date DESC;

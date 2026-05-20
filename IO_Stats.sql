use [Traces];
GO

IF OBJECT_ID('dbo.IO_Stats', 'U') IS NULL
BEGIN
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
END;
GO

USE master;
GO

INSERT INTO [Traces].dbo.IO_Stats
SELECT
    GETDATE(),
    CAST(@@SERVERNAME AS NVARCHAR(128)),
    DB_NAME(mf.database_id),

    SUM(vfs.num_of_reads),
    SUM(vfs.num_of_writes),

    SUM(vfs.num_of_bytes_read) / 1024 / 1024,
    SUM(vfs.num_of_bytes_written) / 1024 / 1024,

    SUM(vfs.num_of_bytes_read + vfs.num_of_bytes_written) / 1024 / 1024,

    SUM(vfs.num_of_bytes_read + vfs.num_of_bytes_written) * 100.0 /
    NULLIF(SUM(SUM(vfs.num_of_bytes_read + vfs.num_of_bytes_written)) OVER(), 0)

FROM sys.dm_io_virtual_file_stats(NULL, NULL) vfs
JOIN sys.master_files mf
    ON vfs.database_id = mf.database_id
   AND vfs.file_id = mf.file_id
GROUP BY mf.database_id;

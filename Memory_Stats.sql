Use Traces;
GO

IF OBJECT_ID('dbo.Memory_Stats', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Memory_Stats (
        SnapshotTime DATETIME NOT NULL,
        ServerName NVARCHAR(128),
        DatabaseName NVARCHAR(128),

        BufferPages BIGINT,
        BufferSizeMB DECIMAL(10,2),
        DirtyPages BIGINT
    );
END;
GO

Use master;
GO

INSERT INTO Traces.dbo.Memory_Stats
SELECT
    GETDATE(),
    CAST(@@SERVERNAME AS NVARCHAR(128)),
    DB_NAME(database_id),

    COUNT(*),
    COUNT(*) * 8.0 / 1024,
    SUM(CASE WHEN is_modified = 1 THEN 1 ELSE 0 END)

FROM sys.dm_os_buffer_descriptors
WHERE database_id <> 32767
GROUP BY database_id;
use Traces;
GO

IF OBJECT_ID('dbo.DBA_IO_Stall_Stats', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.DBA_IO_Stall_Stats (
        SnapshotTime DATETIME,
        DatabaseName NVARCHAR(128),
        PhysicalName NVARCHAR(500),

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
END;
GO

Use master;
GO

INSERT INTO Traces.dbo.DBA_IO_Stall_Stats
SELECT
    GETDATE(),
    DB_NAME(fs.database_id),
    mf.physical_name,

    fs.io_stall_read_ms,
    fs.num_of_reads,
    fs.io_stall_read_ms / NULLIF(fs.num_of_reads, 0.0),

    fs.io_stall_write_ms,
    fs.num_of_writes,
    fs.io_stall_write_ms / NULLIF(fs.num_of_writes, 0.0),

    fs.io_stall_read_ms + fs.io_stall_write_ms,
    fs.num_of_reads + fs.num_of_writes,

    (fs.io_stall_read_ms + fs.io_stall_write_ms)
    / NULLIF((fs.num_of_reads + fs.num_of_writes), 0.0)

FROM sys.dm_io_virtual_file_stats(NULL, NULL) fs
JOIN sys.master_files mf
    ON fs.database_id = mf.database_id
   AND fs.file_id = mf.file_id;


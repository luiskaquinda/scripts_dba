use Traces;
GO

IF OBJECT_ID('dbo.CPU_Stats', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.CPU_Stats (
        SnapshotTime DATETIME NOT NULL,
        ServerName NVARCHAR(128),
        DatabaseName NVARCHAR(128),

        CPU_Time_ms BIGINT,
        ExecutionCount BIGINT,
        CPUPercent DECIMAL(5,2)
    );
END;
GO

use master;
GO

INSERT INTO Traces.dbo.CPU_Stats
SELECT
    GETDATE(),
    CAST(@@SERVERNAME AS NVARCHAR(128)),

    DB_NAME(CAST(pa.value AS INT)),

    SUM(qs.total_worker_time) / 1000,
    SUM(qs.execution_count),

    SUM(qs.total_worker_time) * 100.0 /
    NULLIF(SUM(SUM(qs.total_worker_time)) OVER(), 0)

FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_plan_attributes(qs.plan_handle) pa
WHERE pa.attribute = 'dbid'
  AND pa.value IS NOT NULL
GROUP BY pa.value
HAVING pa.value > 4;


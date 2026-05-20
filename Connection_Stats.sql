Use Traces;
GO

IF OBJECT_ID('dbo.Connection_Stats', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Connection_Stats (
        SnapshotTime DATETIME NOT NULL,
        ServerName NVARCHAR(128),
        DatabaseName NVARCHAR(128),

        NumberOfConnections INT
    );
END;
GO

Use master;
GO

INSERT INTO Traces.dbo.Connection_Stats
SELECT
    GETDATE(),
    CAST(@@SERVERNAME AS NVARCHAR(128)),
    DB_NAME(database_id),

    COUNT(*)

FROM sys.dm_exec_sessions
WHERE is_user_process = 1
  AND database_id IS NOT NULL
GROUP BY database_id;

SELECT * FROM Traces.dbo.Connection_Stats;


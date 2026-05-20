USE Traces;
GO

IF OBJECT_ID('dbo.DBA_ALWAYSON_AVAILABILITYGROUP_Audit', 'U') IS NULL
BEGIN
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
END;
GO

USE msdb;
GO

;WITH ServerInfo AS
(
    SELECT
        CAST(SERVERPROPERTY('MachineName') AS NVARCHAR(128)) AS ServerName,
        CAST(SERVERPROPERTY('ServerName') AS NVARCHAR(128)) AS InstanceName,
        CAST(SERVERPROPERTY('Edition') AS NVARCHAR(128)) AS Edition,
        CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(50)) AS ProductVersion,
        CAST(SERVERPROPERTY('IsHadrEnabled') AS INT) AS IsAlwaysOnEnabled
),

AGInfo AS
(
    SELECT
        ag.group_id,
        ag.name AS AvailabilityGroup
    FROM sys.availability_groups ag
),

ReplicaInfo AS
(
    SELECT
        ar.group_id,
        ar.replica_server_name,
        rs.role_desc AS ReplicaRole,
        rs.connected_state_desc AS ConnectionState,
        rs.synchronization_health_desc AS ReplicaHealth,
        rs.is_local
    FROM sys.availability_replicas ar
    LEFT JOIN sys.dm_hadr_availability_replica_states rs
        ON ar.replica_id = rs.replica_id
),

DatabaseInfo AS
(
    SELECT
        drs.group_id,
        DB_NAME(drs.database_id) AS DatabaseName,
        drs.synchronization_state_desc AS DatabaseSyncState,
        drs.synchronization_health_desc AS DatabaseHealth,
        drs.is_suspended AS IsSuspended
    FROM sys.dm_hadr_database_replica_states drs
)

INSERT INTO Traces.dbo.DBA_ALWAYSON_AVAILABILITYGROUP_Audit
(
    DataConsulta,
    ServerName,
    InstanceName,

    Edition,
    ProductVersion,

    AlwaysOnStatus,
    AvailabilityGroup,

    ReplicaServer,
    ReplicaRole,
    ConnectionState,
    ReplicaHealth,

    IsLocalReplica,

    DatabaseName,
    DatabaseSyncState,
    DatabaseHealth,
    IsSuspended
)

SELECT
    GETDATE() AS DataConsulta,

    si.ServerName,
    si.InstanceName,
    si.Edition,
    si.ProductVersion,

    CASE
        WHEN si.IsAlwaysOnEnabled = 1 THEN 'ENABLED'
        ELSE 'DISABLED'
    END AS AlwaysOnStatus,

    ag.AvailabilityGroup,

    r.replica_server_name AS ReplicaServer,
    r.ReplicaRole,
    r.ConnectionState,
    r.ReplicaHealth,

    CASE
        WHEN r.is_local = 1 THEN 'YES'
        ELSE 'NO'
    END AS IsLocalReplica,

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
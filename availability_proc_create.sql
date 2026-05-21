USE Traces;
GO

CREATE OR ALTER PROCEDURE dbo.DBA_Load_INSTANCE_DBs_AVAILABILITY
AS
BEGIN
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

	INSERT INTO Traces.dbo.DBA_AVAILABILITY_Audit
	(
		ServerName,
		ServiceName,
		DataDaVerificacao,
		AlwaysOnStatus,
		BaseDados,
		EstadoBase,
		RecoveryModel,
		Acesso,
		CriadaEm,
		TamanhoMB,
		EspacoLivreMB,
		UltimoBackup,
		TipoBackup,
		AvailabilityGroup,
		PapelReplica,
		EstadoSincronizacao,
		SaudeHA,
		ReplicaSuspensa
	)

	SELECT
		@@SERVERNAME,
		@@SERVICENAME,
		GETDATE(),

		CASE 
			WHEN @IsHadrEnabled = 1 THEN 'Enabled'
			ELSE 'Disabled'
		END,

		d.name,
		d.state_desc,
		d.recovery_model_desc,
		d.user_access_desc,
		d.create_date,

		t.TamanhoMB,
		t.EspacoLivreMB,

		ub.UltimoBackup,
		ub.TipoBackup,

		CASE 
			WHEN @IsHadrEnabled = 1 THEN ag.name
			ELSE 'Not Applicable'
		END,

		CASE 
			WHEN @IsHadrEnabled = 1 THEN ar.role_desc
			ELSE 'Standalone'
		END,

		CASE 
			WHEN @IsHadrEnabled = 1 THEN drs.synchronization_state_desc
			ELSE 'Not Applicable'
		END,

		CASE 
			WHEN @IsHadrEnabled = 1 THEN drs.synchronization_health_desc
			ELSE 'Not Applicable'
		END,

		CASE 
			WHEN @IsHadrEnabled = 1 THEN CAST(drs.is_suspended AS varchar)
			ELSE '0'
		END

	FROM sys.databases d

	LEFT JOIN Tamanho t 
		ON d.database_id = t.database_id

	LEFT JOIN UltimoBackup ub 
		ON d.name = ub.database_name

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

	ORDER BY d.name;
END;
GO
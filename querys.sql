WITH DiskInfo AS (
    SELECT DISTINCT
        VS.volume_mount_point AS [Montagem],
        VS.logical_volume_name AS [Volume],
        CAST(CAST(VS.total_bytes AS DECIMAL(19, 2)) / 1024 / 1024 / 1024 AS DECIMAL(10, 2)) AS [Total (GB)],
        CAST(CAST(VS.available_bytes AS DECIMAL(19, 2)) / 1024 / 1024 / 1024 AS DECIMAL(10, 2)) AS [Espaço Disponível (GB)],
        CAST((CAST(VS.available_bytes AS DECIMAL(19, 2)) / CAST(VS.total_bytes AS DECIMAL(19, 2)) * 100) AS DECIMAL(10, 2)) AS [Espaço Disponível (%)],
        CAST((100 - (CAST(VS.available_bytes AS DECIMAL(19, 2)) / CAST(VS.total_bytes AS DECIMAL(19, 2)) * 100)) AS DECIMAL(10, 2)) AS [Espaço em uso (%)],
        mf.database_id,
        mf.file_id
    FROM
        sys.master_files AS mf
    CROSS APPLY 
        sys.dm_os_volume_stats(mf.database_id, mf.file_id) AS vs
    WHERE 
        CAST(VS.available_bytes AS DECIMAL(19, 2)) / CAST(VS.total_bytes AS DECIMAL(19, 2)) * 100 < 100
)
SELECT 
    DB_NAME(mf.database_id) AS [Database Name],
    mf.name AS [Logical File Name],
    case when mf.type = 0 then 'DADOS'
    when  mf.type = 1 then 'LOG'
    end as tipodado,
    mf.physical_name AS [MDF File Path],
    CAST(SUM(mf.size) * 8 / 1024 / 1024 AS DECIMAL(18, 2)) AS [Database Size (GB)],
    di.Montagem AS [MONTAGEM],
    di.Volume AS [VOLUME LOGICO],
    di.[Total (GB)] AS [ESPAÇO TOTAL],
    di.[Espaço Disponível (GB)],
    di.[Espaço Disponível (%)],
    di.[Espaço em uso (%)]
FROM 
    sys.master_files AS mf
INNER JOIN 
    DiskInfo AS di ON mf.database_id = di.database_id AND mf.file_id = di.file_id
--WHERE 
-- --   mf.type = 0  -- Filtra apenas o MDF (tipo 0 é o arquivo de dados)
--    --and mf.physical_name not like '%.ndf%'
GROUP BY 
    DB_NAME(mf.database_id), mf.name, mf.physical_name, di.Montagem, di.Volume, di.[Total (GB)], di.[Espaço Disponível (GB)], di.[Espaço Disponível (%)], di.[Espaço em uso (%)], mf.type
ORDER BY 
    [Database Size (GB)] DESC;



-- esse script retorna os ultimos backups gerados nos 10 ultimos dias

Use msdb 
GO
SET NOCOUNT ON
GO
 
DECLARE @Dias Int
 
Set @Dias = 10
 
SELECT
     S.Database_Name
    ,M.Physical_Device_Name
    ,Convert(Decimal(12,2), S.Backup_Size / 1024 / 1024) As Size
    ,S.Backup_Start_Date
    ,S.Backup_Finish_Date
    ,Cast(DateDiff(Second, S.Backup_Start_Date , S.Backup_Finish_Date) As Varchar(4)) As Seconds_Duration
    ,Case S.Type
        When 'D' Then 'Full'
        When 'I' Then 'Differential'
        When 'L' Then 'Transaction Log'
    End As BackupType
    ,S.Server_Name
FROM
    msdb.dbo.BackupSet S
JOIN
    msdb.dbo.BackupMediaFamily M
ON
    S.Media_Set_ID = M.Media_Set_ID
WHERE
    S.Database_Name In (SELECT Name FROM Sys.Databases)
AND S.Backup_Start_Date > Convert(Char(10), (DateAdd(Day, - @Dias, GetDate())), 121)
-- Para listar todos os databases sem o parametro de dias,
-- comente a linha as duas linhas acima (S.Database... e S.Back...) e troque pelas linhas abaixo.
/*
    S.Database_Name = 'MyDataBase'
*/
ORDER BY
    S.Backup_Start_Date DESC, S.Backup_Finish_Date

-- script que mostra exatamente quantos porcentos uma session_id está consumo em uma CPU

SELECT 
    session_id, 
    start_time, 
    GETDATE() AS date_atual, 
    DATEDIFF(ms, start_time, GETDATE()) AS tmp_total_exec,
    cpu_time, 
    cpu_time / CAST(DATEDIFF(ms, start_time, GETDATE()) AS DECIMAL(18,2)) AS perc_utilzd  
FROM 
    sys.dm_exec_requests
WHERE 
    session_id = 57; -- Substituir pelo id da sessão

-- virtual_address_space_committed_kb - physical_memory_in_use_kb = MemToLeave? ReservedMemory?... NonBufferPoolMem
SELECT physical_memory_in_use_kb / 1024. AS Actual_Usage_mb,
       virtual_address_space_committed_kb / 1024. AS VAS_Committed,
       virtual_address_space_reserved_kb / 1024. AS VAS_Reserved,
       total_virtual_address_space_kb / 1024. AS VAS_Total,
       (large_page_allocations_kb + locked_page_allocations_kb + physical_memory_in_use_kb) / 1024. AS Actual_Physical_Memory_mb,
       (virtual_address_space_committed_kb - physical_memory_in_use_kb) / 1024. AS MemToLeave_MB
FROM sys.dm_os_process_memory
GO

/*
Na coluna Acutal_Usage_mb temos o total consumido pelos processos dentro da buffer pool
Na coluna MemToLeave_MB temos o total consumindo dentro da stack size (2mb) + DLLs

--No SQL Server os espaços de endereços são dividido em:
MemToLeave: stack size (2mb) + DLLs
Buffer pool: Todo o resto

Para trazer o total que o SQL Server está utilizando de memória podemos fazer a soma do Acutal_Usage + MemToLeave_MB
*/



-- VISÃO GERAL DAS CONFIGURAÇÕES DA INSTÂNCIA (DATABASES, STATUS, TAMANHO [ DADOS E LOG ], DATA DE CRIAÇÃO, ÚLTIMO BACKUP, ETC... 

-- Autor: Dirceu Resende 

SELECT
    CONVERT(VARCHAR(25), DB.name) AS dbName,
    state_desc,
    (
        SELECT
            COUNT(1)
        FROM
            sys.master_files
        WHERE
            DB_NAME(database_id) = DB.name
            AND type_desc = 'rows'
    ) AS DataFiles,
    (
        SELECT
            SUM(( size * 8 ) / 1024)
        FROM
            sys.master_files
        WHERE
            DB_NAME(database_id) = DB.name
            AND type_desc = 'rows'
    ) AS [Data MB],
    (
        SELECT
            COUNT(1)
        FROM
            sys.master_files
        WHERE
            DB_NAME(database_id) = DB.name
            AND type_desc = 'log'
    ) AS LogFiles,
    (
        SELECT
            SUM(( size * 8 ) / 1024)
        FROM
            sys.master_files
        WHERE
            DB_NAME(database_id) = DB.name
            AND type_desc = 'log'
    ) AS [Log MB],
    recovery_model_desc AS [Recovery model],
    CASE [compatibility_level]
        WHEN 60 THEN '60 (SQL Server 6.0)'
        WHEN 65 THEN '65 (SQL Server 6.5)'
        WHEN 70 THEN '70 (SQL Server 7.0)'
        WHEN 80 THEN '80 (SQL Server 2000)'
        WHEN 90 THEN '90 (SQL Server 2005)'
        WHEN 100 THEN '100 (SQL Server 2008)'
        WHEN 110 THEN '110 (SQL Server 2012)'
        WHEN 120 THEN '120 (SQL Server 2014)'
        WHEN 130 THEN '130 (SQL Server 2016)'
        WHEN 140 THEN '140 (SQL Server 2017)'
        WHEN 150 THEN '150 (SQL Server 2019)'
    END AS [compatibility level],
    CONVERT(VARCHAR(20), create_date, 103) + ' ' + CONVERT(VARCHAR(20), create_date, 108) AS [Creation date],
    -- last backup
    ISNULL(
    (
        SELECT TOP 1
            CASE type WHEN 'D' THEN 'Full' WHEN 'I' THEN 'Differential' WHEN 'L' THEN 'Transaction log' END + ' – ' + LTRIM(ISNULL(STR(ABS(DATEDIFF(DAY, GETDATE(), backup_finish_date))) + ' days ago', 'NEVER')) + ' – ' + CONVERT(VARCHAR(20), backup_start_date, 103) + ' ' + CONVERT(VARCHAR(20), backup_start_date, 108) + ' – ' + CONVERT(VARCHAR(20), backup_finish_date, 103) + ' ' + CONVERT(VARCHAR(20), backup_finish_date, 108) + ' (' + CAST(DATEDIFF(SECOND, BK.backup_start_date, BK.backup_finish_date) AS VARCHAR(4)) + ' ' + 'seconds)'
        FROM
            msdb..backupset BK
        WHERE
            BK.database_name = DB.name
        ORDER BY
            backup_set_id DESC
    ),    '-'
          ) AS [Last backup],
    CASE WHEN is_auto_close_on = 1 THEN 'autoclose' ELSE '' END AS [autoclose],
    page_verify_option_desc AS [page verify option],
    CASE WHEN is_auto_shrink_on = 1 THEN 'autoshrink' ELSE '' END AS [autoshrink],
    CASE WHEN is_auto_create_stats_on = 1 THEN 'auto create statistics' ELSE '' END AS [auto create statistics],
    CASE WHEN is_auto_update_stats_on = 1 THEN 'auto update statistics' ELSE '' END AS [auto update statistics],
    DB.delayed_durability_desc,
    DB.is_parameterization_forced,
    DB.user_access_desc,
    DB.snapshot_isolation_state_desc,
    DB.is_read_only,
    DB.is_trustworthy_on,
    DB.is_encrypted,
    DB.is_query_store_on,
    DB.is_cdc_enabled,
    DB.is_remote_data_archive_enabled,
    DB.is_subscribed,
    DB.is_merge_published
FROM
    sys.databases DB
ORDER BY
    6 DESC;

-- VERIFICAR QUANTO DE MEMÓRIA UMA INSTÂNCIA DE SQL SERVER ESTÁ UTILIZANDO

SELECT total_physical_memory_kb,
    available_physical_memory_kb,
    total_page_file_kb,
    available_page_file_kb,
    system_memory_state_desc
FROM sys.dm_os_sys_memory;

-- Compartilhado no LinkedIn por: Vitor Fava
-- IDENTIFICAR AS SESSÕES QUE MAIS UTILIZAM O TEMPDB

SELECT

          sys.dm_exec_sessions.session_id AS [SESSION ID],
          DB_NAME(sys.dm_exec_sessions.database_id) AS [DATABASE Name],
          HOST_NAME AS [System Name],
          program_name AS [Program Name],
          login_name AS [USER Name],
          status,
          cpu_time AS [CPU TIME (in milisec)],
          total_scheduled_time AS [Total Scheduled TIME (in milisec)],
          total_elapsed_time AS  [Elapsed TIME (in milisec)],
          (memory_usage * 8)   AS [Memory USAGE (in KB)],
          (user_objects_alloc_page_count * 8) AS [SPACE Allocated FOR USER Objects (in KB)],
          (user_objects_dealloc_page_count * 8) AS [SPACE Deallocated FOR USER Objects (in KB)],
          (internal_objects_alloc_page_count * 8) AS [SPACE Allocated FOR Internal Objects (in KB)],
          (internal_objects_dealloc_page_count * 8) AS [SPACE Deallocated FOR Internal Objects (in KB)],
          CASE is_user_process
                     WHEN 1   THEN 'user session'
                     WHEN 0   THEN 'system session'
          END     AS [SESSION Type], row_count AS [ROW COUNT]
FROM 
    sys.dm_db_session_space_usage
INNER join
    sys.dm_exec_sessions
ON 
    sys.dm_db_session_space_usage.session_id = sys.dm_exec_sessions.session_id

-- Autor: Vitor Fava

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


USE Traces;
GO

-- CREATE TABLE
IF OBJECT_ID('dbo.DBA_JOBS_Audit', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.DBA_JOBS_Audit (
        Servidor NVARCHAR(128),
        DataConsulta DATETIME,

        NomeJob NVARCHAR(128),
        CategoriaJob NVARCHAR(128),
        ProprietarioJob NVARCHAR(128),

        StatusJob NVARCHAR(30),
        DataHoraExecucao DATETIME,

        DuracaoExecucao NVARCHAR(20),
        DuracaoEmSegundos INT,

        MensagemExecucao NVARCHAR(MAX),
        SqlMessageID INT,
        SqlSeverity INT,

        UltimoStepID INT,
        UltimoStepNome NVARCHAR(128)
    );
END;
GO

USE msdb;
GO

INSERT INTO Traces.dbo.DBA_JOBS_Audit
(
    Servidor,
    DataConsulta,

    NomeJob,
    CategoriaJob,
    ProprietarioJob,

    StatusJob,
    DataHoraExecucao,

    DuracaoExecucao,
    DuracaoEmSegundos,

    MensagemExecucao,
    SqlMessageID,
    SqlSeverity,

    UltimoStepID,
    UltimoStepNome
)

SELECT
    @@SERVERNAME AS Servidor,
    GETDATE() AS DataConsulta,

    j.name AS NomeJob,
    c.name AS CategoriaJob,
    SUSER_SNAME(j.owner_sid) AS ProprietarioJob,

    CASE h.run_status
        WHEN 0 THEN 'FAILED'
        WHEN 1 THEN 'SUCCEEDED'
        WHEN 2 THEN 'RETRY'
        WHEN 3 THEN 'CANCELED'
        WHEN 4 THEN 'IN PROGRESS'
        ELSE 'UNKNOWN'
    END AS StatusJob,

    msdb.dbo.agent_datetime(h.run_date, h.run_time) AS DataHoraExecucao,

    RIGHT('00' + CAST(h.run_duration / 10000 AS VARCHAR), 2) + ':' +
    RIGHT('00' + CAST((h.run_duration % 10000) / 100 AS VARCHAR), 2) + ':' +
    RIGHT('00' + CAST(h.run_duration % 100 AS VARCHAR), 2) AS DuracaoExecucao,

    ((h.run_duration / 10000) * 3600) +
    (((h.run_duration % 10000) / 100) * 60) +
    (h.run_duration % 100) AS DuracaoEmSegundos,

    h.message AS MensagemExecucao,
    h.sql_message_id AS SqlMessageID,
    h.sql_severity AS SqlSeverity,

    h.step_id AS UltimoStepID,
    h.step_name AS UltimoStepNome

FROM msdb.dbo.sysjobhistory h
INNER JOIN msdb.dbo.sysjobs j
    ON h.job_id = j.job_id
LEFT JOIN msdb.dbo.syscategories c
    ON j.category_id = c.category_id

WHERE
    h.step_id = 0
    AND (
        j.name LIKE '%backup%'
        OR j.name LIKE '%plan%'
    )
ORDER BY
    DataHoraExecucao DESC;
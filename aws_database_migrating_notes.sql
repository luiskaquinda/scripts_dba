COL FILENAME FOR a30
COL TYPE FOR a20
-- Verificar o que tem no directório 
SELECT * FROM TABLE(rdsadmin.rds_file_util.listdir(p_directory => 'DATA_PUMP_DIR'));

-- Fazer o upload para o directório 

SELECT rdsadmin.rdsadmin_s3_tasks.upload_to_s3(
  p_bucket_name    =>  'amzn-s3-t24-bckt',
  p_s3_prefix      =>  'FULLDB.dmp',   
  p_directory_name =>  'DATA_PUMP_DIR') 
AS TASK_ID FROM DUAL;

-- Ver o andamento do job:

SELECT text FROM table(rdsadmin.rds_file_util.read_text_file('BDUMP','dbtask-1791575942205-1275.log'));

-- Fazer o download para o directório 

SELECT rdsadmin.rdsadmin_s3_tasks.download_from_s3(
      p_bucket_name               =>  'amzn-s3-t24-bckt', 
      p_s3_prefix                 =>  'FULLDB.dmp', 
      p_directory_name            =>  'DATA_PUMP_DIR'
) AS TASK_ID FROM DUAL;

-- Ver o andamento do job:

SELECT text FROM table(rdsadmin.rds_file_util.read_text_file('BDUMP','dbtask-1791576066331-1275.log'));


COL FILENAME FOR a30
COL TYPE FOR a20
-- Verificar o que tem no directório 
SELECT * FROM TABLE(rdsadmin.rds_file_util.listdir(p_directory => 'DATA_PUMP_DIR'));

DECLARE
  v_hdn2 NUMBER;
BEGIN
  v_hdn2 := DBMS_DATAPUMP.OPEN('IMPORT','FULL',NULL,'IMP_FULL');
  DBMS_DATAPUMP.ADD_FILE(v_hdn2,'FULLDB.dmp','DATA_PUMP_DIR',NULL,DBMS_DATAPUMP.KU$_FILE_TYPE_DUMP_FILE);
  DBMS_DATAPUMP.ADD_FILE(v_hdn2,'imp_full.log','DATA_PUMP_DIR',NULL,DBMS_DATAPUMP.KU$_FILE_TYPE_LOG_FILE);
  DBMS_DATAPUMP.METADATA_FILTER(v_hdn2,'EXCLUDE_PATH_EXPR','IN (''TABLESPACE'',''DIRECTORY'',''STATISTICS'')');
  DBMS_DATAPUMP.METADATA_FILTER(v_hdn2,'EXCLUDE_NAME_EXPR','IN (''SYS'',''SYSTEM'',''DBSNMP'',''OUTLN'',''RDSADMIN'')','USER');
  DBMS_DATAPUMP.START_JOB(v_hdn2);
END;
/

SELECT * FROM TABLE
    (rdsadmin.rds_file_util.read_text_file(
        p_directory => 'DATA_PUMP_DIR',
        p_filename  => 'imp_full.log'));
		
EXEC UTL_FILE.FREMOVE('DATA_PUMP_DIR', 'imp_full.log'); 

-- ver detalhes do JOB: 
SELECT owner_name, job_name, operation, job_mode, state FROM DBA_DATAPUMP_JOBS;

SELECT job_name, operation, job_mode, state, attached_sessions FROM DBA_DATAPUMP_JOBS WHERE owner_name = ADMIN;

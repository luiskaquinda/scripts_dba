[oracle@ip-10-166-132-86 ~]$
[oracle@ip-10-166-132-86 ~]$
[oracle@ip-10-166-132-86 ~]$ sqlplus admin/B6pHnLUqpPRnyCqQ8vCS@t24dev2.c900uyysotg0.af-south-1.rds.amazonaws.com:1521/ORCL

SQL*Plus: Release 19.0.0.0.0 - Production on Fri Oct 9 21:54:58 2026
Version 19.3.0.0.0

Copyright (c) 1982, 2019, Oracle.  All rights reserved.

Last Successful login time: Fri Oct 09 2026 21:35:59 +02:00

Connected to:
Oracle Database 19c Standard Edition 2 Release 19.0.0.0.0 - Production
Version 19.32.0.0.0

SQL>
SQL>
SQL> SELECT * FROM TABLE(rdsadmin.rds_file_util.listdir(p_directory => 'DATA_PUMP_DIR'));

FILENAME
--------------------------------------------------------------------------------
TYPE         FILESIZE MTIME
---------- ---------- ---------
datapump/
directory        4096 08-OCT-26

EXPDAT03-15_46_45.DMP
file        524288000 08-OCT-26

EXPDAT06-15_46_45.DMP
file        524288000 08-OCT-26


FILENAME
--------------------------------------------------------------------------------
TYPE         FILESIZE MTIME
---------- ---------- ---------
EXPDAT08-15_46_45.DMP
file        524288000 08-OCT-26

EXPDAT04-15_46_45.DMP
file        524288000 08-OCT-26

T24CloudDB_imp.log
file              155 09-OCT-26


FILENAME
--------------------------------------------------------------------------------
TYPE         FILESIZE MTIME
---------- ---------- ---------
EXPDAT02-15_46_45.DMP
file        524288000 08-OCT-26

EXPDAT01-15_46_45.DMP
file        524288000 08-OCT-26

EXPDAT05-15_46_45.DMP
file        524288000 08-OCT-26


FILENAME
--------------------------------------------------------------------------------
TYPE         FILESIZE MTIME
---------- ---------- ---------
import.log
file              493 07-OCT-26


10 rows selected.

SQL>
SQL> SET LINESIZE 200
SET PAGESIZE 200SQL>
SQL>
SQL>
SQL> SELECT * FROM TABLE(rdsadmin.rds_file_util.listdir(p_directory => 'DATA_PUMP_DIR'));

FILENAME
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
TYPE         FILESIZE MTIME
---------- ---------- ---------
datapump/
directory        4096 08-OCT-26

EXPDAT03-15_46_45.DMP
file        524288000 08-OCT-26

EXPDAT06-15_46_45.DMP
file        524288000 08-OCT-26

EXPDAT08-15_46_45.DMP
file        524288000 08-OCT-26

EXPDAT04-15_46_45.DMP
file        524288000 08-OCT-26

T24CloudDB_imp.log
file              155 09-OCT-26

EXPDAT02-15_46_45.DMP
file        524288000 08-OCT-26

EXPDAT01-15_46_45.DMP
file        524288000 08-OCT-26

EXPDAT05-15_46_45.DMP
file        524288000 08-OCT-26

import.log
file              493 07-OCT-26


10 rows selected.

SQL>
SQL>
SQL> col FILENAME for a30
SQL> col TYPE for a20
SQL> SELECT * FROM TABLE(rdsadmin.rds_file_util.listdir(p_directory => 'DATA_PUMP_DIR'));

FILENAME                       TYPE                   FILESIZE MTIME
------------------------------ -------------------- ---------- ---------
datapump/                      directory                  4096 08-OCT-26
EXPDAT03-15_46_45.DMP          file                  524288000 08-OCT-26
EXPDAT06-15_46_45.DMP          file                  524288000 08-OCT-26
EXPDAT08-15_46_45.DMP          file                  524288000 08-OCT-26
EXPDAT04-15_46_45.DMP          file                  524288000 08-OCT-26
T24CloudDB_imp.log             file                        155 09-OCT-26
EXPDAT02-15_46_45.DMP          file                  524288000 08-OCT-26
EXPDAT01-15_46_45.DMP          file                  524288000 08-OCT-26
EXPDAT05-15_46_45.DMP          file                  524288000 08-OCT-26
import.log                     file                        493 07-OCT-26

10 rows selected.

SQL>
SQL>
SQL>
SQL>
SQL>
SQL> SELECT rdsadmin.rdsadmin_s3_tasks.upload_to_s3(
  p_bucket_name    =>  'amzn-s3-t24-bckt',
  p_s3_prefix      =>  'FULLDB.dmp',
  p_directory_name =>  'DATA_PUMP_DIR')
AS TASK_ID FROM DUAL;  2    3    4    5

TASK_ID
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
1791575942205-1275

SQL>
SQL>
SQL> SELECT text FROM table(rdsadmin.rds_file_util.read_text_file('BDUMP','dbtask-1791575942205-1275.log'));

TEXT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
2026-10-09 19:59:02.278 UTC [INFO ] File #1: Uploading the file /rdsdbdata/datapump/EXPDAT03-15_46_45.DMP to Amazon S3 with bucket name amzn-s3-t24-bckt and key FULLDB.dmpEXPDAT03-15_46_45.DMP.
2026-10-09 19:59:04.379 UTC [INFO ] The file /rdsdbdata/datapump/EXPDAT03-15_46_45.DMP was uploaded to Amazon S3 with bucket name amzn-s3-t24-bckt and key FULLDB.dmpEXPDAT03-15_46_45.DMP.
2026-10-09 19:59:04.392 UTC [INFO ] File #2: Uploading the file /rdsdbdata/datapump/EXPDAT06-15_46_45.DMP to Amazon S3 with bucket name amzn-s3-t24-bckt and key FULLDB.dmpEXPDAT06-15_46_45.DMP.
2026-10-09 19:59:06.473 UTC [INFO ] The file /rdsdbdata/datapump/EXPDAT06-15_46_45.DMP was uploaded to Amazon S3 with bucket name amzn-s3-t24-bckt and key FULLDB.dmpEXPDAT06-15_46_45.DMP.
2026-10-09 19:59:06.486 UTC [INFO ] File #3: Uploading the file /rdsdbdata/datapump/EXPDAT08-15_46_45.DMP to Amazon S3 with bucket name amzn-s3-t24-bckt and key FULLDB.dmpEXPDAT08-15_46_45.DMP.
2026-10-09 19:59:08.550 UTC [INFO ] The file /rdsdbdata/datapump/EXPDAT08-15_46_45.DMP was uploaded to Amazon S3 with bucket name amzn-s3-t24-bckt and key FULLDB.dmpEXPDAT08-15_46_45.DMP.
2026-10-09 19:59:08.582 UTC [INFO ] File #4: Uploading the file /rdsdbdata/datapump/EXPDAT04-15_46_45.DMP to Amazon S3 with bucket name amzn-s3-t24-bckt and key FULLDB.dmpEXPDAT04-15_46_45.DMP.
2026-10-09 19:59:10.661 UTC [INFO ] The file /rdsdbdata/datapump/EXPDAT04-15_46_45.DMP was uploaded to Amazon S3 with bucket name amzn-s3-t24-bckt and key FULLDB.dmpEXPDAT04-15_46_45.DMP.
2026-10-09 19:59:10.680 UTC [INFO ] File #5: Uploading the file /rdsdbdata/datapump/T24CloudDB_imp.log to Amazon S3 with bucket name amzn-s3-t24-bckt and key FULLDB.dmpT24CloudDB_imp.log.
2026-10-09 19:59:10.698 UTC [INFO ] The file /rdsdbdata/datapump/T24CloudDB_imp.log was uploaded to Amazon S3 with bucket name amzn-s3-t24-bckt and key FULLDB.dmpT24CloudDB_imp.log.
2026-10-09 19:59:10.710 UTC [INFO ] File #6: Uploading the file /rdsdbdata/datapump/EXPDAT02-15_46_45.DMP to Amazon S3 with bucket name amzn-s3-t24-bckt and key FULLDB.dmpEXPDAT02-15_46_45.DMP.
2026-10-09 19:59:12.819 UTC [INFO ] The file /rdsdbdata/datapump/EXPDAT02-15_46_45.DMP was uploaded to Amazon S3 with bucket name amzn-s3-t24-bckt and key FULLDB.dmpEXPDAT02-15_46_45.DMP.
2026-10-09 19:59:12.833 UTC [INFO ] File #7: Uploading the file /rdsdbdata/datapump/EXPDAT01-15_46_45.DMP to Amazon S3 with bucket name amzn-s3-t24-bckt and key FULLDB.dmpEXPDAT01-15_46_45.DMP.
2026-10-09 19:59:14.898 UTC [INFO ] The file /rdsdbdata/datapump/EXPDAT01-15_46_45.DMP was uploaded to Amazon S3 with bucket name amzn-s3-t24-bckt and key FULLDB.dmpEXPDAT01-15_46_45.DMP.
2026-10-09 19:59:14.912 UTC [INFO ] File #8: Uploading the file /rdsdbdata/datapump/EXPDAT05-15_46_45.DMP to Amazon S3 with bucket name amzn-s3-t24-bckt and key FULLDB.dmpEXPDAT05-15_46_45.DMP.
2026-10-09 19:59:16.989 UTC [INFO ] The file /rdsdbdata/datapump/EXPDAT05-15_46_45.DMP was uploaded to Amazon S3 with bucket name amzn-s3-t24-bckt and key FULLDB.dmpEXPDAT05-15_46_45.DMP.
2026-10-09 19:59:17.003 UTC [INFO ] File #9: Uploading the file /rdsdbdata/datapump/import.log to Amazon S3 with bucket name amzn-s3-t24-bckt and key FULLDB.dmpimport.log.
2026-10-09 19:59:17.029 UTC [INFO ] The file /rdsdbdata/datapump/import.log was uploaded to Amazon S3 with bucket name amzn-s3-t24-bckt and key FULLDB.dmpimport.log.
2026-10-09 19:59:17.029 UTC [INFO ] The task finished successfully.

19 rows selected.

SQL>
SQL>
SQL>
SQL>
SQL>
SQL>
SQL>

SQL> SQL> SELECT rdsadmin.rdsadmin_s3_tasks.download_from_s3(
      p_bucket_name               =>  'amzn-s3-t24-bckt',
      p_s3_prefix                 =>  'FULLDB.dmp',
      p_directory_name            =>  'DATA_PUMP_DIR'
) AS TASK_ID FROM DUAL;  2    3    4    5

TASK_ID
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
1791576066331-1275

SQL>
SQL>
SQL>

SQL> SQL>

SQL> SQL>

SQL> SQL> SELECT text FROM table(rdsadmin.rds_file_util.read_text_file('BDUMP','dbtask-1791576066331-1275.log'));

TEXT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
2026-10-09 20:01:06.559 UTC [INFO ] This task is about to list the Amazon S3 objects for AWS Region af-south-1, bucket name amzn-s3-t24-bckt, and prefix FULLDB.dmp.
2026-10-09 20:01:06.591 UTC [INFO ] The task successfully listed the Amazon S3 objects for AWS Region af-south-1, bucket name amzn-s3-t24-bckt, and prefix FULLDB.dmp.
2026-10-09 20:01:06.605 UTC [INFO ] This task is about to download the Amazon S3 object or objects in /rdsdbdata/datapump from bucket name amzn-s3-t24-bckt and key FULLDB.dmp.
2026-10-09 20:01:21.096 UTC [INFO ] The task successfully downloaded the Amazon S3 object or objects from bucket name amzn-s3-t24-bckt with key FULLDB.dmp to the location /rdsdbdata/datapump.
2026-10-09 20:01:21.098 UTC [INFO ] This task is about to download the Amazon S3 object or objects in /rdsdbdata/datapump from bucket name amzn-s3-t24-bckt and key FULLDB.dmpEXPDAT01-15_46_45.DMP.
2026-10-09 20:01:23.537 UTC [INFO ] The task successfully downloaded the Amazon S3 object or objects from bucket name amzn-s3-t24-bckt with key FULLDB.dmpEXPDAT01-15_46_45.DMP to the location /rdsdbda
ta/datapump.

2026-10-09 20:01:23.537 UTC [INFO ] This task is about to download the Amazon S3 object or objects in /rdsdbdata/datapump from bucket name amzn-s3-t24-bckt and key FULLDB.dmpEXPDAT02-15_46_45.DMP.
2026-10-09 20:01:25.957 UTC [INFO ] The task successfully downloaded the Amazon S3 object or objects from bucket name amzn-s3-t24-bckt with key FULLDB.dmpEXPDAT02-15_46_45.DMP to the location /rdsdbda
ta/datapump.

2026-10-09 20:01:25.957 UTC [INFO ] This task is about to download the Amazon S3 object or objects in /rdsdbdata/datapump from bucket name amzn-s3-t24-bckt and key FULLDB.dmpEXPDAT03-15_46_45.DMP.
2026-10-09 20:01:28.408 UTC [INFO ] The task successfully downloaded the Amazon S3 object or objects from bucket name amzn-s3-t24-bckt with key FULLDB.dmpEXPDAT03-15_46_45.DMP to the location /rdsdbda
ta/datapump.

2026-10-09 20:01:28.408 UTC [INFO ] This task is about to download the Amazon S3 object or objects in /rdsdbdata/datapump from bucket name amzn-s3-t24-bckt and key FULLDB.dmpEXPDAT04-15_46_45.DMP.
2026-10-09 20:01:30.801 UTC [INFO ] The task successfully downloaded the Amazon S3 object or objects from bucket name amzn-s3-t24-bckt with key FULLDB.dmpEXPDAT04-15_46_45.DMP to the location /rdsdbda
ta/datapump.

2026-10-09 20:01:30.802 UTC [INFO ] This task is about to download the Amazon S3 object or objects in /rdsdbdata/datapump from bucket name amzn-s3-t24-bckt and key FULLDB.dmpEXPDAT05-15_46_45.DMP.
2026-10-09 20:01:33.235 UTC [INFO ] The task successfully downloaded the Amazon S3 object or objects from bucket name amzn-s3-t24-bckt with key FULLDB.dmpEXPDAT05-15_46_45.DMP to the location /rdsdbda
ta/datapump.

2026-10-09 20:01:33.235 UTC [INFO ] This task is about to download the Amazon S3 object or objects in /rdsdbdata/datapump from bucket name amzn-s3-t24-bckt and key FULLDB.dmpEXPDAT06-15_46_45.DMP.
2026-10-09 20:01:35.614 UTC [INFO ] The task successfully downloaded the Amazon S3 object or objects from bucket name amzn-s3-t24-bckt with key FULLDB.dmpEXPDAT06-15_46_45.DMP to the location /rdsdbda
ta/datapump.

2026-10-09 20:01:35.614 UTC [INFO ] This task is about to download the Amazon S3 object or objects in /rdsdbdata/datapump from bucket name amzn-s3-t24-bckt and key FULLDB.dmpEXPDAT08-15_46_45.DMP.
2026-10-09 20:01:37.957 UTC [INFO ] The task successfully downloaded the Amazon S3 object or objects from bucket name amzn-s3-t24-bckt with key FULLDB.dmpEXPDAT08-15_46_45.DMP to the location /rdsdbda
ta/datapump.

2026-10-09 20:01:37.957 UTC [INFO ] This task is about to download the Amazon S3 object or objects in /rdsdbdata/datapump from bucket name amzn-s3-t24-bckt and key FULLDB.dmpT24CloudDB_imp.log.
2026-10-09 20:01:38.099 UTC [INFO ] The task successfully downloaded the Amazon S3 object or objects from bucket name amzn-s3-t24-bckt with key FULLDB.dmpT24CloudDB_imp.log to the location /rdsdbdata/
datapump.

2026-10-09 20:01:38.099 UTC [INFO ] This task is about to download the Amazon S3 object or objects in /rdsdbdata/datapump from bucket name amzn-s3-t24-bckt and key FULLDB.dmpimport.log.
2026-10-09 20:01:38.211 UTC [INFO ] The task successfully downloaded the Amazon S3 object or objects from bucket name amzn-s3-t24-bckt with key FULLDB.dmpimport.log to the location /rdsdbdata/datapump
.

2026-10-09 20:01:38.211 UTC [INFO ] The task finished successfully.

23 rows selected.

SQL>
SQL>

SQL> SQL>
SQL>
SQL>
SQL>
SQL>
SQL>
SQL> SELECT * FROM TABLE(rdsadmin.rds_file_util.listdir(p_directory => 'DATA_PUMP_DIR'));

FILENAME                       TYPE                   FILESIZE MTIME
------------------------------ -------------------- ---------- ---------
datapump/                      directory                  4096 09-OCT-26
FULLDB.dmpEXPDAT02-15_46_45.DM file                  524288000 09-OCT-26
P

EXPDAT03-15_46_45.DMP          file                  524288000 08-OCT-26
FULLDB.dmpEXPDAT05-15_46_45.DM file                  524288000 09-OCT-26
P

FULLDB.dmpEXPDAT03-15_46_45.DM file                  524288000 09-OCT-26
P

FULLDB.dmpEXPDAT01-15_46_45.DM file                  524288000 09-OCT-26
P

EXPDAT06-15_46_45.DMP          file                  524288000 08-OCT-26
FULLDB.dmpimport.log           file                        493 09-OCT-26
EXPDAT08-15_46_45.DMP          file                  524288000 08-OCT-26
FULLDB.dmpEXPDAT06-15_46_45.DM file                  524288000 09-OCT-26
P

EXPDAT04-15_46_45.DMP          file                  524288000 08-OCT-26
T24CloudDB_imp.log             file                        155 09-OCT-26
EXPDAT02-15_46_45.DMP          file                  524288000 08-OCT-26
FULLDB.dmpT24CloudDB_imp.log   file                        155 09-OCT-26
EXPDAT01-15_46_45.DMP          file                  524288000 08-OCT-26
FULLDB.dmp                     file                 4478656512 09-OCT-26
EXPDAT05-15_46_45.DMP          file                  524288000 08-OCT-26
FULLDB.dmpEXPDAT04-15_46_45.DM file                  524288000 09-OCT-26
P

import.log                     file                        493 07-OCT-26
FULLDB.dmpEXPDAT08-15_46_45.DM file                  524288000 09-OCT-26
P


20 rows selected.

SQL> col FILENAME for a45
SQL> SELECT * FROM TABLE(rdsadmin.rds_file_util.listdir(p_directory => 'DATA_PUMP_DIR'));

FILENAME                                      TYPE                   FILESIZE MTIME
--------------------------------------------- -------------------- ---------- ---------
datapump/                                     directory                  4096 09-OCT-26
FULLDB.dmpEXPDAT02-15_46_45.DMP               file                  524288000 09-OCT-26
EXPDAT03-15_46_45.DMP                         file                  524288000 08-OCT-26
FULLDB.dmpEXPDAT05-15_46_45.DMP               file                  524288000 09-OCT-26
FULLDB.dmpEXPDAT03-15_46_45.DMP               file                  524288000 09-OCT-26
FULLDB.dmpEXPDAT01-15_46_45.DMP               file                  524288000 09-OCT-26
EXPDAT06-15_46_45.DMP                         file                  524288000 08-OCT-26
FULLDB.dmpimport.log                          file                        493 09-OCT-26
EXPDAT08-15_46_45.DMP                         file                  524288000 08-OCT-26
FULLDB.dmpEXPDAT06-15_46_45.DMP               file                  524288000 09-OCT-26
EXPDAT04-15_46_45.DMP                         file                  524288000 08-OCT-26
T24CloudDB_imp.log                            file                        155 09-OCT-26
EXPDAT02-15_46_45.DMP                         file                  524288000 08-OCT-26
FULLDB.dmpT24CloudDB_imp.log                  file                        155 09-OCT-26
EXPDAT01-15_46_45.DMP                         file                  524288000 08-OCT-26
FULLDB.dmp                                    file                 4478656512 09-OCT-26
EXPDAT05-15_46_45.DMP                         file                  524288000 08-OCT-26
FULLDB.dmpEXPDAT04-15_46_45.DMP               file                  524288000 09-OCT-26
import.log                                    file                        493 07-OCT-26
FULLDB.dmpEXPDAT08-15_46_45.DMP               file                  524288000 09-OCT-26

20 rows selected.

SQL>
SQL>
SQL>
SQL>
SQL>

SQL> SQL>
SQL>
SQL>

SQL> SQL>
SQL>
SQL>
SQL>
SQL>
SQL>
SQL> DECLARE
  h NUMBER;
BEGIN
  h := DBMS_DATAPUMP.OPEN('IMPORT','FULL',NULL,'IMP_FULL');
  DBMS_DATAPUMP.ADD_FILE(h,'FULLDB.dmp','DATA_PUMP_DIR',NULL,DBMS_DATAPUMP.KU$_FILE_TYPE_DUMP_FILE);
  DBMS_DATAPUMP.ADD_FILE(h,'imp_full.log','DATA_PUMP_DIR',NULL,DBMS_DATAPUMP.KU$_FILE_TYPE_LOG_FILE);
  DBMS_DATAPUMP.METADATA_FILTER(h,'EXCLUDE_PATH_EXPR','IN (''TABLESPACE'',''DIRECTORY'',''STATISTICS'')');
  2    3    4    5    6    7    8    DBMS_DATAPUMP.METADATA_FILTER(h,'EXCLUDE_NAME_EXPR','IN (''SYS'',''SYSTEM'',''DBSNMP'',''OUTLN'',''RDSADMIN'')','USER');
  DBMS_DATAPUMP.SET_PARALLEL(h,4);
  DBMS_DATAPUMP.START_JOB(h);
  9   10   11  END;
/ 12
DECLARE
*
ERROR at line 1:
ORA-39002: invalid operation
ORA-06512: at "SYS.DBMS_SYS_ERROR", line 79
ORA-06512: at "SYS.DBMS_DATAPUMP", line 4929
ORA-06512: at "SYS.DBMS_DATAPUMP", line 6938
ORA-06512: at line 9


SQL>
SQL>
SQL> SELECT * FROM TABLE(rdsadmin.rds_file_util.listdir(p_directory => 'DATA_PUMP_DIR'));

FILENAME                                      TYPE                   FILESIZE MTIME
--------------------------------------------- -------------------- ---------- ---------
datapump/                                     directory                  4096 09-OCT-26
FULLDB.dmpEXPDAT02-15_46_45.DMP               file                  524288000 09-OCT-26
EXPDAT03-15_46_45.DMP                         file                  524288000 08-OCT-26
FULLDB.dmpEXPDAT05-15_46_45.DMP               file                  524288000 09-OCT-26
FULLDB.dmpEXPDAT03-15_46_45.DMP               file                  524288000 09-OCT-26
FULLDB.dmpEXPDAT01-15_46_45.DMP               file                  524288000 09-OCT-26
EXPDAT06-15_46_45.DMP                         file                  524288000 08-OCT-26
FULLDB.dmpimport.log                          file                        493 09-OCT-26
EXPDAT08-15_46_45.DMP                         file                  524288000 08-OCT-26
FULLDB.dmpEXPDAT06-15_46_45.DMP               file                  524288000 09-OCT-26
EXPDAT04-15_46_45.DMP                         file                  524288000 08-OCT-26
T24CloudDB_imp.log                            file                        155 09-OCT-26
imp_full.log                                  file                         70 09-OCT-26
EXPDAT02-15_46_45.DMP                         file                  524288000 08-OCT-26
FULLDB.dmpT24CloudDB_imp.log                  file                        155 09-OCT-26
EXPDAT01-15_46_45.DMP                         file                  524288000 08-OCT-26
FULLDB.dmp                                    file                 4478656512 09-OCT-26
EXPDAT05-15_46_45.DMP                         file                  524288000 08-OCT-26
FULLDB.dmpEXPDAT04-15_46_45.DMP               file                  524288000 09-OCT-26
import.log                                    file                        493 07-OCT-26
FULLDB.dmpEXPDAT08-15_46_45.DMP               file                  524288000 09-OCT-26

21 rows selected.

SQL>
SQL>

SQL> SQL>

SQL> SQL>

SQL> SQL>
SQL>

SQL> SQL>
SQL>
SQL>
SQL> SELECT * FROM TABLE
    (rdsadmin.rds_file_util.read_text_file(
        p_directory => 'DATA_PUMP_DIR',
        p_filename  => 'imp_full.log'));  2    3    4

TEXT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ORA-39094: Parallel execution not supported in this database edition.

SQL>

SQL> SQL>
SQL>

SQL> SQL>
SQL> EXEC UTL_FILE.FREMOVE('DATA_PUMP_DIR', 'imp_full.log');

PL/SQL procedure successfully completed.

SQL> SELECT * FROM TABLE(rdsadmin.rds_file_util.listdir(p_directory => 'DATA_PUMP_DIR'));

FILENAME                                      TYPE                   FILESIZE MTIME
--------------------------------------------- -------------------- ---------- ---------
datapump/                                     directory                  4096 09-OCT-26
FULLDB.dmpEXPDAT02-15_46_45.DMP               file                  524288000 09-OCT-26
EXPDAT03-15_46_45.DMP                         file                  524288000 08-OCT-26
FULLDB.dmpEXPDAT05-15_46_45.DMP               file                  524288000 09-OCT-26
FULLDB.dmpEXPDAT03-15_46_45.DMP               file                  524288000 09-OCT-26
FULLDB.dmpEXPDAT01-15_46_45.DMP               file                  524288000 09-OCT-26
EXPDAT06-15_46_45.DMP                         file                  524288000 08-OCT-26
FULLDB.dmpimport.log                          file                        493 09-OCT-26
EXPDAT08-15_46_45.DMP                         file                  524288000 08-OCT-26
FULLDB.dmpEXPDAT06-15_46_45.DMP               file                  524288000 09-OCT-26
EXPDAT04-15_46_45.DMP                         file                  524288000 08-OCT-26
T24CloudDB_imp.log                            file                        155 09-OCT-26
EXPDAT02-15_46_45.DMP                         file                  524288000 08-OCT-26
FULLDB.dmpT24CloudDB_imp.log                  file                        155 09-OCT-26
EXPDAT01-15_46_45.DMP                         file                  524288000 08-OCT-26
FULLDB.dmp                                    file                 4478656512 09-OCT-26
EXPDAT05-15_46_45.DMP                         file                  524288000 08-OCT-26
FULLDB.dmpEXPDAT04-15_46_45.DMP               file                  524288000 09-OCT-26
import.log                                    file                        493 07-OCT-26
FULLDB.dmpEXPDAT08-15_46_45.DMP               file                  524288000 09-OCT-26

20 rows selected.

SQL>
SQL>

SQL> SQL>
SQL>
SQL>
SQL>
SQL> DECLARE
  h NUMBER;
BEGIN
  h := DBMS_DATAPUMP.OPEN('IMPORT','FULL',NULL,'IMP_FULL');
  DBMS_DATAPUMP.ADD_FILE(h,'FULLDB.dmp','DATA_PUMP_DIR',NULL,DBMS_DATAPUMP.KU$_FILE_TYPE_DUMP_FILE);
  DBMS_DATAPUMP.ADD_FILE(h,'imp_full.log','DATA_PUMP_DIR',NULL,DBMS_DATAPUMP.KU$_FILE_TYPE_LOG_FILE);
  DBMS_DATAPUMP.METADATA_FILTER(h,'EXCLUDE_PATH_EXPR','IN (''TABLESPACE'',''DIRECTORY'',''STATISTICS'')');
  DBMS_DATAPUMP.METADATA_FILTER(h,'EXCLUDE_NAME_EXPR','IN (''SYS'',''SYSTEM'',''DBSNMP'',''OUTLN'',''RDSADMI  2  N'')','USER');
  DBMS_DATAPUMP.START_JOB(h);
END;
  3    4    5    6    7    8    9   10   11  /
DECLARE
*
ERROR at line 1:
ORA-31634: job already exists
ORA-06512: at "SYS.DBMS_SYS_ERROR", line 79
ORA-06512: at "SYS.DBMS_DATAPUMP", line 1849
ORA-06512: at "SYS.DBMS_DATAPUMP", line 6867
ORA-06512: at line 4


SQL>
SQL>
SQL>

SQL> SQL>
SQL>
SQL>

SQL> SQL>
SQL>
SQL>
SQL>
SQL> DECLARE
  v_hdn2 NUMBER;
BEGIN
  v_hdn2 := DBMS_DATAPUMP.OPEN('IMPORT','FULL',NULL,'IMP_FULL');
  DBMS_DATAPUMP.ADD_FILE(v_hdn2,'FULLDB.dmp','DATA_PUMP_DIR',NULL,DBMS_DATAPUMP.KU$_FILE_TYPE_DUMP_FILE);
  DBMS_DATAPUMP.ADD_FILE(v_hdn2,'imp_full.log','DATA_PUMP_DIR',NULL,DBMS_DATAPUMP.KU$_FILE_TYPE_LOG_FILE);
  DBMS_DATAPUMP.METADATA_FILTER(v_hdn2,'EXCLUDE_PATH_EXPR','IN (''TABLESPACE'',''DIRECTORY'',''STATISTICS'')');
  DBMS_DATAPUMP.METADATA_FILTER(v_hdn2,'EXCLUDE_NAME_EXPR','IN (''SYS'',''SYSTEM'',''DBSNMP'',''OUTLN'',''RDSADMIN'')','USER');
  2    3    4    5    6    7    8    9    DBMS_DATAPUMP.START_JOB(v_hdn2);
END;
/ 10   11
DECLARE
*
ERROR at line 1:
ORA-31634: job already exists
ORA-06512: at "SYS.DBMS_SYS_ERROR", line 79
ORA-06512: at "SYS.DBMS_DATAPUMP", line 1849
ORA-06512: at "SYS.DBMS_DATAPUMP", line 6867
ORA-06512: at line 4


SQL>
SQL>
SQL>
SQL>
SQL>
SQL> SELECT owner_name,
job_name,
operation,
job_mode,
state
FROM dba_datapump_jobs;  2    3    4    5    6

OWNER_NAME
--------------------------------------------------------------------------------------------------------------------------------
JOB_NAME
--------------------------------------------------------------------------------------------------------------------------------
OPERATION
--------------------------------------------------------------------------------------------------------------------------------
JOB_MODE
--------------------------------------------------------------------------------------------------------------------------------
STATE
--------------------------------------------------------------------------------------------------------------------------------
ADMIN
IMP_FULL
IMPORT
FULL
DEFINING


SQL>
SQL>
SQL>
SQL>
SQL> COL OWNER_NAME FOR A30
SQL> COL JOB_NAME FOR A30
SQL>
SQL> COL OPERATION FOR A30
SQL>
SQL>
SQL>
SQL>
SQL> SELECT owner_name, job_name, operation, job_mode, state FROM DBA_DATAPUMP_JOBS;

OWNER_NAME                     JOB_NAME                       OPERATION
------------------------------ ------------------------------ ------------------------------
JOB_MODE
--------------------------------------------------------------------------------------------------------------------------------
STATE
--------------------------------------------------------------------------------------------------------------------------------
ADMIN                          IMP_FULL                       IMPORT
FULL
DEFINING


SQL> COL JOB_MODE FOR A20
SQL> COL STATE FOR A30
SQL>
SQL>
SQL> SELECT owner_name, job_name, operation, job_mode, state FROM DBA_DATAPUMP_JOBS;

OWNER_NAME                     JOB_NAME                       OPERATION                      JOB_MODE             STATE
------------------------------ ------------------------------ ------------------------------ -------------------- ------------------------------
ADMIN                          IMP_FULL                       IMPORT                         FULL                 DEFINING

SQL>

SQL> SQL>
SQL>
SQL>
SQL>

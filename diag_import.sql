================================================================
99 - DIAGNOSTICO DO IMPORT (so leitura, nao altera nada)
================================================================

### 1. LOG DO IMPORT (6 linhas)

--- inicio do log ---
[1] ORA-39014: One or more workers have prematurely exited.
[2] ORA-39029: worker 1 with process name "DW00" prematurely terminated
[3] ORA-31671: Worker process DW00 had an unhandled exception.
[4] ORA-39014: One or more workers have prematurely exited.
[5] ORA-39029: worker 2 with process name "DW00" prematurely terminated
[6] ORA-31671: Worker process DW00 had an unhandled exception.

--- fases executadas ---

--- contexto da primeira queda do worker (linha 1) ---
[1] ORA-39014: One or more workers have prematurely exited.
[2] ORA-39029: worker 1 with process name "DW00" prematurely terminated
[3] ORA-31671: Worker process DW00 had an unhandled exception.
[4] ORA-39014: One or more workers have prematurely exited.
[5] ORA-39029: worker 2 with process name "DW00" prematurely terminated
[6] ORA-31671: Worker process DW00 had an unhandled exception.

--- ultimas 15 linhas ---
[1] ORA-39014: One or more workers have prematurely exited.
[2] ORA-39029: worker 1 with process name "DW00" prematurely terminated
[3] ORA-31671: Worker process DW00 had an unhandled exception.
[4] ORA-39014: One or more workers have prematurely exited.
[5] ORA-39029: worker 2 with process name "DW00" prematurely terminated
[6] ORA-31671: Worker process DW00 had an unhandled exception.

### 2. ALERT LOG (erros das ultimas 24h, no maximo 80 linhas)

09/10 15:22:19  DM00 stopped with pid=65, OS id=1080044, job ADMIN.SYS_IMPORT_FULL_01
09/10 15:22:27  DM01 stopped with pid=67, OS id=1092309, job ADMIN.IMP_T24_TEST
09/10 15:23:01  DM02 stopped with pid=68, OS id=1093423, job ADMIN.SYS_IMPORT_FULL_02
09/10 20:35:45  DM00 started with pid=67, OS id=1335337, job ADMIN.IMP_FULL
09/10 22:00:02  Errors in file /rdsdbdata/log/diag/rdbms/orcl_a/ORCL/trace/ORCL_j002_1374940.trc: ORA-12012: error on auto execute of job "SYS"."ORA$AT_SQ_SQL_SW_96" ORA-38153: Software
10/10 04:07:31  DM00 stopped with pid=67, OS id=1335337, job ADMIN.IMP_FULL
10/10 06:00:02  Errors in file /rdsdbdata/log/diag/rdbms/orcl_a/ORCL/trace/ORCL_j002_1600691.trc: ORA-12012: error on auto execute of job "SYS"."ORA$AT_SQ_SQL_SW_99" ORA-38153: Software
10/10 10:05:22  Errors in file /rdsdbdata/log/diag/rdbms/orcl_a/ORCL/trace/ORCL_j002_1715684.trc: ORA-12012: error on auto execute of job "SYS"."ORA$AT_SQ_SQL_SW_102" ORA-38153: Software
10/10 12:57:21  DM00 started with pid=62, OS id=1796493, job ADMIN.IMP_FULL
10/10 12:57:22  DW00 started with pid=67, OS id=1796495, wid=1, job ADMIN.IMP_FULL
10/10 12:57:22  Errors in file /rdsdbdata/log/diag/rdbms/orcl_a/ORCL/trace/ORCL_dw00_1796495.trc  (incident=66708): ORA-00600: internal error code, arguments: [kupdls_rdData-01], [ORA-20
10/10 12:57:22  Incident details in: /rdsdbdata/log/diag/rdbms/orcl_a/ORCL/incident/incdir_66708/ORCL_dw00_1796495_i66708.trc
10/10 12:57:23  Errors in file /rdsdbdata/log/diag/rdbms/orcl_a/ORCL/trace/ORCL_dw00_1796495.trc  (incident=66709): ORA-00600: internal error code, arguments: [kupdls_rdData-01], [ORA-20
10/10 12:57:23  Incident details in: /rdsdbdata/log/diag/rdbms/orcl_a/ORCL/incident/incdir_66709/ORCL_dw00_1796495_i66709.trc
10/10 12:57:24  DW00 terminating with fatal err=600, pid=67, wid=1, job ADMIN.IMP_FULL
10/10 12:57:24  Dumping diagnostic data in directory=[cdmp_20261010125724], requested by (instance=1, osid=1796495 (DW00)), summary=[incident=66708].
10/10 12:57:51  DW00 started with pid=49, OS id=1796600, wid=2, job ADMIN.IMP_FULL
10/10 12:57:52  Errors in file /rdsdbdata/log/diag/rdbms/orcl_a/ORCL/trace/ORCL_dw00_1796600.trc  (incident=66564): ORA-00600: internal error code, arguments: [kupdls_rdData-01], [ORA-20
10/10 12:57:52  Incident details in: /rdsdbdata/log/diag/rdbms/orcl_a/ORCL/incident/incdir_66564/ORCL_dw00_1796600_i66564.trc
10/10 12:57:52  Errors in file /rdsdbdata/log/diag/rdbms/orcl_a/ORCL/trace/ORCL_dw00_1796600.trc  (incident=66565): ORA-00600: internal error code, arguments: [kupdls_rdData-01], [ORA-20
10/10 12:57:52  Incident details in: /rdsdbdata/log/diag/rdbms/orcl_a/ORCL/incident/incdir_66565/ORCL_dw00_1796600_i66565.trc
10/10 12:57:53  DW00 terminating with fatal err=600, pid=49, wid=2, job ADMIN.IMP_FULL
10/10 12:57:53  Dumping diagnostic data in directory=[cdmp_20261010125753], requested by (instance=1, osid=1796600 (DW00)), summary=[incident=66564].
10/10 12:59:21  DM00 stopped with pid=62, OS id=1796493, job ADMIN.IMP_FULL
10/10 14:05:26  Errors in file /rdsdbdata/log/diag/rdbms/orcl_a/ORCL/trace/ORCL_j002_1828758.trc: ORA-12012: error on auto execute of job "SYS"."ORA$AT_SQ_SQL_SW_105" ORA-38153: Software
10/10 14:40:05  DM00 started with pid=52, OS id=1845150, job ADMIN.CHK_DUMP
10/10 14:40:06  DW00 started with pid=61, OS id=1845152, wid=1, job ADMIN.CHK_DUMP
10/10 14:40:12  DM00 stopped with pid=52, OS id=1845150, job ADMIN.CHK_DUMP
10/10 14:41:03  DM00 started with pid=68, OS id=1845586, job ADMIN.IMP_MIGRACAO
10/10 14:41:04  DW00 started with pid=69, OS id=1845588, wid=1, job ADMIN.IMP_MIGRACAO
10/10 14:41:04  Errors in file /rdsdbdata/log/diag/rdbms/orcl_a/ORCL/trace/ORCL_dw00_1845588.trc  (incident=66724): ORA-00600: internal error code, arguments: [kupdls_rdData-01], [ORA-20
10/10 14:41:04  Incident details in: /rdsdbdata/log/diag/rdbms/orcl_a/ORCL/incident/incdir_66724/ORCL_dw00_1845588_i66724.trc
10/10 14:41:05  Errors in file /rdsdbdata/log/diag/rdbms/orcl_a/ORCL/trace/ORCL_dw00_1845588.trc  (incident=66725): ORA-00600: internal error code, arguments: [kupdls_rdData-01], [ORA-20
10/10 14:41:05  Incident details in: /rdsdbdata/log/diag/rdbms/orcl_a/ORCL/incident/incdir_66725/ORCL_dw00_1845588_i66725.trc
10/10 14:41:05  DW00 terminating with fatal err=600, pid=69, wid=1, job ADMIN.IMP_MIGRACAO
10/10 14:41:06  Dumping diagnostic data in directory=[cdmp_20261010144106], requested by (instance=1, osid=1845588 (DW00)), summary=[incident=66724].
10/10 14:41:33  DW00 started with pid=69, OS id=1845778, wid=2, job ADMIN.IMP_MIGRACAO
10/10 14:41:33  Errors in file /rdsdbdata/log/diag/rdbms/orcl_a/ORCL/trace/ORCL_dw00_1845778.trc  (incident=66726): ORA-00600: internal error code, arguments: [kupdls_rdData-01], [ORA-20
10/10 14:41:33  Incident details in: /rdsdbdata/log/diag/rdbms/orcl_a/ORCL/incident/incdir_66726/ORCL_dw00_1845778_i66726.trc
10/10 14:41:34  Errors in file /rdsdbdata/log/diag/rdbms/orcl_a/ORCL/trace/ORCL_dw00_1845778.trc  (incident=66727): ORA-00600: internal error code, arguments: [kupdls_rdData-01], [ORA-20
10/10 14:41:34  Incident details in: /rdsdbdata/log/diag/rdbms/orcl_a/ORCL/incident/incdir_66727/ORCL_dw00_1845778_i66727.trc
10/10 14:41:35  Dumping diagnostic data in directory=[cdmp_20261010144135], requested by (instance=1, osid=1845778 (DW00)), summary=[incident=66726].
10/10 14:41:35  DW00 terminating with fatal err=600, pid=69, wid=2, job ADMIN.IMP_MIGRACAO
10/10 14:41:36  Dumping diagnostic data in directory=[cdmp_20261010144136], requested by (instance=1, osid=1845778 (DW00)), summary=[incident=66727].
10/10 14:43:03  DM00 stopped with pid=68, OS id=1845586, job ADMIN.IMP_MIGRACAO
10/10 15:10:43  DM00 started with pid=52, OS id=1859402, job ADMIN.CHK_DUMP
10/10 15:10:44  DW00 started with pid=61, OS id=1859404, wid=1, job ADMIN.CHK_DUMP
10/10 15:10:51  DM00 stopped with pid=52, OS id=1859402, job ADMIN.CHK_DUMP
10/10 15:11:56  DM00 started with pid=68, OS id=1860085, job ADMIN.IMP_MIGRACAO
10/10 15:11:57  DW00 started with pid=69, OS id=1860088, wid=1, job ADMIN.IMP_MIGRACAO
10/10 15:11:57  Errors in file /rdsdbdata/log/diag/rdbms/orcl_a/ORCL/trace/ORCL_dw00_1860088.trc  (incident=66728): ORA-00600: internal error code, arguments: [kupdls_rdData-01], [ORA-20
10/10 15:11:57  Incident details in: /rdsdbdata/log/diag/rdbms/orcl_a/ORCL/incident/incdir_66728/ORCL_dw00_1860088_i66728.trc
10/10 15:11:58  Errors in file /rdsdbdata/log/diag/rdbms/orcl_a/ORCL/trace/ORCL_dw00_1860088.trc  (incident=66729): ORA-00600: internal error code, arguments: [kupdls_rdData-01], [ORA-20
10/10 15:11:58  Incident details in: /rdsdbdata/log/diag/rdbms/orcl_a/ORCL/incident/incdir_66729/ORCL_dw00_1860088_i66729.trc
10/10 15:11:58  DW00 terminating with fatal err=600, pid=69, wid=1, job ADMIN.IMP_MIGRACAO
10/10 15:11:59  Dumping diagnostic data in directory=[cdmp_20261010151159], requested by (instance=1, osid=1860088 (DW00)), summary=[incident=66728].
10/10 15:12:26  DW00 started with pid=52, OS id=1860319, wid=2, job ADMIN.IMP_MIGRACAO
10/10 15:12:27  Errors in file /rdsdbdata/log/diag/rdbms/orcl_a/ORCL/trace/ORCL_dw00_1860319.trc  (incident=66588): ORA-00600: internal error code, arguments: [kupdls_rdData-01], [ORA-20
10/10 15:12:27  Incident details in: /rdsdbdata/log/diag/rdbms/orcl_a/ORCL/incident/incdir_66588/ORCL_dw00_1860319_i66588.trc
10/10 15:12:27  Errors in file /rdsdbdata/log/diag/rdbms/orcl_a/ORCL/trace/ORCL_dw00_1860319.trc  (incident=66589): ORA-00600: internal error code, arguments: [kupdls_rdData-01], [ORA-20
10/10 15:12:27  Incident details in: /rdsdbdata/log/diag/rdbms/orcl_a/ORCL/incident/incdir_66589/ORCL_dw00_1860319_i66589.trc
10/10 15:12:28  Dumping diagnostic data in directory=[cdmp_20261010151228], requested by (instance=1, osid=1860319 (DW00)), summary=[incident=66588].
10/10 15:12:28  DW00 terminating with fatal err=600, pid=52, wid=2, job ADMIN.IMP_MIGRACAO
10/10 15:12:29  Dumping diagnostic data in directory=[cdmp_20261010151229], requested by (instance=1, osid=1860319 (DW00)), summary=[incident=66589].
10/10 15:13:56  DM00 stopped with pid=68, OS id=1860085, job ADMIN.IMP_MIGRACAO

### 3. TRACES DOS WORKERS (ultimas 24h)

--- ORCL_dm00_1860085.trc  (2877 bytes, 10/10 15:13) ---

--- ORCL_dw00_1860319.trc  (2385 bytes, 10/10 15:12) ---
  ORA-00600: internal error code, arguments: [kupdls_rdData-01], [ORA-20900: RDS does not support Data Pump import of table data into the SYS schema.
  ORA-06512: at "SYS.RDS_SYS_PUB_UTIL", line 42
  ORA-00600: internal error code, arguments: [kupdls_rdData-01], [ORA-20900: RDS does not support Data Pump import of table data into the SYS schema.
  ORA-06512: at "SYS.RDS_SYS_PUB_UTIL", line 42
  ORA-06512: at "SYS.KUPD$DATA_INT", line 1384
  ORA-06512: at "SYS.KUPD$DATA", line 5172
  ORA-06512: at "SYS.KUPD$DATA", line 7120
  ORA-06512: at "SYS.KUPW$WORKER", line 23059
  ORA-06512: at "SYS.KUPW$WORKER", line 5735
  ORA-06512: at "SYS.KUPW$WORKER", line 13805
  ORA-06512: at "SYS.KUPW$WORKER", line 2439
  ORA-06512: at line 2

--- ORCL_dw00_1860088.trc  (2387 bytes, 10/10 15:12) ---
  ORA-00600: internal error code, arguments: [kupdls_rdData-01], [ORA-20900: RDS does not support Data Pump import of table data into the SYS schema.
  ORA-06512: at "SYS.RDS_SYS_PUB_UTIL", line 42
  ORA-00600: internal error code, arguments: [kupdls_rdData-01], [ORA-20900: RDS does not support Data Pump import of table data into the SYS schema.
  ORA-06512: at "SYS.RDS_SYS_PUB_UTIL", line 42
  ORA-06512: at "SYS.KUPD$DATA_INT", line 1384
  ORA-06512: at "SYS.KUPD$DATA", line 5172
  ORA-06512: at "SYS.KUPD$DATA", line 7120
  ORA-06512: at "SYS.KUPW$WORKER", line 23059
  ORA-06512: at "SYS.KUPW$WORKER", line 5735
  ORA-06512: at "SYS.KUPW$WORKER", line 13805
  ORA-06512: at "SYS.KUPW$WORKER", line 2439
  ORA-06512: at line 2

### 4. MEMORIA (MB)
   Buffer Cache Size            9952
   Shared Pool Size             1600
   Large Pool Size                32
   Streams Pool Size              64
   Maximum SGA Size            11680
   streams_pool_size               0
   sga_target                 11680M
   memory_target                   0
   pga_aggregate_target     1992585K

### 5. ESPACO
   Arquivos no DATA_PUMP_DIR (MB):        11271
   Datafiles do banco (MB):              3705
   MGMT_AD4J_TS                         100 MB
   MGMT_ECM_DEPOT_TS                    100 MB
   MGMT_TABLESPACE                      100 MB
   TEMP                                   - MB
   USERS                                400 MB

### 6. O QUE JA FOI IMPORTADO
   A20140070                 objetos=0  tabelas=0  MB=0  colunas XMLTYPE=0
   A236951                   objetos=0  tabelas=0  MB=0  colunas XMLTYPE=0
   A238967                   objetos=0  tabelas=0  MB=0  colunas XMLTYPE=0
   A238968                   objetos=0  tabelas=0  MB=0  colunas XMLTYPE=0
   EA20140061                objetos=0  tabelas=0  MB=0  colunas XMLTYPE=0
   EA237638                  objetos=0  tabelas=0  MB=0  colunas XMLTYPE=0
   EA266692T1                objetos=0  tabelas=0  MB=0  colunas XMLTYPE=0
   EC880905T1                objetos=0  tabelas=0  MB=0  colunas XMLTYPE=0

### 7. VERSAO
   Oracle Database 19c Standard Edition 2 Release 19.0.0.0.0 - Production Version 19.32.0.0.0

################################################################
###                     VEREDITO                             ###
################################################################

CAUSA: ERRO INTERNO DO ORACLE (ORA-00600/07445) no processo do Data Pump.

O QUE FAZER: NAO tente de novo do mesmo jeito, vai dar o mesmo erro.
             Mande este arquivo para o Gustavo.

################################################################

================================================================
Leia o VEREDITO acima. Ele diz o que fazer.
(tudo tambem ficou salvo em diagnostico_resultado.txt)
================================================================
SQL>

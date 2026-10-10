-- =====================================================================
--  99 - DIAGNOSTICO do import (nao altera nada, so le)
--  Rodar com:  @99_diagnostico.sql
--  Depois mande o arquivo diagnostico_resultado.txt para o Gustavo.
-- =====================================================================
@@00_config.sql
SPOOL diagnostico_resultado.txt

PROMPT
PROMPT ================================================================
PROMPT  99 - DIAGNOSTICO DO IMPORT (so leitura, nao altera nada)
PROMPT ================================================================
PROMPT

-- ---------------------------------------------------------------
-- 1) Log do import: fases e contexto da falha
-- ---------------------------------------------------------------
DECLARE
  TYPE t_linhas IS TABLE OF VARCHAR2(4000);
  l       t_linhas;
  v_first NUMBER;

  PROCEDURE p(t VARCHAR2) IS BEGIN DBMS_OUTPUT.PUT_LINE(t); END;
BEGIN
  BEGIN
    SELECT text BULK COLLECT INTO l
      FROM TABLE(rdsadmin.rds_file_util.read_text_file('&DP_DIR', '&LOG_IMP'));
  EXCEPTION WHEN OTHERS THEN
    p('[ERRO] Nao consegui ler o &LOG_IMP: ' || SQLERRM);
    RETURN;
  END;

  p('### 1. LOG DO IMPORT (' || l.COUNT || ' linhas)');
  p('');
  p('--- inicio do log ---');
  FOR i IN 1 .. LEAST(8, l.COUNT) LOOP
    p('[' || i || '] ' || SUBSTR(l(i), 1, 190));
  END LOOP;

  p('');
  p('--- fases executadas ---');
  FOR i IN 1 .. l.COUNT LOOP
    IF l(i) LIKE 'Processing object type%' THEN
      p('[' || i || '] ' || SUBSTR(l(i), 1, 190));
    END IF;
  END LOOP;

  FOR i IN 1 .. l.COUNT LOOP
    IF l(i) LIKE '%ORA-31671%' OR l(i) LIKE '%ORA-39029%' OR l(i) LIKE '%ORA-39014%' THEN
      v_first := i;
      EXIT;
    END IF;
  END LOOP;

  p('');
  IF v_first IS NOT NULL THEN
    p('--- contexto da primeira queda do worker (linha ' || v_first || ') ---');
    FOR i IN GREATEST(1, v_first - 40) .. LEAST(l.COUNT, v_first + 40) LOOP
      p('[' || i || '] ' || SUBSTR(l(i), 1, 190));
    END LOOP;
  ELSE
    p('(nao achei queda de worker no log)');
  END IF;

  p('');
  p('--- ultimas 15 linhas ---');
  FOR i IN GREATEST(1, l.COUNT - 14) .. l.COUNT LOOP
    p('[' || i || '] ' || SUBSTR(l(i), 1, 190));
  END LOOP;
END;
/

-- ---------------------------------------------------------------
-- 2) Alert log das ultimas 24h
-- ---------------------------------------------------------------
DECLARE
  PROCEDURE p(t VARCHAR2) IS BEGIN DBMS_OUTPUT.PUT_LINE(t); END;
BEGIN
  p('');
  p('### 2. ALERT LOG (erros das ultimas 24h, no maximo 80 linhas)');
  p('');
  FOR r IN (SELECT * FROM (
              SELECT originating_timestamp ts, message_text
                FROM alertlog
               WHERE originating_timestamp > SYSTIMESTAMP - INTERVAL '1' DAY
                 AND (   message_text LIKE '%ORA-%'
                      OR message_text LIKE '%Errors in file%'
                      OR message_text LIKE '%Incident%'
                      OR message_text LIKE '%DW0%'
                      OR message_text LIKE '%DM0%')
               ORDER BY originating_timestamp DESC)
             WHERE ROWNUM <= 80
             ORDER BY ts) LOOP
    p(TO_CHAR(r.ts, 'DD/MM HH24:MI:SS') || '  ' || SUBSTR(REPLACE(r.message_text, CHR(10), ' '), 1, 170));
  END LOOP;
EXCEPTION WHEN OTHERS THEN
  p('(nao consegui ler o alert log: ' || SQLERRM || ')');
END;
/

-- ---------------------------------------------------------------
-- 3) Trace dos workers do Data Pump (DW00)
-- ---------------------------------------------------------------
DECLARE
  v_n      NUMBER;
  v_depois NUMBER;
  PROCEDURE p(t VARCHAR2) IS BEGIN DBMS_OUTPUT.PUT_LINE(t); END;
BEGIN
  p('');
  p('### 3. TRACES DOS WORKERS (ultimas 24h)');
  FOR f IN (SELECT * FROM (
              SELECT filename, filesize, mtime
                FROM TABLE(rdsadmin.rds_file_util.listdir('BDUMP'))
               WHERE (LOWER(filename) LIKE '%dw0%.trc' OR LOWER(filename) LIKE '%dm0%.trc')
                 AND mtime > SYSDATE - 1
               ORDER BY mtime DESC)
             WHERE ROWNUM <= 3) LOOP
    p('');
    p('--- ' || f.filename || '  (' || f.filesize || ' bytes, ' || TO_CHAR(f.mtime, 'DD/MM HH24:MI') || ') ---');
    v_n := 0;
    v_depois := 0;
    FOR r IN (SELECT text FROM TABLE(rdsadmin.rds_file_util.read_text_file('BDUMP', f.filename))) LOOP
      IF r.text LIKE '%ORA-%' OR r.text LIKE '%Current SQL%' OR r.text LIKE '%KUPW%object%'
         OR r.text LIKE '%table_name%' OR r.text LIKE '%TABLE%' AND r.text LIKE '%"%' THEN
        p('  ' || SUBSTR(r.text, 1, 190));
        v_n := v_n + 1;
        IF r.text LIKE '%Current SQL%' THEN v_depois := 3; END IF;
      ELSIF v_depois > 0 THEN
        p('  ' || SUBSTR(r.text, 1, 190));
        v_depois := v_depois - 1;
        v_n := v_n + 1;
      END IF;
      EXIT WHEN v_n >= 60;
    END LOOP;
  END LOOP;
EXCEPTION WHEN OTHERS THEN
  p('(nao consegui ler os traces: ' || SQLERRM || ')');
END;
/

-- ---------------------------------------------------------------
-- 4) Memoria, espaco e o que ja foi importado
-- ---------------------------------------------------------------
DECLARE
  v_mb NUMBER;
  PROCEDURE p(t VARCHAR2) IS BEGIN DBMS_OUTPUT.PUT_LINE(t); END;
BEGIN
  p('');
  p('### 4. MEMORIA (MB)');
  FOR r IN (SELECT name, ROUND(bytes / 1024 / 1024) mb FROM v$sgainfo
             WHERE name IN ('Maximum SGA Size', 'Shared Pool Size', 'Streams Pool Size',
                            'Buffer Cache Size', 'Large Pool Size')) LOOP
    p('   ' || RPAD(r.name, 25) || LPAD(r.mb, 8));
  END LOOP;
  FOR r IN (SELECT name, display_value FROM v$parameter
             WHERE name IN ('sga_target', 'memory_target', 'pga_aggregate_target', 'streams_pool_size')) LOOP
    p('   ' || RPAD(r.name, 25) || LPAD(NVL(r.display_value, '-'), 8));
  END LOOP;

  p('');
  p('### 5. ESPACO');
  SELECT ROUND(SUM(filesize) / 1024 / 1024) INTO v_mb
    FROM TABLE(rdsadmin.rds_file_util.listdir('&DP_DIR'));
  p('   Arquivos no &DP_DIR (MB):        ' || v_mb);
  SELECT ROUND(SUM(bytes) / 1024 / 1024) INTO v_mb FROM dba_data_files;
  p('   Datafiles do banco (MB):              ' || v_mb);
  FOR r IN (SELECT m.tablespace_name,
                   (SELECT ROUND(SUM(bytes) / 1024 / 1024) FROM dba_data_files d
                     WHERE d.tablespace_name = m.tablespace_name) usado_mb
              FROM mig_tablespaces m ORDER BY 1) LOOP
    p('   ' || RPAD(r.tablespace_name, 30) || LPAD(NVL(TO_CHAR(r.usado_mb), '-'), 10) || ' MB');
  END LOOP;

  p('');
  p('### 6. O QUE JA FOI IMPORTADO');
  FOR s IN (SELECT m.username,
                   (SELECT COUNT(*) FROM dba_objects o WHERE o.owner = m.username) objs,
                   (SELECT COUNT(*) FROM dba_tables t WHERE t.owner = m.username) tabs,
                   (SELECT ROUND(SUM(bytes) / 1024 / 1024) FROM dba_segments g WHERE g.owner = m.username) mb,
                   (SELECT COUNT(*) FROM dba_tab_cols c WHERE c.owner = m.username AND c.data_type = 'XMLTYPE') xmlcols
              FROM mig_schemas m WHERE m.importar = 'S' ORDER BY 1) LOOP
    p('   ' || RPAD(s.username, 25) || ' objetos=' || s.objs || '  tabelas=' || s.tabs ||
      '  MB=' || NVL(s.mb, 0) || '  colunas XMLTYPE=' || s.xmlcols);
  END LOOP;

  p('');
  p('### 7. VERSAO');
  FOR r IN (SELECT banner_full FROM v$version) LOOP
    p('   ' || REPLACE(r.banner_full, CHR(10), ' '));
  END LOOP;
END;
/

-- ---------------------------------------------------------------
-- 8) VEREDITO: o que aconteceu e o que fazer
-- ---------------------------------------------------------------
DECLARE
  v_mem    BOOLEAN := FALSE;
  v_disco  BOOLEAN := FALSE;
  v_temp   BOOLEAN := FALSE;
  v_bug    BOOLEAN := FALSE;
  v_proc   BOOLEAN := FALSE;
  v_xml    NUMBER  := 0;
  v_n      NUMBER;

  PROCEDURE p(t VARCHAR2) IS BEGIN DBMS_OUTPUT.PUT_LINE(t); END;

  PROCEDURE analisa(t VARCHAR2) IS
  BEGIN
    IF t IS NULL THEN RETURN; END IF;
    IF t LIKE '%ORA-04031%' OR t LIKE '%ORA-04030%' OR t LIKE '%ORA-04036%' THEN v_mem := TRUE; END IF;
    IF REGEXP_LIKE(t, 'ORA-(01653|01654|01658|01659|01688|01691|01144|19502|27072|01237)')
       OR LOWER(t) LIKE '%no space left%' THEN v_disco := TRUE; END IF;
    IF t LIKE '%ORA-01652%' THEN v_temp := TRUE; END IF;
    IF t LIKE '%ORA-00600%' OR t LIKE '%ORA-07445%' THEN v_bug := TRUE; END IF;
    IF t LIKE '%ORA-00018%' OR t LIKE '%ORA-00020%' THEN v_proc := TRUE; END IF;
  END;
BEGIN
  -- log do import
  BEGIN
    FOR r IN (SELECT text FROM TABLE(rdsadmin.rds_file_util.read_text_file('&DP_DIR', '&LOG_IMP'))
               WHERE text LIKE '%ORA-%' OR LOWER(text) LIKE '%space%') LOOP
      analisa(r.text);
    END LOOP;
  EXCEPTION WHEN OTHERS THEN NULL;
  END;

  -- alert log
  BEGIN
    FOR r IN (SELECT message_text FROM alertlog
               WHERE originating_timestamp > SYSTIMESTAMP - INTERVAL '1' DAY
                 AND (message_text LIKE '%ORA-%' OR LOWER(message_text) LIKE '%space%')) LOOP
      analisa(r.message_text);
    END LOOP;
  EXCEPTION WHEN OTHERS THEN NULL;
  END;

  -- traces dos workers
  BEGIN
    FOR f IN (SELECT filename FROM TABLE(rdsadmin.rds_file_util.listdir('BDUMP'))
               WHERE (LOWER(filename) LIKE '%dw0%.trc' OR LOWER(filename) LIKE '%dm0%.trc')
                 AND mtime > SYSDATE - 1) LOOP
      v_n := 0;
      FOR r IN (SELECT text FROM TABLE(rdsadmin.rds_file_util.read_text_file('BDUMP', f.filename))) LOOP
        IF r.text LIKE '%ORA-%' THEN analisa(r.text); END IF;
        v_n := v_n + 1;
        EXIT WHEN v_n >= 20000;
      END LOOP;
    END LOOP;
  EXCEPTION WHEN OTHERS THEN NULL;
  END;

  BEGIN
    SELECT COUNT(*) INTO v_xml FROM dba_tab_cols c JOIN mig_schemas m ON m.username = c.owner
     WHERE m.importar = 'S' AND c.data_type = 'XMLTYPE';
  EXCEPTION WHEN OTHERS THEN NULL;
  END;

  p('');
  p('################################################################');
  p('###                     VEREDITO                             ###');
  p('################################################################');
  p('');

  IF v_mem THEN
    p('CAUSA: FALTA DE MEMORIA no RDS (ORA-04031/04030).');
    p('       A instancia e pequena demais para o Data Pump.');
    p('');
    p('O QUE FAZER:');
    p('  1. Console AWS > RDS > Databases > t24dev2 > botao Modify');
    p('  2. "DB instance class": escolha uma com pelo menos 8 GB de RAM');
    p('     (ex.: db.m5.large ou db.r5.large). Pode voltar depois da migracao.');
    p('  3. Continue > marque "Apply immediately" > Modify DB instance');
    p('  4. Espere o status voltar para "Available" (uns 10-20 min)');
    p('  5. No SQL*Plus:  @98_reset_import.sql   (digite APAGAR)');
    p('  6. Depois:       @04_importar.sql       (digite SIM)');
    p('');
  END IF;

  IF v_disco THEN
    p('CAUSA: FALTA DE ESPACO EM DISCO no RDS.');
    p('');
    p('O QUE FAZER:');
    p('  1. No SQL*Plus:  @07_limpeza.sql  e apague os duplicados (libera uns 8 GB)');
    p('     (na segunda pergunta, NAO apague o FULLDB.dmp)');
    p('  2. Console AWS > RDS > t24dev2 > Modify > "Allocated storage":');
    p('     aumente para pelo menos 3x o tamanho do dump (ex.: +50 GB)');
    p('     > marque "Apply immediately" > Modify DB instance');
    p('  3. Espere o status voltar para "Available"');
    p('  4. No SQL*Plus:  @98_reset_import.sql   (digite APAGAR)');
    p('  5. Depois:       @04_importar.sql       (digite SIM)');
    p('');
  END IF;

  IF v_temp AND NOT v_disco THEN
    p('CAUSA: FALTA DE ESPACO TEMPORARIO (ORA-01652), normalmente na criacao de indices.');
    p('');
    p('O QUE FAZER: rode no SQL*Plus:');
    p('  ALTER TABLESPACE temp ADD TEMPFILE SIZE 10G AUTOEXTEND ON;');
    p('  e depois  @98_reset_import.sql  e  @04_importar.sql');
    p('');
  END IF;

  IF v_proc THEN
    p('CAUSA: LIMITE DE PROCESSOS/SESSOES do RDS atingido.');
    p('');
    p('O QUE FAZER: mande este arquivo para o Gustavo (precisa ajustar o parameter group).');
    p('');
  END IF;

  IF v_bug THEN
    p('CAUSA: ERRO INTERNO DO ORACLE (ORA-00600/07445) no processo do Data Pump.');
    IF v_xml > 0 THEN
      p('       O banco tem ' || v_xml || ' colunas XMLTYPE, que sao a causa mais comum disso.');
    END IF;
    p('');
    p('O QUE FAZER: NAO tente de novo do mesmo jeito, vai dar o mesmo erro.');
    p('             Mande este arquivo para o Gustavo.');
    p('');
  END IF;

  IF NOT (v_mem OR v_disco OR v_temp OR v_proc OR v_bug) THEN
    p('CAUSA: nao identificada automaticamente.');
    p('');
    p('O QUE FAZER: mande o arquivo diagnostico_resultado.txt para o Gustavo.');
    p('             NAO rode o 04 de novo antes disso.');
    p('');
  END IF;

  p('################################################################');
END;
/

PROMPT
PROMPT ================================================================
PROMPT  Leia o VEREDITO acima. Ele diz o que fazer.
PROMPT  (tudo tambem ficou salvo em diagnostico_resultado.txt)
PROMPT ================================================================

SPOOL OFF

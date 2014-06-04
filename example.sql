set heading off
set feedback off
set echo off
set pagesize 0
set verify off
set serveroutput on unlimited
set long 2000000000

set serveroutput on unlimited
spool index.html
exec ddd_util.output_text;
spool off
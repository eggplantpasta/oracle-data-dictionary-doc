set heading off
set feedback off
set echo off
set pagesize 0
set verify off
set serveroutput on size unlimited
set trimout on
set trimspool on
set long 2000000000
set longchunksize 2000000000
set linesize 32767
variable x clob
exec :x := ddd_html.test;
spool index.html
print x
spool off
set heading off
set feedback off
set echo off
set pagesize 0
set verify off
set long 2000000000

var x clob

begin
  :x := ddd_html.crate_page;
end;
/

spool index.html
select :x from dual;
spool off

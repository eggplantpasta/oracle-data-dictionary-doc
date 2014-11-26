-- file system access for templates and writing output
create or replace directory ddd_templates as 'C:\gitrepo\oracle-data-dictionary-doc\templates';
create or replace directory ddd_output as 'C:\gitrepo\oracle-data-dictionary-doc\output';

-- db objects
@@ddd_text.sql
@@ddd_util.pks
@@ddd_util.pkb
@@ddd_html.pks
@@ddd_html.pkb

-- data load
@@data.sql
commit;

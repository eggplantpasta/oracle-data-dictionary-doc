oracle-data-dictionary-doc
==========================

Automatic generation of schema documentation using the Oracle data dictionary tables.

## Note

> This personal project is pre-pre-alpha. It's quite fiddly to use and incomplete (not everything you read here exists). Sorry.

## Overview

This PL/SQL package generates database documentation from Oracle data dictionary objects combined with a [mustache](http://mustache.github.io/) template.

See the example [here](http://htmlpreview.github.com/?https://github.com/eggplantpasta/oracle-data-dictionary-doc/blob/master/files/dddexample.html?raw=true).

This project grew out of my need for something simpler with more modern markup than [PLDOC](http://sourceforge.net/projects/pldoc/). I have used only SQL scripts and PL/SQL so it has no requirements outside of database and file system access. The default template output HTML is styled using [Bootstrap 3](http://getbootstrap.com/) for a modern, clean look.

## Quick Start
Copy the contents of the repository /files/* directory (custom.css and ddd.mustache) to the directory corresponding to a database directory object with permissions to read and write.

Create the "ddd" package in the schema you wish to document.
```sql
@ddd.sql
```
Generate the documentation (change 'DDD_DIR below to match your environment').
```sql
exec ddd.document('DDD_DIR');
```
Take a look at the resulting documentation file  ddd.html.

## Acknowledgements

* [PLDOC](http://sourceforge.net/projects/pldoc/) for the inspiration.
* [Bootstrap 3](http://getbootstrap.com/) for the prettiness.
* [StackExchange](http://dba.stackexchange.com/questions/6747/within-a-pl-sql-procedure-wrap-a-query-or-refcursor-in-html-table) for the --cursor to XML to HTML-- method.
* [vagrant-ubuntu-oracle-xe](https://github.com/hilverd/vagrant-ubuntu-oracle-xe) for the development database.
* The Oracle documentation, especially [Oracle Database Reference 11g Release 2 (11.2), Part II, Static Data Dictionary Views](http://docs.oracle.com/cd/E11882_01/server.112/e40402/statviews_part.htm#i125539) for the data dictionary info.

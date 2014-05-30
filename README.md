oracle-data-dictionary-doc
==========================

Automatic generation of schema documentation using the Oracle data dictionary tables.

## Note: this project is pre-pre-alpha. It's quite fiddly to use and incomplete (not everything you read here exists). Sorry.


## Overview

This project grew out of my need for something simpler and more modern than [PLDOC](http://sourceforge.net/projects/pldoc/). I have used only SQL scripts and PL/SQL so it has no requirements outside of database and file system access. The output HTML is styled using [Bootstrap 3](http://getbootstrap.com/) for a modern, clean look.


## Installation

Change into the `sql` directory and run the `build.sql` script. This will create all the database objects required and populate the ddd_text table with initial data.

Populating the CLOB columns of the `ddd_text` table requires different methods. If you have access to a database directory `select * from all_directories;` the quickest method is to use the function `ddd_util.load_text`.

* Copy all files from the templates directory into the database accessible directory.
* Call the procedure `exec ddd_util.load_text('[directory_name]');`.

If you don't have access to a database directory then you can manually load the CLOB data via SQL Developer. Use the `ddd_text.file_name` column value to determine which file's data to load into the CLOB field. Double click the CLOB field you want to populate and then make sure you click the edit button (pencil icon) before you copy/paste the multi line data.


## Usage

To generate documentation for the current (user) schema:

### The input

Use syntax similar to [Javadoc](http://en.wikipedia.org/wiki/Javadoc).

### The output


## Running the examples

### DDD

### HR


## Acknowledgements

[PLDOC](http://sourceforge.net/projects/pldoc/) for the inspiration.
[Bootstrap 3](http://getbootstrap.com/) for the prettiness.
[StackExchange](http://dba.stackexchange.com/questions/6747/within-a-pl-sql-procedure-wrap-a-query-or-refcursor-in-html-table) for the --cursor to XML to HTML-- method.
[GitHub](https://github.com/hilverd/vagrant-ubuntu-oracle-xe) for the development database.

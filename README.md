oracle-data-dictionary-doc
==========================

Automatic generation of schema documentation using the Oracle data dictionary tables.

## Note

This personal project is pre-pre-alpha. It's quite fiddly to use and incomplete (not everything you read here exists). Sorry.

## Overview

This project grew out of my need for something simpler with more modern markup than [PLDOC](http://sourceforge.net/projects/pldoc/). I have used only SQL scripts and PL/SQL so it has no requirements outside of database and file system access. The output HTML is styled using [Bootstrap 3](http://getbootstrap.com/) for a modern, clean look.


## Installation

### Prerequisites

This project needs access to the schema objects being documented. It can be created in the same schema as the one being documented as it excludes it's own objects by default.

What ever schema is used for this project will require access to the filesystem as it uses UTL_FILE for reading templates and writing the documentation.

### Creating the database objects

Change into this project's `sql` directory and run the `build.sql` script. This will create all the database objects required and populate the ddd_text table with initial data.

Populating the CLOB columns of the `ddd_text` table requires different methods. If you have access to a database directory or can create one `create or replace directory ddd_dir as '/vagrant';` the quickest method is to use the function `ddd_util.load_text('ddd_dir')`.

* If required, create a database directory object e.g. `create or replace directory ddd_dir as '/vagrant';`
* Grant permissions to the schema that contains the ddd objects `grant read on directory ddd_dir to hr;`.
* Copy all files from the templates directory into the database accessible directory.
* Call the procedure `exec ddd_util.load_text('[ddd_dir]');`.

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

* [PLDOC](http://sourceforge.net/projects/pldoc/) for the inspiration.
* [Bootstrap 3](http://getbootstrap.com/) for the prettiness.
* [StackExchange](http://dba.stackexchange.com/questions/6747/within-a-pl-sql-procedure-wrap-a-query-or-refcursor-in-html-table) for the --cursor to XML to HTML-- method.
* [vagrant-ubuntu-oracle-xe](https://github.com/hilverd/vagrant-ubuntu-oracle-xe) for the development database.
* The Oracle documentation, especially [Oracle Database Reference 11g Release 2 (11.2), Part II, Static Data Dictionary Views](http://docs.oracle.com/cd/E11882_01/server.112/e40402/statviews_part.htm#i125539) for the data dictionary info.
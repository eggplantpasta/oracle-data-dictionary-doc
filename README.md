oracle-data-dictionary-doc
==========================

Automatic generation of schema documentation using the Oracle data dictionary tables.

## Note

> This personal project is pre-pre-alpha. It's quite fiddly to use and incomplete (not everything you read here exists). Sorry.

## Overview

This project grew out of my need for something simpler with more modern markup than [PLDOC](http://sourceforge.net/projects/pldoc/). I have used only SQL scripts and PL/SQL so it has no requirements outside of database and file system access. The default template output HTML is styled using [Bootstrap 3](http://getbootstrap.com/) for a modern, clean look.

## Usage

### Prerequisites

This package needs access to the schema objects being documented. It can be created in the same schema as the one being documented as it excludes it's own objects by default. The example installation below assumes the package is being created in the Oracle example schema 'HR'.

### Usage

To generate documentation for the current schema:
```sql
begin
  ddd.document(
    p_directory => 'ddd_dir'
  );
end;
/
```

### Installation
The schema is used for this package will require access to the filesystem as it needs to read templates and write output files.

* If required, create a database directory object e.g.
```sql
create or replace directory ddd_dir as '\git\oracle-data-dictionary-doc\files';
```
* Grant permissions on the directory to the schema that contains the ddd objects.
```sql
grant read, write on directory ddd_dir to hr;
```
* Copy all files from the repositoriy's oracle-data-dictionary-doc\files directory into the database accessible directory.
* Call the procedure `exec ddd_util.load_text('[ddd_dir]');`.

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

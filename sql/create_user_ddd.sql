-- use if creating package and directory in a separate schema to the one being documented
-- modify as appropriate for your environment

-- start run as as privileged user e.g. system
create user ddd identified by ddd;
grant connect, resource to ddd;
grant create database link, create procedure to ddd;
grant create any directory to ddd; -- allows user to read and write to the filesystem of the db server
grant select any dictionary to ddd; -- allows user to select from dba_* tables

-- connection to our newly created user to create the package and directory
connect ddd/ddd@xe;
create or replace directory ddd_files as 'C:\gitrepo\oracle-data-dictionary-doc\files';
@ddd.sql

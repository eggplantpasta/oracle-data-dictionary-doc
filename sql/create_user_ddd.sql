-- run as privileged user e.g. system
create user ddd identified by ddd;
grant connect, resource to ddd;
grant create database link, create procedure, create table to ddd;
grant create any directory to ddd; -- allows user to read and write to the filesystem of the db server
grant select any dictionary to ddd; -- allows user to select from dba_<tablename>


-- run from the command line in the same directory as files e.g.:
-- [path]sqlldr.exe userid=[user]/[password]@[sid] control=ddd_text.ctl log=ddd_text.log bad=ddd_text.bad
-- use the following sql to select data for the csv
-- select text_type, text_name, description, filename from ddd_text;
load data
infile 'ddd_text.csv'
truncate
into table ddd_text
fields terminated by ',' optionally enclosed by '"'
(   text_type    char(50),
    text_name    char(50),
    description  char(500),
    filename     char(50),
    text         lobfile(filename) terminated by eof
)
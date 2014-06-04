rem inserting into ddd_text
set define off;

-- ignore errors for data already in table
insert into ddd_text (text_type,text_name,description,filename) values ('html','page-template',null,'page-template.html');
insert into ddd_text (text_type,text_name,description,filename) values ('html','overview','EDIT THIS. The overview text in the file overview.html should be replaced with text relevant to the schema being documented.','overview.html');

insert into ddd_text (text_type,text_name,description,filename) values ('xsl','html-table',null,'html-table.xsl');
insert into ddd_text (text_type,text_name,description,filename) values ('xsl','html-dl',null,'html-dl.xsl');

insert into ddd_text (text_type,text_name,description,filename) values ('text','pagetitle','EDIT THIS. Optional. Schema name used if null.',null);
insert into ddd_text (text_type,text_name,description,filename) values ('text','headtitle','EDIT THIS. Optional. Schema name used if null.',null);
insert into ddd_text (text_type,text_name,description,filename) values ('text','object-like','EDIT THIS. Optional. All objects documented if null.',null);

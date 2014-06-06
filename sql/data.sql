rem inserting into ddd_text
set define off;

-- ignore errors for data already in table
insert into ddd_text (text_type,text_name,description,filename) values ('html','page-head',null,'page-head.html');
insert into ddd_text (text_type,text_name,description,filename) values ('html','page-foot',null,'page-foot.html');
insert into ddd_text (text_type,text_name,description,filename) values ('html','overview-intro','The overview text in the file overview.html should be replaced with text relevant to the schema being documented.','overview-intro.html');
insert into ddd_text (text_type,text_name,description,filename) values ('html','data-intro','The overview text in the file overview.html should be replaced with text relevant to the schema being documented.','data-intro.html');
insert into ddd_text (text_type,text_name,description,filename) values ('html','code-intro','The overview text in the file overview.html should be replaced with text relevant to the schema being documented.','code-intro.html');

insert into ddd_text (text_type,text_name,description,filename) values ('xsl','html-table',null,'html-table.xsl');
insert into ddd_text (text_type,text_name,description,filename) values ('xsl','html-dl',null,'html-dl.xsl');

insert into ddd_text (text_type,text_name,description,filename) values ('text','pagetitle','Optional. Schema name used if null.',null);
insert into ddd_text (text_type,text_name,description,filename) values ('text','headtitle','Optional. Schema name used if null.',null);
insert into ddd_text (text_type,text_name,description,filename) values ('text','object-regexp-like','Optional. All objects documented if null.',null);
insert into ddd_text (text_type,text_name,description,filename) values ('text','object-not-regexp-like','Optional. All objects documented if null.',null);

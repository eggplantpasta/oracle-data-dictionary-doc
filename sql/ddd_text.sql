create table ddd_text
(
    text_type varchar2(50) not null,
    text_name varchar2(50) not null,
    description varchar2(500),
    filename varchar2(50),
    text clob,

    constraint pk_ddd_text primary key (text_type, text_name)
);

-- documentation in comments
comment on table ddd_text is 'Boilerplate text, xsl, and templates required for constructing documentation.';

comment on column ddd_text.text_type is 'Type of text data, used for grouping.';
comment on column ddd_text.text_name is 'Name of this instance of text, unique within text type.';
comment on column ddd_text.description is 'Optional description of the data.';
comment on column ddd_text.filename is 'Filename (and path) if loaded from external file.';
comment on column ddd_text.text is 'The text.';

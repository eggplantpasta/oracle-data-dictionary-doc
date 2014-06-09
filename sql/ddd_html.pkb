create or replace
package body ddd_html is

/* All object_types from view all_objects

Documented
<data> in ('TABLE', 'VIEW', 'MATERIALIZED VIEW')

<code> in ('PROCEDURE', 'FUNCTION', 'PACKAGE')

Not documented (yet?)
'NEXT OBJECT', 'INDEX', 'CLUSTER', 'SYNONYM', 'SEQUENCE', 'TRIGGER', 'PACKAGE BODY', 'TYPE', 'TYPE BODY', 'TABLE PARTITION', 'INDEX PARTITION', 'LOB', 'LIBRARY', 'DIRECTORY', 'QUEUE', 'JAVA SOURCE', 'JAVA CLASS', 'JAVA RESOURCE', 'INDEXTYPE', 'OPERATOR', 'TABLE SUBPARTITION', 'INDEX SUBPARTITION', 'LOB PARTITION', 'LOB SUBPARTITION', 'REWRITE EQUIVALENCE', 'DIMENSION', 'CONTEXT', 'RULE SET', 'RESOURCE PLAN', 'CONSUMER GROUP', 'XML SCHEMA', 'JAVA DATA', 'EDITION', 'RULE', 'CAPTURE', 'APPLY', 'EVALUATION CONTEXT', 'JOB', 'PROGRAM', 'JOB CLASS', 'WINDOW', 'SCHEDULER GROUP', 'SCHEDULE', 'CHAIN', 'FILE GROUP', 'MINING MODEL', 'ASSEMBLY', 'CREDENTIAL', 'CUBE DIMENSION', 'CUBE', 'MEASURE FOLDER', 'CUBE BUILD PROCESS', 'FILE WATCHER', 'DESTINATION', 'UNDEFINED'

*/

-------------------------------------------------------------------------------
-- PRVATE
-------------------------------------------------------------------------------

  function get_text(
    p_text_type    in ddd_text.text_type%type
  , p_text_name    in ddd_text.text_name%type
  , p_text_default in ddd_text.text_name%type default null
  ) return clob is
    l_retval clob;
    l_cursor sys_refcursor;
  begin
    open l_cursor for
      select text from ddd_text
      where text_type = p_text_type
      and text_name = p_text_name;
    fetch l_cursor into l_retval;
    close l_cursor;

    if l_retval is null or dbms_lob.getlength(l_retval) = 0 then
      l_retval := p_text_default;
    end if;

    return l_retval;
  end get_text;

  -- replace the first occourance of variable with text
  function text_replace (
    p_template     in ddd_text.text%type
  , p_variable     in varchar2
  , p_text         in ddd_text.text%type
  ) return clob is
    l_retval      clob := p_template;
    l_html_escape boolean;
  begin
    -- TODO replace with functions that can deal with > 32k
    l_html_escape := substr(p_variable, 3, 1) != '{';
    if l_html_escape then
      l_retval := replace(l_retval, p_variable, p_text); -- TODO escape l_text
    else
      l_retval := replace(l_retval, p_variable, p_text);
    end if;

    return l_retval;
  end text_replace;


  -- replace the first occourance of variable with text
  function get_text_replace (
    p_template     in ddd_text.text%type
  , p_variable     in varchar2
  , p_replace_null in boolean default true
  , p_text_default in ddd_text.text_name%type default null
  ) return clob is

    l_retval      clob;
    l_text_name   ddd_text.text_name%type;
    l_text        ddd_text.text%type;

  begin
    l_retval := p_template;
    l_text_name := regexp_substr(p_variable, '({{)([{]?)(.*[^}])([}]?)(}})', 1, 1, 'c', 3);
    l_text := get_text('text', l_text_name);

    -- default text if required
    l_text := nvl(l_text, p_text_default);

    if l_text is not null or p_replace_null then
      l_retval := text_replace(l_retval, p_variable, l_text);
    end if;

    return l_retval;
  end get_text_replace;

  function get_template_replace_all(
    p_text_name in ddd_text.text_name%type
  ) return clob is
    l_retval      clob;
    l_temp        clob;
    l_text        ddd_text.text%type;
    l_text_name   ddd_text.text_name%type;
    l_variable    varchar2(512);
  begin
    -- fetch the template
    l_temp := get_text('template', p_text_name);
    l_retval := l_temp;

    -- attempt a replace of all variables. ignore ones not don't exist in
    -- table ddd_text
    for i in 1 .. (regexp_count(l_temp, '({{)([{]?)(.*[^}])([}]?)(}})')) loop
      -- get the variable name
      l_variable := regexp_substr(l_temp, '({{)([{]?)(.*[^}])([}]?)(}})', 1, i);
      l_retval := get_text_replace(l_retval, l_variable, false);
    end loop;

    -- return the result
    return l_retval;
  end get_template_replace_all;


-------------------------------------------------------------------------------
-- PUBLIC
-------------------------------------------------------------------------------

  function create_page return clob is
    l_retval                 clob;
    l_fragment               clob;
    l_object_regexp_like     clob := get_text('text', 'object-regexp-like', '.*');
    l_object_not_regexp_like clob := get_text('text', 'object-not-regexp-like', '^$');
  begin
    l_retval := get_template_replace_all('page');

    l_retval := get_text_replace(l_retval, '{{long-title}}', true, user || ' schema docs');
    l_retval := get_text_replace(l_retval, '{{short-title}}', true, user);

    for r in (
      select owner, object_type, object_name
      from all_objects
      where object_type in ('TABLE', 'VIEW', 'MATERIALIZED VIEW')
      and owner = user
      and regexp_like (object_name, l_object_regexp_like)
      and not regexp_like (object_name, l_object_not_regexp_like)
      order by owner, object_type, object_name
    ) loop
      l_fragment := l_fragment || table_doc(r.object_name, r.object_type);
    end loop;
    l_retval := text_replace(l_retval, '{{{data-objects}}}', l_fragment);

    return l_retval;
  end create_page;


  function table_doc(
    p_object_name in user_objects.object_name%type
  , p_object_type in user_objects.object_type%type
  ) return clob is
    l_retval   clob;
    c          sys_refcursor;
    l_comments user_tab_comments.comments%type;

  begin

    open c for select comments from user_tab_comments where table_name = p_object_name and table_type = p_object_type;
    fetch c into l_comments;
    close c;

    l_retval := l_retval ||
      '<h3 name="' || lower(p_object_name) || '-' || lower(p_object_type) || '">' ||
      lower(p_object_name) || ' <small>' || lower(p_object_type) || '</small></h3>' ||
      '<p>' || l_comments || '</p>';

    open c for
      select
        '<span class="nowrap">' ||
        lower(t.column_name) ||
        '</span>' "Column_Name",
        '<span class="nowrap">' ||
        lower(t.data_type) ||
        decode(t.data_type,
          'CHAR',      '('|| t.char_length ||')',
          'VARCHAR',   '('|| t.char_length ||')',
          'VARCHAR2',  '('|| t.char_length ||')',
          'NCHAR',     '('|| t.char_length ||')',
          'NVARCHAR',  '('|| t.char_length ||')',
          'NVARCHAR2', '('|| t.char_length ||')',
          'NUMBER',    '('||
          nvl(t.data_precision,t.data_length)||
               decode(t.data_scale,null,null,
                      ', '||t.data_scale)||')',
          null) ||
        '</span>' "Type",
        '<span class="nowrap">' ||
          (
            select decode(ic.column_position, null, null, '<abbr title="primary key" class="badge pk">PK'|| ic.column_position ||'</abbr>')
            from user_ind_columns ic, user_constraints ac
            where ac.constraint_type = 'P'
            and ic.index_name = ac.index_name
            and ic.table_name = ac.table_name
            and ic.table_name = c.table_name
            and ic.column_name = c.column_name
          ) ||
        decode(t.nullable, 'N', ' <abbr title="not null" class="badge">NN</abbr>') ||
        '</span>' "_",
        c.comments "Comments"
       from user_tab_columns t, user_col_comments c
      where t.table_name = p_object_name
        and t.table_name = c.table_name
        and t.column_name = c.column_name
      order by t.column_id
      ;
    l_retval := l_retval || cursor2table(c, 'table table-hover table-condensed');

    return l_retval;
  end table_doc;


  function cursor2table(
    p_rf       sys_refcursor
  , p_class   in varchar2 default null
  , p_caption in varchar2 default null
  ) return clob is

      l_retval      clob;
      l_htmloutput  xmltype;
      l_xsl         clob;
      l_xmldata     xmltype;
      l_context     dbms_xmlgen.ctxhandle;

  begin

      -- get a handle on the ref cursor
      l_context := dbms_xmlgen.newcontext(p_rf);
      -- setnullhandling to 1 (or 2) to allow null columns to be displayed
      dbms_xmlgen.setnullhandling(l_context,1);
      -- create xml from ref cursor
      l_xmldata := dbms_xmlgen.getxmltype(l_context,dbms_xmlgen.none);

      -- this is a generic XSL for Oracle's default XML row and rowset tags
      l_xsl := get_text('xsl', 'html-table');

      -- table classes and caption
      if p_class is not null then
          l_xsl := replace(l_xsl, '<table>', '<table class="' || p_class || '">');
      end if;
      if p_caption is not null then
          l_xsl := replace(l_xsl, '<thead>', '<caption>' || p_caption || '</caption><thead>');
      end if;

      -- xsl transformation to convert xml to html
      l_htmloutput := l_xmldata.transform(xmltype(l_xsl));
      -- convert xmltype to clob
      l_retval := l_htmloutput.getclobval();

      return l_retval;

  end cursor2table;


  function cursor2dl(
    p_rf       sys_refcursor
  , p_class   in varchar2 default null
  ) return clob is

      l_retval      clob;
      l_htmloutput  xmltype;
      l_xsl         clob;
      l_xmldata     xmltype;
      l_context     dbms_xmlgen.ctxhandle;

  begin

      -- get a handle on the ref cursor
      l_context := dbms_xmlgen.newcontext(p_rf);
      -- setnullhandling to 1 (or 2) to allow null columns to be displayed
      dbms_xmlgen.setnullhandling(l_context,1);
      -- create xml from ref cursor --
      l_xmldata := dbms_xmlgen.getxmltype(l_context,dbms_xmlgen.none);

      l_xsl := get_text('xsl', 'html-dl');

      -- dl classes
      if p_class is not null then
          l_xsl := replace(l_xsl, '<dl>', '<dl class="' || p_class || '">');
      end if;

      -- xsl transformation to convert xml to html
      l_htmloutput := l_xmldata.transform(xmltype(l_xsl));
      -- convert xmltype to clob
      l_retval := l_htmloutput.getclobval();

      return l_retval;

  end cursor2dl;


end ddd_html;
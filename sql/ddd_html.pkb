create or replace
package body ddd_html is

    function crate_page return clob is
      l_retval clob;
      l_text clob;
      l_body clob;
    begin
      -- get the template
      l_retval := ddd_util.get_text('html', 'page-template');

      -- replace placeholders
      l_text := ddd_util.get_text('text', 'pagetitle', user || ' schema docs');
      l_retval := replace(l_retval, '<!-- template-pagetitle -->', l_text);

      l_text := ddd_util.get_text('text', 'headtitle', user);
      l_retval := replace(l_retval, '<!-- template-headtitle -->', l_text);

      -- assemble the body
      -- overview
      l_body :=
        '<h2 id="overview">Overview</h2>' ||
        ddd_util.get_text('html', 'overview')
      ;
      -- data
      l_body := l_body || '<h2 id="data">Data</h2>';
      l_body := l_body || '<h3 id="data">Tables</h3>';
      l_text := table_doc('DDD_TEXT');
      l_body := l_body || l_text;

      --code
      l_body := l_body || '<h2 id="code">Code</h2>';
      l_retval := replace(l_retval, '<!-- template-content -->', l_body);

      return l_retval;
    end crate_page;


    function table_doc(
      p_table_name in all_tables.table_name%type
    , p_owner      in all_tables.owner%type default null
    ) return clob is
      l_retval      clob;
      l_cursor      sys_refcursor;

      r_all_tab_comments all_tab_comments%rowtype;

    begin

      open l_cursor for
        select * from all_tab_comments where table_name = p_table_name;
      fetch l_cursor into r_all_tab_comments;
      close l_cursor;

      l_retval := l_retval ||
        '<h4 name="' || lower(r_all_tab_comments.table_type) || '-' || lower(r_all_tab_comments.table_name) || '">' ||
        lower(r_all_tab_comments.table_name) || ' <small>' || lower(r_all_tab_comments.table_type) || '</small></h4>' ||
        '<p>' || r_all_tab_comments.comments || '</p>';

      open l_cursor for
        select
          lower(t.column_name) "Column_Name",
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
            null) "Type",
          decode(t.nullable, 'N', '<abbr title="primary key" class="badge">PK</abbr>') "_",
          decode(t.nullable, 'N', '<abbr title="not null" class="badge">NN</abbr>') "_",
          c.comments "Comments"
         from sys.all_tab_columns t, sys.all_col_comments c
        where t.owner = nvl(p_owner, user)
          and t.table_name = p_table_name
          and t.owner = c.owner
          and t.table_name = c.table_name
          and t.column_name = c.column_name
        order by t.column_id
        ;
      l_retval := l_retval || cursor2table(l_cursor, 'table table-hover table-condensed');

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
        l_xsl := ddd_util.get_text('xsl', 'html-table');

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

        l_xsl := ddd_util.get_text('xsl', 'html-dl');

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
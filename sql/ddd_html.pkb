create or replace
package body ddd_html is

    function create_page return clob is
      l_retval     clob;
      l_html       clob;
      l_text       clob;
    begin
      dbms_lob.createtemporary(l_retval,true);

      -- get the head template and do replacements and append to return value
      l_html := ddd_util.get_text('html', 'page-head');
      l_text := ddd_util.get_text('text', 'pagetitle', user || ' schema docs');
      l_html := replace(l_html, '<!-- template-pagetitle -->', l_text);
      l_text := ddd_util.get_text('text', 'headtitle', user);
      l_html := replace(l_html, '<!-- template-headtitle -->', l_text);
      dbms_lob.append(l_retval,l_html);

      -- assemble the body
      -- overview
      l_html := '<h1 id="overview">Overview</h1>' || ddd_util.get_text('html', 'overview-intro');
      dbms_lob.append(l_retval,l_html);

      -- data
      l_html := '<h1 id="data">Data</h1>' || ddd_util.get_text('html', 'data-intro');
      l_html := l_html || '<h2 id="data">Tables</h2>';

      for r in (
        select object_name, object_type
        from user_objects
        where regexp_like (object_name, ddd_util.get_text('text', 'object-regexp-like', '.*'))
        and not regexp_like (object_name, ddd_util.get_text('text', 'object-not-regexp-like', '^$'))
        and object_type = 'TABLE' 
        order by object_name
      ) loop
        l_html := l_html || table_doc(r.object_name, r.object_type);
      end loop;
      dbms_lob.append(l_retval,l_html);

      l_html := '<h2 id="data">Views</h2>';
      for r in (
        select object_name, object_type
        from user_objects
        where regexp_like (object_name, ddd_util.get_text('text', 'object-regexp-like', '.*'))
        and not regexp_like (object_name, ddd_util.get_text('text', 'object-not-regexp-like', '^$'))
        and object_type = 'VIEW' 
        order by object_name
      ) loop
        l_html := l_html || table_doc(r.object_name, r.object_type);
      end loop;
      dbms_lob.append(l_retval,l_html);

      l_html := '<h2 id="data">Materialized Views</h2>';
      for r in (
        select object_name, object_type
        from user_objects
        where regexp_like (object_name, ddd_util.get_text('text', 'object-regexp-like', '.*'))
        and not regexp_like (object_name, ddd_util.get_text('text', 'object-not-regexp-like', '^$'))
        and object_type = 'MATERIALIZED VIEW' 
        order by object_name
      ) loop
        l_html := l_html || table_doc(r.object_name, r.object_type);
      end loop;
      dbms_lob.append(l_retval,l_html);

      -- code
      l_html := '<h1 id="code">Code</h1>' || ddd_util.get_text('html', 'code-intro');
      dbms_lob.append(l_retval,l_html);

      -- footer
      l_html := ddd_util.get_text('html', 'page-foot');
      dbms_lob.append(l_retval,l_html);

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
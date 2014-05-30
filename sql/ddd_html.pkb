create or replace
package body ddd_html is


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
          lower(column_name) "Column_Name",
          lower(data_type) ||
          decode(data_type,
            'CHAR',      '('|| char_length ||')',
            'VARCHAR',   '('|| char_length ||')',
            'VARCHAR2',  '('|| char_length ||')',
            'NCHAR',     '('|| char_length ||')',
            'NVARCHAR',  '('|| char_length ||')',
            'NVARCHAR2', '('|| char_length ||')',
            'NUMBER',    '('||
            nvl(data_precision,data_length)||
                 decode(data_scale,null,null,
                        ', '||data_scale)||')',
            null) "Type",
            nullable "Nullable"
         from sys.all_tab_columns
        where owner = nvl(p_owner, user)
          and table_name = p_table_name
        order by owner, table_name, column_id
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

        -- this is a generic XSL for Oracle's default XML row and rowset tags
        -- " " is a non-breaking space
        l_xsl := l_xsl || q'[<?xml version="1.0" encoding="ISO-8859-1"?>]';
        l_xsl := l_xsl || q'[<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">]';
        l_xsl := l_xsl || q'[ <xsl:output method="html"/>]';
        l_xsl := l_xsl || q'[ <xsl:template match="/">]';
        l_xsl := l_xsl || q'[   <dl>]';
        l_xsl := l_xsl || q'[     <xsl:for-each select="/ROWSET/*">]';
        l_xsl := l_xsl || q'[         <dt><xsl:value-of select="./*[1]"/></dt>]';
        l_xsl := l_xsl || q'[         <dd><xsl:value-of select="./*[2]"/></dd>]';
        l_xsl := l_xsl || q'[     </xsl:for-each>]';
        l_xsl := l_xsl || q'[   </dl>]';
        l_xsl := l_xsl || q'[ </xsl:template>]';
        l_xsl := l_xsl || q'[</xsl:stylesheet>]';

        -- table classes
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
create or replace
package ddd_html is


    function table_doc(
      p_table_name in all_tables.table_name%type
    , p_owner      in all_tables.owner%type default null
    ) return clob;

    function cursor2table(
      p_rf       sys_refcursor
    , p_class   in varchar2 default null
    , p_caption in varchar2 default null
    ) return clob;

    function cursor2dl(
      p_rf       sys_refcursor,
      p_class in varchar2 default null)
    return clob;


end ddd_html;
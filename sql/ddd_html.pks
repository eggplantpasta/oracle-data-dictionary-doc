create or replace
package ddd_html is


    function create_page return clob;

    function table_doc(
      p_object_name in user_objects.object_name%type
    , p_object_type in user_objects.object_type%type
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
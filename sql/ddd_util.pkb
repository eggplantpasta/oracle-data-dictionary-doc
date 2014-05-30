create or replace
package body ddd_util is


    function get_text(
      p_text_type in ddd_text.text_type%type
    , p_text_name in ddd_text.text_name%type
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

      return l_retval;
    end get_text;


end ddd_util;
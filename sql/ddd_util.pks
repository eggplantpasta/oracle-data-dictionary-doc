create or replace
package ddd_util is


    function get_text(
      p_text_type in ddd_text.text_type%type
    , p_text_name in ddd_text.text_name%type
    ) return clob;


end ddd_util;
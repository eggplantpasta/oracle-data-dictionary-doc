create or replace
package ddd_util is

	g_file_directory varchar2(30) := 'DDD_DIR';


	function get_text(
    p_text_type    in ddd_text.text_type%type
  , p_text_name    in ddd_text.text_name%type
  , p_text_default in ddd_text.text_name%type default null
	) return clob;


  -- input output utilities
  procedure load_all_text(p_file_directory in varchar2);


  procedure load_text(
    p_text_type  ddd_text.text_type%type
  , p_text_name ddd_text.text_name%type
  , p_filename  ddd_text.filename%type
  );

  procedure output_text;

end ddd_util;
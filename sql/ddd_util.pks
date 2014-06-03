create or replace
package ddd_util is

	c_file_directory constant varchar2(30) := 'DDD_DIR';


	function get_text(
	  p_text_type in ddd_text.text_type%type
	, p_text_name in ddd_text.text_name%type
	) return clob;


  procedure load_all_text;


  procedure load_text(
    p_text_type  ddd_text.text_type%type
  , p_text_name ddd_text.text_name%type
  , p_filename  ddd_text.filename%type
  );


end ddd_util;
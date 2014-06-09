create or replace
package ddd_util is

  -- input output utilities
  procedure load_db_text(p_file_directory in varchar2);

  procedure load_text(
    p_text_type  ddd_text.text_type%type
  , p_text_name ddd_text.text_name%type
  , p_filename  ddd_text.filename%type
  , p_file_directory  in varchar2
  );

  procedure put_clob(p_clob in clob);

end ddd_util;
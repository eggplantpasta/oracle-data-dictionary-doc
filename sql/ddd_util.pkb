create or replace
package body ddd_util is


  function get_text(
    p_text_type    in ddd_text.text_type%type
  , p_text_name    in ddd_text.text_name%type
  , p_text_default in ddd_text.text_name%type default null
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

    if l_retval is null or dbms_lob.getlength(l_retval) = 0 then
      l_retval := p_text_default;
    end if;

    return l_retval;
  end get_text;


  procedure load_all_text(p_file_directory in varchar2) is
  begin
   g_file_directory := p_file_directory;
   for r in (
      select * from ddd_text where filename is not null
    ) loop
      load_text(r.text_type, r.text_name, r.filename);
    end loop;
  end load_all_text;


  procedure load_text(
    p_text_type  ddd_text.text_type%type
  , p_text_name ddd_text.text_name%type
  , p_filename  ddd_text.filename%type
  ) is
    l_bfile   BFILE;
    l_clob    clob;

    l_dest_offset  integer := 1;
    l_src_offset   integer := 1;
    l_lang_context number := dbms_lob.default_lang_ctx;
    l_warning      number;

  begin
      l_bfile := bfilename (g_file_directory, p_filename);

      if dbms_lob.fileexists (l_bfile) = 1 then

          dbms_lob.open (l_bfile, dbms_lob.lob_readonly);
          dbms_lob.createtemporary (l_clob, true, dbms_lob.session);
          dbms_lob.loadclobfromfile (
            dest_lob     => l_clob
          , src_bfile    => l_bfile
          , amount       => dbms_lob.lobmaxsize
          , dest_offset  => l_dest_offset
          , src_offset   => l_src_offset
          , bfile_csid   => dbms_lob.default_csid
          , lang_context => l_lang_context
          , warning      => l_warning
          );
          dbms_lob.close (l_bfile);

          update ddd_text
          set text = l_clob
          where text_type = p_text_type
          and text_name = p_text_name;

      end if;

  end load_text;


  procedure output_text is
  begin
    dbms_output.enable(null);
    dbms_output.put_line(ddd_html.crate_page);
  end;

end ddd_util;
create or replace
package body ddd_util is


  procedure load_db_text(p_file_directory in varchar2) is
  begin
   for r in (
      select * from ddd_text where filename is not null
    ) loop
      load_text(r.text_type, r.text_name, r.filename, p_file_directory);
    end loop;
  end load_db_text;


  procedure load_text(
    p_text_type  ddd_text.text_type%type
  , p_text_name ddd_text.text_name%type
  , p_filename  ddd_text.filename%type
  , p_file_directory  in varchar2
  ) is
    l_bfile   BFILE;
    l_clob    clob;

    l_dest_offset  integer := 1;
    l_src_offset   integer := 1;
    l_lang_context number := dbms_lob.default_lang_ctx;
    l_warning      number;

  begin
      l_bfile := bfilename (p_file_directory, p_filename);

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


  procedure put_clob(p_clob in clob) is
    l_offset  integer := 1;
    l_size    integer := dbms_lob.getlength(p_clob);
    l_maxsize integer := least(32767, l_size);
  begin
    dbms_output.enable(null);
    while l_offset < l_size loop
      dbms_output.put_line(dbms_lob.substr(p_clob, least(l_maxsize, l_size - l_offset), l_offset));
      l_offset := l_offset + least(l_maxsize, l_size - l_offset);
    end loop;
  end put_clob;


end ddd_util;
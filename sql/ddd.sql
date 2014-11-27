create or replace
package ddd is

-- mustache template proceessing

/** process simple mustache tags: variables {{, {{{, and comments {{! */
function process_simple_tag (
  p_tag in varchar2
, p_val in clob
) return clob;

/** process section mustache tags {{#, {{/ */
function process_section_tag (
  p_tag  in varchar2
, p_list in sys_refcursor
) return clob;

-- file handling

/** load a clob from a file */
function file2clob (
  p_dir      in varchar2
, p_filename in varchar2
) return clob;

/** save a clob to a file */
procedure clob2file (
  p_dir      in varchar2
, p_filename in varchar2
, p_clob     in clob
);

end ddd;
/

create or replace
package body ddd is

-- mustache template proceessing

function process_simple_tag (
  p_tag in varchar2
, p_val in clob
) return clob is
begin
   return
     case
       when substr(p_tag, 1, 3) = '{{{' then
         -- variable, return unescaped value
         p_val
       when substr(p_tag, 1, 3) = '{{!' then
         -- comment, return nothing
         null
       when substr(p_tag, 1, 2) = '{{' then
         -- variable, return HTML escape value
         htf.escape_sc(p_val)
       else -- unrecognised simple tag type - return unchanged for debugging
         p_tag
     end;
end process_simple_tag;


function process_section_tag (
  p_tag  in varchar2
, p_list in sys_refcursor
) return clob is
begin
  return null; -- TODO
end process_section_tag;


function file2clob (
  p_dir      in varchar2
, p_filename in varchar2
) return clob is

  l_bfile        bfile;
  l_returnvalue  clob;

  l_dest_offset    integer := 1;
  l_src_offset     integer := 1;
  l_lang_context   integer := dbms_lob.default_lang_ctx;
  l_warning        integer;
begin

  dbms_lob.createtemporary (l_returnvalue, false);
  l_bfile := bfilename (p_dir, p_filename);
  dbms_lob.fileopen (l_bfile, dbms_lob.file_readonly);
  dbms_lob.loadclobfromfile (
    dest_lob     => l_returnvalue
  , src_bfile    => l_bfile
  , amount       => dbms_lob.lobmaxsize
  , dest_offset  => l_dest_offset
  , src_offset   => l_src_offset
  , bfile_csid   => dbms_lob.default_csid
  , lang_context => l_lang_context
  , warning      => l_warning
  );
  dbms_lob.fileclose (l_bfile);

  return l_returnvalue;

exception
  when others then
    if dbms_lob.fileisopen (l_bfile) = 1 then
      dbms_lob.fileclose (l_bfile);
    end if;
    dbms_lob.freetemporary(l_returnvalue);
    raise;

end file2clob;


procedure clob2file (
  p_dir      in varchar2
, p_filename in varchar2
, p_clob     in clob
) is
  l_file      utl_file.file_type;
  l_buffer    varchar2(32767);
  l_amount    binary_integer := 8000;
  l_pos       integer := 1;
  l_clob_len  integer;
begin

  l_clob_len := dbms_lob.getlength (p_clob);
  l_file := utl_file.fopen (p_dir, p_filename, 'w', 32767);

  while l_pos < l_clob_len loop
    dbms_lob.read (p_clob, l_amount, l_pos, l_buffer);
    utl_file.put (l_file, l_buffer);
    utl_file.fflush (l_file);
    l_pos := l_pos + l_amount;
  end loop;

  utl_file.fclose (l_file);

exception
  when others then
    if utl_file.is_open (l_file) then
      utl_file.fclose (l_file);
    end if;
    raise;

end clob2file;


end ddd;
/

set define off;
create or replace
package ddd is

-- mustache template proceessing

/** process simple mustache tags: variables {{, {{{, and comments {{! */
function process_simple_tag (
  p_template in clob
, p_tag in varchar2
, p_val in varchar2
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

/** document schema */
procedure document (
  p_dir               in varchar2
, p_template_filename in varchar2 default 'default.mustache'
, p_document_filename in varchar2 default 'index.html'
, p_schema            in varchar2 default null
);

end ddd;
/

create or replace
package body ddd is

-- clob utilities

function clob_escape (
  p_clob in clob
) return clob is
  l_return clob := p_clob;
begin
  -- escape html special characters in a clob
  l_return := regexp_replace(l_return, '&', '&amp;');
  l_return := regexp_replace(l_return, '"', '&quot;');
  l_return := regexp_replace(l_return, '<', '&lt;');
  l_return := regexp_replace(l_return, '>', '&gt;');
  l_return := regexp_replace(l_return, '''', '&#x27;');
  l_return := regexp_replace(l_return, '/', '&#x2F;');
  return l_return;
end clob_escape;


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


-- mustache template proceessing

function process_simple_tag (
  p_template in clob
, p_tag in varchar2
, p_val in varchar2
) return clob is
  l_return clob;
begin
  -- variable, replace with unescaped value
  l_return := regexp_replace(p_template, '{{{'||p_tag||'}}', p_val);
  -- comment, replace with nothing
  l_return := regexp_replace(p_template, '{{!'||p_tag||'}}', null);
    -- variable, replace with HTML escape value
  l_return := regexp_replace(p_template, '{{'||p_tag||'}}', htf.escape_sc(p_val));
  return l_return;
end process_simple_tag;


function process_section_tag (
  p_tag  in varchar2
, p_list in sys_refcursor
) return clob is
begin
  return null; -- TODO
end process_section_tag;


procedure document (
  p_dir               in varchar2
, p_template_filename in varchar2 default 'default.mustache'
, p_document_filename in varchar2 default 'index.html'
, p_schema            in varchar2 default null
) is
  l_schema varchar2(30) := p_schema;
  l_template clob;
  
  -- simple variables
  l_sys_context varchar2(256);

begin
  -- defaults
  l_schema := nvl(p_schema, sys_context ('USERENV', 'CURRENT_SCHEMA'));

  -- fetch the template
  l_template := ddd.file2clob (p_dir, p_template_filename);

  -- replace simple variables
  l_template := process_simple_tag(l_template, 'schema', l_schema);
  l_template := process_simple_tag(l_template, 'shortdate', to_char(sysdate, 'DS'));
  l_template := process_simple_tag(l_template, 'longdate', to_char(sysdate, 'DL'));
  l_template := process_simple_tag(l_template, 'datetime', to_char(sysdate, 'DS TS'));

  l_template := process_simple_tag(l_template, 'procedure', 'ddd.document');
  l_template := process_simple_tag(l_template, 'p_dir', p_dir);
  l_template := process_simple_tag(l_template, 'p_template_filename', p_template_filename);
  l_template := process_simple_tag(l_template, 'p_document_filename', p_document_filename);
  l_template := process_simple_tag(l_template, 'p_schema', p_schema);
  
  l_template := process_simple_tag(l_template, 'db_name', sys_context ('USERENV', 'DB_NAME'));
  l_template := process_simple_tag(l_template, 'current_schema', sys_context ('USERENV', 'CURRENT_SCHEMA'));

  -- write the results
  ddd.clob2file (p_dir, p_document_filename, l_template);
end document;


end ddd;
/

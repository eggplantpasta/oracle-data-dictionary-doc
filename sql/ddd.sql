set define off;
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

function clob_replace (
  p_clob          in clob
, p_what          in varchar2
, p_with          in varchar2 ) return clob is

  c_whatlen       constant pls_integer := length(p_what);
  c_withlen       constant pls_integer := length(p_with);

  l_return        clob;
  l_segment       clob;
  l_pos           pls_integer := 1-c_withlen;
  l_offset        pls_integer := 1;

begin

  if p_what is not null then
    while l_offset < dbms_lob.getlength(p_clob) loop
      l_segment := dbms_lob.substr(p_clob,32767,l_offset);
      loop
        l_pos := dbms_lob.instr(l_segment,p_what,l_pos+c_withlen);
        exit when (nvl(l_pos,0) = 0) or (l_pos = 32767-c_withlen);
        l_segment := to_clob( dbms_lob.substr(l_segment,l_pos-1)
                            ||p_with
                            ||dbms_lob.substr(l_segment,32767-c_whatlen-l_pos-c_whatlen+1,l_pos+c_whatlen));
      end loop;
      l_return := l_return||l_segment;
      l_offset := l_offset + 32767 - c_whatlen;
    end loop;
  end if;

  return l_return;

end clob_replace;


function clob_escape (
  p_clob in clob
) return clob is
  l_return clob := p_clob;
begin
  -- escape html special characters in a clob
  l_return := clob_replace(l_return, '&', '&amp;');
  l_return := clob_replace(l_return, '"', '&quot;');
  l_return := clob_replace(l_return, '<', '&lt;');
  l_return := clob_replace(l_return, '>', '&gt;');
  l_return := clob_replace(l_return, '''', '&#x27;');
  l_return := clob_replace(l_return, '/', '&#x2F;');
  return l_return;
end clob_escape;


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


procedure document (
  p_dir               in varchar2
, p_template_filename in varchar2 default 'default.mustache'
, p_document_filename in varchar2 default 'index.html'
, p_schema            in varchar2 default null
) is
  l_schema varchar2(30) := p_schema;
  l_template clob;
  
begin
  -- defaults
  if l_schema is null then
    select sys_context ('USERENV', 'CURRENT_SCHEMA')
    into l_schema
    from dual;
  end if;

  -- fetch the template
  l_template := ddd.file2clob (p_dir, p_template_filename);
  
  -- fetch simple variables
  
  -- replace simple variables
  l_template := clob_replace(l_template, '{{schema}}', l_schema);
  l_template := clob_replace(l_template, '{{shortdate}}', to_char(sysdate, 'DD-MON-YYYY'));
  l_template := clob_replace(l_template, '{{longdate}}', to_char(sysdate, 'Month dth, YYYY'));
  l_template := clob_replace(l_template, '{{datetime}}', to_char(sysdate, 'DD Month YYYY HH24:MI:SS'));
  
  ddd.clob2file (p_dir, p_document_filename, l_template);
end document;


end ddd;
/

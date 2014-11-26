create or replace
package ddd is

-- mustache template proceessing

/** process simple mustache tags: variables {{, {{{, and comments {{! */
function process_simple_tag (
  tag in varchar2,
  val in clob
  ) return clob;

/** process section mustache tags {{#, {{/ */
function process_section_tag (
  tag in varchar2,
  list_vals in sys_refcursor
  ) return clob;

end ddd;
/

create or replace
package body ddd is

-- mustache template proceessing

function process_simple_tag (
  tag in varchar2,
  val in clob
  ) return clob is
begin
  return
    case
      when substr(tag, 1, 3) = '{{{' then
        -- variable, return unescaped value
        val
      when substr(tag, 1, 3) = '{{!' then
        -- comment, return nothing
        null
      when substr(tag, 1, 2) = '{{' then
        -- variable, return HTML escape value
        htf.escape_sc(val)
      else -- unrecognised simple tag type - return unchanged for debugging
        tag
    end;
end process_simple_tag;


function process_section_tag (
  tag in varchar2,
  list_vals in sys_refcursor
  ) return clob is
begin
  return null;
end process_section_tag;


end ddd;
/

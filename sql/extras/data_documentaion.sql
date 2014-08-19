-- Table and column documentation
--
-- Use the following select statements to create code templates for the creation of table and column comments for the current user's tables.
-- Where a comment exists the code generated is pre-populated to re-create it, but the whole statement is commented out by default.

select nvl2(t.comments, '/* ', null) || 'comment on table ' || lower(t.table_name) || ' is ''' || t.comments || ''';' || nvl2(t.comments, ' */', null)
from user_tab_comments t, user_objects o
where t.table_name = o.object_name
and o.object_type = 'TABLE'
order by t.table_name;

select nvl2(t.comments, '/* ', null) || 'comment on column ' || lower(t.table_name || '.' || t.column_name) || ' is ''' || t.comments || ''';' || nvl2(t.comments, ' */', null)
from user_col_comments t, user_objects o
where t.table_name = o.object_name
and o.object_type = 'TABLE'
order by t.table_name, t.column_name;

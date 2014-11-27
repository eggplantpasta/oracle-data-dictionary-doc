select ddd.process_simple_tag(tag => '{{test}}',val => '<p>hello world</p>') from dual;

begin
  ddd.clob2file ('ddd_files', 'page.html', ddd.file2clob ('ddd_files', 'page.mustache'));
end;
/

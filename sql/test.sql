-- unit tests
select ddd.process_simple_tag(tag => '{{test}}',val => '<p>hello world</p>') from dual;
exec ddd.clob2file ('DDD_FILES', 'ddd.html', ddd.file2clob ('DDD_FILES', 'ddd.mustache'));
exec ddd.document('DDD_FILES');

-- system tests

-- example file creation
exec ddd.clob2file ('DDD_FILES', 'dddexample.html', ddd.file2clob ('DDD_FILES', 'ddd.mustache'));

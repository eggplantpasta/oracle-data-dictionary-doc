-- unit tests
select ddd.process_simple_tag(tag => '{{test}}',val => '<p>hello world</p>') from dual;
exec ddd.clob2file ('DDD_FILES', 'clob2file.html', ddd.file2clob ('DDD_FILES', 'default.mustache'));

-- system tests
exec ddd.document('DDD_FILES');
exec ddd.document('DDD_FILES', 'default.mustache', 'test.html', 'HR');

-- example file creation
exec ddd.document('DDD_FILES', 'hrexample.mustache', 'example.html', 'HR');

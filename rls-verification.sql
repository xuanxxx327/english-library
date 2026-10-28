begin;
insert into auth.users(id) values ('10000000-0000-4000-8000-000000000001'),('10000000-0000-4000-8000-000000000002');
insert into public.learning_cards(user_id,en,zh,content_hash) values ('10000000-0000-4000-8000-000000000001','rls-test-a','测试','rls-test-a'),('10000000-0000-4000-8000-000000000002','rls-test-b','测试','rls-test-b');
insert into storage.objects(bucket_id,name) values ('english-library-private','10000000-0000-4000-8000-000000000001/rls-test'),('english-library-private','10000000-0000-4000-8000-000000000002/rls-test');
set local role authenticated;
select set_config('request.jwt.claim.sub','10000000-0000-4000-8000-000000000001',true);
do $$
declare n integer;
begin
if (select count(*) from public.learning_cards where content_hash like 'rls-test-%') <> 1 then raise exception 'card SELECT isolation failed'; end if;
if (select count(*) from storage.objects where name like '%/rls-test') <> 1 then raise exception 'storage SELECT isolation failed'; end if;
update public.learning_cards set en='forbidden' where user_id='10000000-0000-4000-8000-000000000002'; get diagnostics n=row_count; if n<>0 then raise exception 'foreign update allowed';end if;
begin
insert into public.learning_cards(user_id,en,zh) values('10000000-0000-4000-8000-000000000002','forbidden','forbidden');
raise exception 'foreign insert allowed';
exception when insufficient_privilege then null;end;
begin
update public.learning_cards set user_id='10000000-0000-4000-8000-000000000002' where content_hash='rls-test-a';
raise exception 'owner reassignment allowed';
exception when insufficient_privilege then null;end;
begin
insert into storage.objects(bucket_id,name) values ('english-library-private','10000000-0000-4000-8000-000000000002/forbidden');
raise exception 'foreign storage insert allowed';
exception when insufficient_privilege then null;end;
update storage.objects set name='10000000-0000-4000-8000-000000000002/forbidden-update' where name='10000000-0000-4000-8000-000000000002/rls-test'; get diagnostics n=row_count; if n<>0 then raise exception 'foreign storage update allowed';end if;
begin
update storage.objects set name='10000000-0000-4000-8000-000000000002/forbidden-reassign' where name='10000000-0000-4000-8000-000000000001/rls-test';
raise exception 'storage reassignment allowed';
exception when insufficient_privilege then null;end;
if has_table_privilege('authenticated','public.learning_cards','TRUNCATE') then raise exception 'truncate exposed';end if;
end $$;
set local role anon;
select set_config('request.jwt.claim.sub','',true);
do $$ begin
begin
if exists(select 1 from public.learning_cards) then raise exception 'anonymous rows exposed';end if;
exception when insufficient_privilege then null;end;
if exists(select 1 from storage.objects where name like '%/rls-test') then raise exception 'anonymous storage exposed';end if;
end $$;
rollback;

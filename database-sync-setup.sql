alter table public.learning_cards add column if not exists content_hash text; create unique index if not exists learning_cards_owner_content_hash on public.learning_cards(user_id,content_hash);
revoke truncate, references, trigger on public.learning_cards from authenticated;

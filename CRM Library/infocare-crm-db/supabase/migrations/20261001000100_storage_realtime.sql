-- =====================================================================
-- Infocare CRM — storage buckets and realtime (Supabase only)
-- Run after 20261001000000_core_schema.sql
-- ---------------------------------------------------------------------
-- File path convention (the app must follow it):
--   visit-photos/<branch_id>/<lead_id>/<file>.jpg
--   quotation-pdfs/<branch_id>/<quotation_number>-v<version>.pdf
--   product-docs/<sku>/<file>.pdf
-- The first folder of photos and PDFs is the branch id, so the same
-- branch rules as the tables apply to files.
-- =====================================================================

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values
  ('visit-photos',   'visit-photos',   false, 10485760, array['image/jpeg', 'image/png', 'image/heic', 'image/webp', 'audio/mp4', 'audio/aac', 'audio/mpeg']),
  ('quotation-pdfs', 'quotation-pdfs', false, 10485760, array['application/pdf']),
  ('product-docs',   'product-docs',   false, 26214400, array['application/pdf', 'image/jpeg', 'image/png'])
on conflict (id) do nothing;

-- Photos and quotation PDFs: branch rules from the folder name --------------
create policy "crm branch files read" on storage.objects
  for select to authenticated
  using (bucket_id in ('visit-photos', 'quotation-pdfs')
         and public.can_read_branch(public.try_uuid((storage.foldername(name))[1])));

create policy "crm branch files upload" on storage.objects
  for insert to authenticated
  with check (bucket_id in ('visit-photos', 'quotation-pdfs')
              and (public.can_write_branch(public.try_uuid((storage.foldername(name))[1]))
                   or public.my_role() = 'back_office'));

create policy "crm branch files delete" on storage.objects
  for delete to authenticated
  using (bucket_id in ('visit-photos', 'quotation-pdfs') and public.my_role() = 'admin');

-- Product documents: everyone reads, admin manages ------------------------------
create policy "product docs read" on storage.objects
  for select to authenticated
  using (bucket_id = 'product-docs' and public.my_role() is not null);

create policy "product docs admin insert" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'product-docs' and public.my_role() = 'admin');

create policy "product docs admin update" on storage.objects
  for update to authenticated
  using (bucket_id = 'product-docs' and public.my_role() = 'admin');

create policy "product docs admin delete" on storage.objects
  for delete to authenticated
  using (bucket_id = 'product-docs' and public.my_role() = 'admin');

-- Live updates in the Flutter app (lead inbox, pipeline, tasks) -----------------
alter publication supabase_realtime
  add table public.leads, public.deals, public.tasks, public.activities, public.quotations;

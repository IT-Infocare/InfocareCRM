-- ============================================================================
-- Migration: Establish Companies as Parent and Branches as Children
-- Date: 2026-10-15
-- Hierarchy:
--   Parent: public.companies (e.g. InfoCare Systems)
--   Children: public.branches (e.g. InfoCare System Dubai, InfoCare System Iraq, InfoCare Systems Sharjah)
-- ============================================================================

-- 1. Ensure updated_at trigger function exists
create or replace function public.tg_set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

-- 2. Create public.companies table if not exists
create table if not exists public.companies (
  id uuid not null default gen_random_uuid(),
  name text not null,
  code text null,
  trade_licence_no text null,
  industry text null,
  country text not null default 'UAE'::text,
  emirate text null,
  city text null,
  address text null,
  website text null,
  phone text null,
  email text null,
  logo_url text null,
  tax_number text null,
  notes text null,
  is_active boolean null default true,
  created_by uuid null default auth.uid(),
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now(),
  constraint companies_pkey primary key (id)
);

-- Safely link created_by to profiles(id) if profiles exists
do $$
begin
  if exists (select 1 from information_schema.tables where table_schema = 'public' and table_name = 'profiles') then
    if not exists (select 1 from information_schema.table_constraints where constraint_name = 'companies_created_by_fkey') then
      alter table public.companies 
        add constraint companies_created_by_fkey foreign key (created_by) references public.profiles (id) on delete set null;
    end if;
  end if;
end $$;

-- Drop legacy branch_id foreign key constraint and index from companies if present
alter table public.companies drop constraint if exists companies_branch_id_fkey cascade;
drop index if exists public.companies_branch_idx;

-- Drop any legacy RLS policies on companies that referenced branch_id
drop policy if exists companies_read on public.companies;
drop policy if exists companies_insert on public.companies;
drop policy if exists companies_update on public.companies;
drop policy if exists companies_delete on public.companies;

-- Drop branch_id column from companies if it exists
alter table public.companies drop column if exists branch_id cascade;

-- Ensure all parent company columns exist
alter table public.companies add column if not exists code text;
alter table public.companies add column if not exists trade_licence_no text;
alter table public.companies add column if not exists industry text;
alter table public.companies add column if not exists country text default 'UAE';
alter table public.companies add column if not exists emirate text;
alter table public.companies add column if not exists city text;
alter table public.companies add column if not exists address text;
alter table public.companies add column if not exists website text;
alter table public.companies add column if not exists phone text;
alter table public.companies add column if not exists email text;
alter table public.companies add column if not exists logo_url text;
alter table public.companies add column if not exists tax_number text;
alter table public.companies add column if not exists notes text;
alter table public.companies add column if not exists is_active boolean default true;
alter table public.companies add column if not exists updated_at timestamptz default now();

-- Name index on companies
create index if not exists companies_name_idx on public.companies using btree (lower(name));

-- Trigger on companies
drop trigger if exists set_updated_at on public.companies;
create trigger set_updated_at before update on public.companies
for each row execute function public.tg_set_updated_at();

-- 3. Create or alter public.branches table
create table if not exists public.branches (
  id uuid not null default gen_random_uuid(),
  company_id uuid null,
  code text not null,
  name text not null,
  country text not null default 'UAE'::text,
  currency character varying(10) not null default 'AED'::bpchar,
  created_at timestamp with time zone not null default now(),
  timezone text null default 'Asia/Dubai'::text,
  time_zone text null default 'Asia/Dubai'::text,
  phone text null,
  mobile text null,
  email text null,
  location text null,
  tr_number text null,
  address text null,
  is_active boolean null default true,
  vat_number text null,
  logo_url text null,
  manager text null,
  city text null default 'Dubai'::text,
  vat_percent numeric(5, 2) null default 5.0,
  website text null,
  po_box text null,
  updated_at timestamp with time zone not null default now(),
  constraint branches_pkey primary key (id),
  constraint branches_code_key unique (code)
);

-- Ensure company_id exists on branches
alter table public.branches add column if not exists company_id uuid;

-- 4. Seed parent company: 'InfoCare Systems'
insert into public.companies (
  id,
  name,
  code,
  trade_licence_no,
  industry,
  country,
  emirate,
  city,
  address,
  website,
  phone,
  email,
  tax_number,
  notes,
  is_active
) values (
  '11111111-2222-3333-4444-555555555555',
  'InfoCare Systems',
  'INFOCARE',
  'CN-1029384',
  'IT, Security & Surveillance Systems',
  'UAE',
  'Dubai',
  'Dubai',
  'Business Bay, Tower B, Office 1204, Dubai, UAE',
  'https://infocaresystems.com',
  '+971 4 321 0000',
  'info@infocaresystems.com',
  '100293847500001',
  'Parent enterprise entity managing InfoCare regional branches across UAE and the Middle East.',
  true
)
on conflict (id) do update set
  name = excluded.name,
  code = excluded.code,
  trade_licence_no = excluded.trade_licence_no,
  industry = excluded.industry,
  address = excluded.address,
  website = excluded.website,
  phone = excluded.phone,
  email = excluded.email,
  tax_number = excluded.tax_number,
  updated_at = now();

-- Associate existing branches without company_id to InfoCare Systems
update public.branches
set company_id = '11111111-2222-3333-4444-555555555555'
where company_id is null;

-- Enforce company_id NOT NULL and foreign key constraint
alter table public.branches alter column company_id set not null;

alter table public.branches drop constraint if exists branches_company_id_fkey;
alter table public.branches
  add constraint branches_company_id_fkey foreign key (company_id)
  references public.companies (id) on delete cascade;

-- Index on branches(company_id)
create index if not exists branches_company_idx on public.branches using btree (company_id);

-- Trigger on branches
drop trigger if exists set_updated_at_branches on public.branches;
create trigger set_updated_at_branches before update on public.branches
for each row execute function public.tg_set_updated_at();

-- 5. Seed Child Branches under 'InfoCare Systems'
-- Branch 1: InfoCare System Dubai
insert into public.branches (
  id,
  company_id,
  code,
  name,
  country,
  city,
  currency,
  vat_percent,
  timezone,
  time_zone,
  phone,
  mobile,
  email,
  location,
  tr_number,
  address,
  website,
  po_box,
  manager,
  is_active
) values (
  '77777777-7777-4777-a777-777777777777',
  '11111111-2222-3333-4444-555555555555',
  'DXB',
  'InfoCare System Dubai',
  'UAE',
  'Dubai',
  'AED',
  5.0,
  'Asia/Dubai',
  'Asia/Dubai',
  '+971 4 321 0000',
  '+971 50 111 2222',
  'dubai@infocare.ae',
  'Dubai, UAE',
  '100293847500003',
  'Business Bay, Tower B, Office 1204, Dubai, UAE',
  'https://infocare.ae',
  'P.O. Box 12345, Dubai',
  'Sarah Connor',
  true
)
on conflict (code) do update set
  company_id = excluded.company_id,
  name = excluded.name,
  country = excluded.country,
  city = excluded.city,
  currency = excluded.currency,
  vat_percent = excluded.vat_percent,
  timezone = excluded.timezone,
  phone = excluded.phone,
  mobile = excluded.mobile,
  email = excluded.email,
  location = excluded.location,
  tr_number = excluded.tr_number,
  address = excluded.address,
  manager = excluded.manager,
  updated_at = now();

-- Branch 2: InfoCare System Iraq
insert into public.branches (
  id,
  company_id,
  code,
  name,
  country,
  city,
  currency,
  vat_percent,
  timezone,
  time_zone,
  phone,
  mobile,
  email,
  location,
  tr_number,
  address,
  website,
  po_box,
  manager,
  is_active
) values (
  '88888888-8888-4888-a888-888888888888',
  '11111111-2222-3333-4444-555555555555',
  'IRQ',
  'InfoCare System Iraq',
  'Iraq',
  'Baghdad',
  'USD',
  0.0,
  'Asia/Baghdad',
  'Asia/Baghdad',
  '+964 1 719 0000',
  '+964 770 123 4567',
  'iraq@infocare.ae',
  'Baghdad, Iraq',
  'IRQ-9928172',
  'Al-Mansour District, Street 14, Building 22, Baghdad, Iraq',
  'https://infocare.iq',
  'P.O. Box 1001, Baghdad',
  'Ali Mansoor',
  true
)
on conflict (code) do update set
  company_id = excluded.company_id,
  name = excluded.name,
  country = excluded.country,
  city = excluded.city,
  currency = excluded.currency,
  vat_percent = excluded.vat_percent,
  timezone = excluded.timezone,
  phone = excluded.phone,
  mobile = excluded.mobile,
  email = excluded.email,
  location = excluded.location,
  tr_number = excluded.tr_number,
  address = excluded.address,
  manager = excluded.manager,
  updated_at = now();

-- Branch 3: InfoCare Systems Sharjah
insert into public.branches (
  id,
  company_id,
  code,
  name,
  country,
  city,
  currency,
  vat_percent,
  timezone,
  time_zone,
  phone,
  mobile,
  email,
  location,
  tr_number,
  address,
  website,
  po_box,
  manager,
  is_active
) values (
  '99999999-9999-4999-a999-999999999999',
  '11111111-2222-3333-4444-555555555555',
  'SHJ',
  'InfoCare Systems Sharjah',
  'UAE',
  'Sharjah',
  'AED',
  5.0,
  'Asia/Dubai',
  'Asia/Dubai',
  '+971 6 555 0000',
  '+971 52 888 9999',
  'sharjah@infocare.ae',
  'Sharjah, UAE',
  '100293847500005',
  'Al Majaz 3, Corniche Road, Crystal Tower, Suite 501, Sharjah, UAE',
  'https://infocare.ae',
  'P.O. Box 4500, Sharjah',
  'Rashid Al Nuaimi',
  true
)
on conflict (code) do update set
  company_id = excluded.company_id,
  name = excluded.name,
  country = excluded.country,
  city = excluded.city,
  currency = excluded.currency,
  vat_percent = excluded.vat_percent,
  timezone = excluded.timezone,
  phone = excluded.phone,
  mobile = excluded.mobile,
  email = excluded.email,
  location = excluded.location,
  tr_number = excluded.tr_number,
  address = excluded.address,
  manager = excluded.manager,
  updated_at = now();

-- 6. Permissions
grant all on public.companies to authenticated, service_role, anon;
grant all on public.branches to authenticated, service_role, anon;

notify pgrst, 'reload schema';

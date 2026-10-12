-- =====================================================================
-- Migration: 20261012000000_branches_enhancement.sql
-- Description: Add logo, manager, regional location, currency, VAT rate,
--              website, and contact details to public.branches table.
-- =====================================================================

-- 1. Alter public.branches table with new fields
alter table public.branches
  add column if not exists logo_url text,
  add column if not exists manager text,
  add column if not exists city text default 'Dubai',
  add column if not exists vat_percent numeric(5, 2) default 5.0,
  add column if not exists website text,
  add column if not exists po_box text,
  add column if not exists timezone text default 'Asia/Dubai',
  add column if not exists phone text,
  add column if not exists mobile text,
  add column if not exists email text,
  add column if not exists location text,
  add column if not exists tr_number text,
  add column if not exists address text,
  add column if not exists is_active boolean not null default true,
  add column if not exists updated_at timestamptz not null default now();

-- Ensure currency can store up to 10 characters if needed
alter table public.branches
  alter column currency type varchar(10);

-- Sync vat_number with tr_number if tr_number is currently null
update public.branches
   set tr_number = vat_number
 where tr_number is null and vat_number is not null;

-- 2. Attach updated_at automatic trigger
do $$
begin
  if exists (select 1 from pg_proc where proname = 'tg_set_updated_at') then
    drop trigger if exists set_updated_at_branches on public.branches;
    create trigger set_updated_at_branches
      before update on public.branches
      for each row execute function public.tg_set_updated_at();
  end if;
end $$;

-- 3. Populate default metadata for standard Infocare branches
-- Dubai HQ
update public.branches
   set manager      = coalesce(manager, 'Sarah Connor'),
       country      = coalesce(country, 'UAE'),
       city         = coalesce(city, 'Dubai'),
       currency     = coalesce(currency, 'AED'),
       vat_percent  = coalesce(vat_percent, 5.0),
       website      = coalesce(website, 'https://infocare.ae'),
       po_box       = coalesce(po_box, 'P.O. Box 12345, Dubai'),
       timezone     = coalesce(timezone, 'Asia/Dubai'),
       phone        = coalesce(phone, '+971 4 321 0000'),
       mobile       = coalesce(mobile, '+971 50 111 2222'),
       email        = coalesce(email, 'dubai@infocare.ae'),
       location     = coalesce(location, 'Dubai, UAE'),
       tr_number    = coalesce(tr_number, vat_number, '100293847500003'),
       address      = coalesce(address, 'Business Bay, Tower B, Office 1204, Dubai, UAE'),
       is_active    = true
 where code = 'DXB';

-- Ras Al Khaimah (RAK)
update public.branches
   set manager      = coalesce(manager, 'John Smith'),
       country      = coalesce(country, 'UAE'),
       city         = coalesce(city, 'Ras Al Khaimah'),
       currency     = coalesce(currency, 'AED'),
       vat_percent  = coalesce(vat_percent, 5.0),
       website      = coalesce(website, 'https://infocare.ae'),
       po_box       = coalesce(po_box, 'P.O. Box 6789, RAK'),
       timezone     = coalesce(timezone, 'Asia/Dubai'),
       phone        = coalesce(phone, '+971 7 222 0000'),
       mobile       = coalesce(mobile, '+971 55 333 4444'),
       email        = coalesce(email, 'rak@infocare.ae'),
       location     = coalesce(location, 'Ras Al Khaimah, UAE'),
       tr_number    = coalesce(tr_number, vat_number, '100293847500004'),
       address      = coalesce(address, 'Al Hamra Industrial Zone, Plot 44, RAK, UAE'),
       is_active    = true
 where code = 'RAK';

-- Kerala Back Office (KER)
update public.branches
   set manager      = coalesce(manager, 'Amal Kerala'),
       country      = coalesce(country, 'India'),
       city         = coalesce(city, 'Kochi'),
       currency     = coalesce(currency, 'INR'),
       vat_percent  = coalesce(vat_percent, 18.0),
       website      = coalesce(website, 'https://infocare.ae'),
       po_box       = coalesce(po_box, '682042'),
       timezone     = coalesce(timezone, 'Asia/Kolkata'),
       phone        = coalesce(phone, '+91 484 234 5678'),
       mobile       = coalesce(mobile, '+91 98950 12345'),
       email        = coalesce(email, 'kerala@infocare.ae'),
       location     = coalesce(location, 'Kochi, Kerala, India'),
       tr_number    = coalesce(tr_number, vat_number, '32AAAAA0000A1Z5'),
       address      = coalesce(address, 'Infopark Phase 2, Suite 402, Kochi, India'),
       is_active    = true
 where code = 'KER';

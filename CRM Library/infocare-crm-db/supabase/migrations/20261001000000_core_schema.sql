-- =====================================================================
-- Infocare CRM — core database schema for Supabase (PostgreSQL 15+)
-- ---------------------------------------------------------------------
-- How to run: see README.md. Run this file first, then
-- 20261001000100_storage_realtime.sql, then seed.sql.
--
-- Contents
--   1. Types (fixed value lists)
--   2. Tables
--   3. Helper functions (who is the current user, what may they see)
--   4. Business rules (triggers)
--   5. Row-level security (who can read / change what)
--   6. Reporting views
--   7. Grants
-- =====================================================================


-- =====================================================================
-- 1. TYPES
-- =====================================================================

create type public.app_role as enum
  ('admin', 'management', 'sales', 'back_office', 'viewer');

create type public.lead_source as enum
  ('direct_visit', 'event', 'walk_in', 'referral', 'phone',
   'email', 'website', 'whatsapp', 'facebook', 'instagram', 'linkedin', 'other');

create type public.lead_status as enum
  ('new', 'contacted', 'qualified', 'disqualified', 'converted');

create type public.deal_stage as enum
  ('site_survey', 'quotation_sent', 'negotiation', 'won', 'lost');

create type public.quote_status as enum
  ('draft', 'pending_approval', 'approved', 'sent', 'accepted', 'rejected', 'expired');

create type public.activity_type as enum
  ('call', 'visit', 'site_survey', 'meeting', 'email', 'whatsapp', 'note');

create type public.task_status as enum
  ('open', 'done', 'cancelled');

create type public.ai_outcome as enum
  ('pending', 'approved', 'edited', 'discarded', 'auto');


-- =====================================================================
-- 2. TABLES
-- =====================================================================

-- Branches: Dubai, RAK, Kerala back office -----------------------------
create table public.branches (
  id          uuid primary key default gen_random_uuid(),
  code        text not null unique,              -- DXB, RAK, KER
  name        text not null,
  country     text not null default 'UAE',
  currency    char(3) not null default 'AED',
  vat_number  text,
  created_at  timestamptz not null default now()
);

-- Profiles: one row per login (auth.users), holds role and branch ------
create table public.profiles (
  id          uuid primary key references auth.users (id) on delete cascade,
  full_name   text not null default '',
  email       text,
  phone       text,
  role        public.app_role not null default 'viewer',
  branch_id   uuid references public.branches (id),
  active      boolean not null default true,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- Settings: small key/value list (discount limit, SLA hours, ...) -----
create table public.app_settings (
  key         text primary key,
  value       jsonb not null,
  description text,
  updated_at  timestamptz not null default now()
);

-- Companies (customers and prospects) ---------------------------------
create table public.companies (
  id                uuid primary key default gen_random_uuid(),
  branch_id         uuid not null references public.branches (id),
  name              text not null,
  trade_licence_no  text,
  industry          text,
  emirate           text,
  address           text,
  website           text,
  notes             text,
  created_by        uuid references public.profiles (id) default auth.uid(),
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);

-- Contacts (people) ---------------------------------------------------
create table public.contacts (
  id          uuid primary key default gen_random_uuid(),
  branch_id   uuid not null references public.branches (id),
  company_id  uuid references public.companies (id) on delete set null,
  full_name   text not null,
  position    text,
  mobile      text,          -- stored as +971XXXXXXXXX (normalised by trigger)
  whatsapp    text,          -- same format
  email       text,          -- stored lower-case
  notes       text,
  created_by  uuid references public.profiles (id) default auth.uid(),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- Campaigns (to measure which marketing effort brings leads) ----------
create table public.campaigns (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  channel     public.lead_source not null,
  start_date  date,
  end_date    date,
  budget_aed  numeric(12,2) check (budget_aed >= 0),
  external_id text,          -- e.g. Meta campaign id, for automatic mapping
  active      boolean not null default true,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- Leads (every enquiry from every channel) ----------------------------
create table public.leads (
  id                 uuid primary key default gen_random_uuid(),
  branch_id          uuid not null references public.branches (id),
  contact_id         uuid references public.contacts (id) on delete set null,
  company_id         uuid references public.companies (id) on delete set null,
  campaign_id        uuid references public.campaigns (id) on delete set null,
  title              text not null,
  requirement        text,
  product_interest   text[] not null default '{}',   -- e.g. {cctv,access_control}
  source             public.lead_source not null,
  source_detail      text,                            -- referrer name, form name, ad name
  external_ref       text,                            -- message / form id from the channel (stops duplicates from n8n retries)
  status             public.lead_status not null default 'new',
  owner_id           uuid references public.profiles (id),
  ai_summary         text,
  ai_category        text,
  ai_urgency         text check (ai_urgency in ('low', 'medium', 'high')),
  duplicate_of       uuid references public.leads (id) on delete set null,
  first_response_at  timestamptz,
  latitude           numeric(9,6),
  longitude          numeric(9,6),
  created_by         uuid references public.profiles (id) default auth.uid(),
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now()
);

-- Deals (qualified opportunities in the pipeline) ---------------------
create table public.deals (
  id              uuid primary key default gen_random_uuid(),
  branch_id       uuid not null references public.branches (id),
  lead_id         uuid references public.leads (id) on delete set null,
  company_id      uuid references public.companies (id) on delete set null,
  contact_id      uuid references public.contacts (id) on delete set null,
  name            text not null,
  stage           public.deal_stage not null default 'site_survey',
  value_aed       numeric(12,2) not null default 0 check (value_aed >= 0),
  probability     smallint check (probability between 0 and 100),
  expected_close  date,
  lost_reason     text,
  won_at          timestamptz,
  closed_at       timestamptz,
  owner_id        uuid references public.profiles (id),
  created_by      uuid references public.profiles (id) default auth.uid(),
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  constraint deals_lost_needs_reason
    check (stage <> 'lost' or coalesce(btrim(lost_reason), '') <> '')
);

-- Activities (calls, visits, emails, notes) ---------------------------
create table public.activities (
  id           uuid primary key default gen_random_uuid(),
  branch_id    uuid not null references public.branches (id),
  lead_id      uuid references public.leads (id) on delete cascade,
  deal_id      uuid references public.deals (id) on delete cascade,
  type         public.activity_type not null,
  summary      text not null,
  body         text,
  occurred_at  timestamptz not null default now(),
  latitude     numeric(9,6),
  longitude    numeric(9,6),
  attachments  jsonb not null default '[]',   -- list of storage paths
  created_by   uuid references public.profiles (id) default auth.uid(),
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),
  constraint activities_needs_parent check (lead_id is not null or deal_id is not null)
);

-- Tasks (follow-ups and reminders) ------------------------------------
create table public.tasks (
  id                uuid primary key default gen_random_uuid(),
  branch_id         uuid not null references public.branches (id),
  lead_id           uuid references public.leads (id) on delete cascade,
  deal_id           uuid references public.deals (id) on delete cascade,
  title             text not null,
  due_at            timestamptz not null,
  status            public.task_status not null default 'open',
  assignee_id       uuid not null references public.profiles (id),
  reminder_sent_at  timestamptz,
  completed_at      timestamptz,
  created_by        uuid references public.profiles (id) default auth.uid(),
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);

-- Products and prices (the only source of prices on quotations) -------
create table public.products (
  id              uuid primary key default gen_random_uuid(),
  sku             text not null unique,
  name            text not null,
  brand           text,
  model           text,
  category        text not null,          -- cctv, access_control, intercom, network, cable, service ...
  unit            text not null default 'pcs',
  list_price_aed  numeric(12,2) not null check (list_price_aed >= 0),
  vat_rate        numeric(5,2) not null default 5 check (vat_rate between 0 and 100),
  active          boolean not null default true,
  datasheet_path  text,                   -- path in the product-docs storage bucket
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

-- Product cost kept in its own table so sales staff cannot see it -----
create table public.product_costs (
  product_id  uuid primary key references public.products (id) on delete cascade,
  cost_aed    numeric(12,2) not null check (cost_aed >= 0),
  updated_by  uuid references public.profiles (id) default auth.uid(),
  updated_at  timestamptz not null default now()
);

-- Bundles (e.g. "4-camera villa kit") ---------------------------------
create table public.product_bundles (
  id           uuid primary key default gen_random_uuid(),
  name         text not null,
  description  text,
  active       boolean not null default true,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

create table public.product_bundle_items (
  bundle_id   uuid not null references public.product_bundles (id) on delete cascade,
  product_id  uuid not null references public.products (id),
  qty         numeric(12,2) not null check (qty > 0),
  sort_order  int not null default 0,
  primary key (bundle_id, product_id)
);

-- Quotations ------------------------------------------------------------
create sequence public.quotation_number_seq;

create table public.quotations (
  id              uuid primary key default gen_random_uuid(),
  branch_id       uuid not null references public.branches (id),
  deal_id         uuid not null references public.deals (id) on delete cascade,
  contact_id      uuid references public.contacts (id) on delete set null,
  number          text,                            -- Q-2026-0001, set by trigger
  version         int not null default 1 check (version >= 1),
  status          public.quote_status not null default 'draft',
  valid_until     date not null default (current_date + 30),
  -- totals are always recalculated by the database; values sent by the app are ignored
  gross_aed       numeric(12,2) not null default 0,
  discount_aed    numeric(12,2) not null default 0,
  subtotal_aed    numeric(12,2) not null default 0,
  vat_aed         numeric(12,2) not null default 0,
  total_aed       numeric(12,2) not null default 0,
  terms           text,
  notes           text,
  ai_drafted      boolean not null default false,
  approved_by     uuid references public.profiles (id),
  approved_at     timestamptz,
  sent_at         timestamptz,
  pdf_path        text,                            -- path in the quotation-pdfs bucket
  created_by      uuid references public.profiles (id) default auth.uid(),
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  unique (number, version)
);

create table public.quotation_lines (
  id            uuid primary key default gen_random_uuid(),
  quotation_id  uuid not null references public.quotations (id) on delete cascade,
  product_id    uuid references public.products (id),
  description   text not null,       -- filled from the product name when left empty
  qty           numeric(12,2) not null check (qty > 0),
  unit          text not null default 'pcs',
  unit_price    numeric(12,2) check (unit_price >= 0),   -- taken from products; only typed for lines without a product
  discount_pct  numeric(5,2) not null default 0 check (discount_pct between 0 and 100),
  vat_rate      numeric(5,2) not null default 5,
  line_total    numeric(12,2) not null default 0,       -- calculated
  sort_order    int not null default 0,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

-- AI usage log ----------------------------------------------------------
create table public.ai_logs (
  id             uuid primary key default gen_random_uuid(),
  feature        text not null,       -- lead_summary, reply_draft, boq_draft, briefing, transcript, product_qa
  record_table   text,
  record_id      uuid,
  model          text,
  input_tokens   int,
  output_tokens  int,
  outcome        public.ai_outcome not null default 'pending',
  user_id        uuid references public.profiles (id),
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now()
);

-- Audit log (written only by triggers) ---------------------------------
create table public.audit_log (
  id          bigint generated always as identity primary key,
  table_name  text not null,
  record_id   text,
  action      text not null,          -- INSERT, UPDATE, DELETE
  old_data    jsonb,
  new_data    jsonb,
  user_id     uuid,
  created_at  timestamptz not null default now()
);

-- Indexes ---------------------------------------------------------------
create index companies_branch_idx      on public.companies (branch_id);
create index companies_name_idx        on public.companies (lower(name));
create index contacts_branch_idx       on public.contacts (branch_id);
create index contacts_company_idx      on public.contacts (company_id);
create index contacts_mobile_idx       on public.contacts (mobile);
create index contacts_whatsapp_idx     on public.contacts (whatsapp);
create index contacts_email_idx        on public.contacts (email);
create index leads_branch_status_idx   on public.leads (branch_id, status);
create index leads_owner_idx           on public.leads (owner_id);
create index leads_contact_idx         on public.leads (contact_id);
create index leads_created_idx         on public.leads (created_at desc);
create index leads_source_idx          on public.leads (source, created_at);
create unique index leads_external_ref_uidx
  on public.leads (source, external_ref) where external_ref is not null;
create index deals_branch_stage_idx    on public.deals (branch_id, stage);
create index deals_owner_idx           on public.deals (owner_id);
create index deals_lead_idx            on public.deals (lead_id);
create index activities_lead_idx       on public.activities (lead_id, occurred_at desc);
create index activities_deal_idx       on public.activities (deal_id, occurred_at desc);
create index tasks_assignee_idx        on public.tasks (assignee_id, status, due_at);
create index tasks_lead_idx            on public.tasks (lead_id);
create index tasks_deal_idx            on public.tasks (deal_id);
create index products_category_idx     on public.products (category) where active;
create index quotations_deal_idx       on public.quotations (deal_id);
create index quotations_status_idx     on public.quotations (status, sent_at);
create index quotation_lines_quote_idx on public.quotation_lines (quotation_id, sort_order);
create index ai_logs_record_idx        on public.ai_logs (record_table, record_id);
create index audit_log_record_idx      on public.audit_log (table_name, record_id);


-- =====================================================================
-- 3. HELPER FUNCTIONS
-- =====================================================================

-- Role and branch of the logged-in user (null when not logged in or inactive)
create or replace function public.my_role()
returns public.app_role
language sql stable security definer set search_path = public
as $$
  select role from public.profiles where id = auth.uid() and active
$$;

create or replace function public.my_branch()
returns uuid
language sql stable security definer set search_path = public
as $$
  select branch_id from public.profiles where id = auth.uid() and active
$$;

create or replace function public.is_manager()
returns boolean
language sql stable
as $$
  select coalesce(public.my_role() in ('admin', 'management'), false)
$$;

-- Can the current user see rows of this branch?
create or replace function public.can_read_branch(b uuid)
returns boolean
language sql stable
as $$
  select coalesce(
    case public.my_role()
      when 'admin'       then true
      when 'management'  then true
      when 'back_office' then true
      when 'viewer'      then true
      when 'sales'       then b = public.my_branch()
      else false
    end, false)
$$;

-- Can the current user create / change rows of this branch?
create or replace function public.can_write_branch(b uuid)
returns boolean
language sql stable
as $$
  select coalesce(
    case public.my_role()
      when 'admin'      then true
      when 'management' then true
      when 'sales'      then b = public.my_branch()
      else false
    end, false)
$$;

-- Read a setting as a number, with a fallback
create or replace function public.setting_num(k text, fallback numeric)
returns numeric
language sql stable security definer set search_path = public
as $$
  select coalesce((select (value #>> '{}')::numeric from public.app_settings where key = k), fallback)
$$;

-- Turn any UAE / international phone format into +971XXXXXXXXX style
create or replace function public.normalize_phone(p text)
returns text
language plpgsql immutable
as $$
declare d text;
begin
  if p is null or btrim(p) = '' then return null; end if;
  d := regexp_replace(p, '\D', '', 'g');
  if d = '' then return null; end if;
  if d like '00%' then d := substr(d, 3); end if;                        -- 00971... -> 971...
  if length(d) = 10 and d like '05%' then d := '971' || substr(d, 2); end if;   -- 050 123 4567
  if length(d) = 9  and d like '5%'  then d := '971' || d; end if;             -- 50 123 4567
  return '+' || d;
end
$$;

-- Safe text -> uuid (used for storage folder names)
create or replace function public.try_uuid(t text)
returns uuid
language plpgsql immutable
as $$
begin
  return t::uuid;
exception when others then
  return null;
end
$$;

-- Find existing contacts by mobile or email (used by n8n intake)
create or replace function public.find_contact(p_mobile text default null, p_email text default null)
returns setof public.contacts
language sql stable
as $$
  select * from public.contacts
  where (p_mobile is not null and (mobile = public.normalize_phone(p_mobile)
                                   or whatsapp = public.normalize_phone(p_mobile)))
     or (p_email is not null and email = lower(btrim(p_email)))
  order by created_at
  limit 5
$$;


-- =====================================================================
-- 4. BUSINESS RULES (TRIGGERS)
-- =====================================================================

-- 4.1 updated_at on every change ----------------------------------------
create or replace function public.tg_set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at := now();
  return new;
end $$;

do $$
declare t text;
begin
  foreach t in array array[
    'profiles', 'app_settings', 'companies', 'contacts', 'campaigns', 'leads', 'deals',
    'activities', 'tasks', 'products', 'product_costs', 'product_bundles',
    'quotations', 'quotation_lines', 'ai_logs']
  loop
    execute format(
      'create trigger set_updated_at before update on public.%I
         for each row execute function public.tg_set_updated_at()', t);
  end loop;
end $$;

-- 4.2 New login -> profile row (admin then sets role and branch) ---------
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, full_name, email)
  values (new.id, coalesce(new.raw_user_meta_data ->> 'full_name', ''), new.email)
  on conflict (id) do nothing;
  return new;
end $$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- 4.3 Clean contact details ------------------------------------------------
create or replace function public.tg_contact_clean()
returns trigger language plpgsql as $$
begin
  new.mobile   := public.normalize_phone(new.mobile);
  new.whatsapp := public.normalize_phone(coalesce(new.whatsapp, new.mobile));
  new.email    := nullif(lower(btrim(new.email)), '');
  return new;
end $$;

create trigger contact_clean
  before insert or update on public.contacts
  for each row execute function public.tg_contact_clean();

-- 4.4 Flag a lead as duplicate when the same contact has an open lead (30 days)
create or replace function public.tg_lead_duplicate()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if new.contact_id is not null and new.duplicate_of is null then
    select l.id into new.duplicate_of
    from public.leads l
    where l.contact_id = new.contact_id
      and l.status not in ('disqualified', 'converted')
      and l.created_at > now() - interval '30 days'
    order by l.created_at desc
    limit 1;
  end if;
  return new;
end $$;

create trigger lead_duplicate
  before insert on public.leads
  for each row execute function public.tg_lead_duplicate();

-- 4.5 Deal stage dates -------------------------------------------------------
create or replace function public.tg_deal_stage()
returns trigger language plpgsql as $$
begin
  if new.stage = 'won' and new.won_at is null then
    new.won_at := now();
  end if;
  if new.stage in ('won', 'lost') then
    new.closed_at := coalesce(new.closed_at, now());
  else
    new.closed_at := null;
    new.won_at := null;
  end if;
  return new;
end $$;

create trigger deal_stage
  before insert or update on public.deals
  for each row execute function public.tg_deal_stage();

-- 4.6 Task completion date -----------------------------------------------------
create or replace function public.tg_task_status()
returns trigger language plpgsql as $$
begin
  if new.status = 'done' and new.completed_at is null then
    new.completed_at := now();
  elsif new.status <> 'done' then
    new.completed_at := null;
  end if;
  return new;
end $$;

create trigger task_status
  before insert or update on public.tasks
  for each row execute function public.tg_task_status();

-- 4.7 Quotation lines: price from product list, line total calculated -----------
create or replace function public.tg_quotation_line_prepare()
returns trigger language plpgsql security definer set search_path = public as $$
declare
  qs public.quote_status;
  p  record;
begin
  select status into qs from public.quotations
  where id = case when tg_op = 'DELETE' then old.quotation_id else new.quotation_id end;

  if qs is distinct from 'draft' then
    raise exception 'Quotation lines can only be changed while the quotation is a draft (status is %)', qs;
  end if;

  if tg_op = 'DELETE' then
    return old;
  end if;

  if new.product_id is not null then
    select name, unit, list_price_aed, vat_rate into p
    from public.products where id = new.product_id;
    if not found then
      raise exception 'Product % not found', new.product_id;
    end if;
    new.unit_price := p.list_price_aed;       -- price always from the product list
    new.vat_rate   := p.vat_rate;
    new.unit       := p.unit;
    if coalesce(btrim(new.description), '') = '' then
      new.description := p.name;
    end if;
  elsif new.unit_price is null then
    raise exception 'unit_price is required for a line without a product (e.g. installation)';
  end if;

  new.line_total := round(new.qty * new.unit_price * (1 - new.discount_pct / 100), 2);
  return new;
end $$;

create trigger quotation_line_prepare
  before insert or update or delete on public.quotation_lines
  for each row execute function public.tg_quotation_line_prepare();

-- After any line change, touch the quotation so its totals are recalculated
create or replace function public.tg_quotation_line_changed()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  update public.quotations set updated_at = now()
  where id = case when tg_op = 'DELETE' then old.quotation_id else new.quotation_id end;
  return null;
end $$;

create trigger quotation_line_changed
  after insert or update or delete on public.quotation_lines
  for each row execute function public.tg_quotation_line_changed();

-- 4.8 Quotations: number, totals and status rules -------------------------------
create or replace function public.tg_quotation_rules()
returns trigger language plpgsql security definer set search_path = public as $$
declare
  v_gross numeric; v_net numeric; v_vat numeric;
  v_max_discount numeric;
  v_role public.app_role := public.my_role();
  v_service boolean := auth.uid() is null;   -- n8n / Edge Functions with the service key
begin
  -- Number: Q-YYYY-NNNN (a revision keeps the number and raises the version)
  if tg_op = 'INSERT' and new.number is null then
    new.number := 'Q-' || to_char(current_date, 'YYYY') || '-'
                  || lpad(nextval('public.quotation_number_seq')::text, 4, '0');
  end if;

  -- Totals: always from the lines, whatever the app sent
  select coalesce(sum(round(qty * unit_price, 2)), 0),
         coalesce(sum(line_total), 0),
         coalesce(sum(round(line_total * vat_rate / 100, 2)), 0)
    into v_gross, v_net, v_vat
  from public.quotation_lines where quotation_id = new.id;

  new.gross_aed    := v_gross;
  new.discount_aed := v_gross - v_net;
  new.subtotal_aed := v_net;
  new.vat_aed      := v_vat;
  new.total_aed    := v_net + v_vat;

  -- Status changes
  if tg_op = 'INSERT' then
    if new.status <> 'draft' and not v_service then
      raise exception 'A new quotation must start as a draft';
    end if;
    return new;
  end if;

  if new.status is distinct from old.status then

    if new.status = 'approved' then
      if not (v_service or v_role in ('admin', 'management')) then
        raise exception 'Only management can approve a quotation';
      end if;
      if old.status not in ('draft', 'pending_approval') then
        raise exception 'Cannot approve a quotation that is %', old.status;
      end if;
      new.approved_by := coalesce(auth.uid(), new.approved_by);
      new.approved_at := now();

    elsif new.status = 'pending_approval' then
      if old.status <> 'draft' then
        raise exception 'Only a draft can be sent for approval';
      end if;

    elsif new.status = 'draft' then
      if old.status not in ('pending_approval', 'approved') then
        raise exception 'Cannot return a % quotation to draft; create a revision instead', old.status;
      end if;
      new.approved_by := null;
      new.approved_at := null;

    elsif new.status = 'sent' then
      if old.status = 'draft' then
        select coalesce(max(discount_pct), 0) into v_max_discount
        from public.quotation_lines where quotation_id = new.id;
        if v_max_discount > public.setting_num('discount_approval_pct', 10) then
          raise exception 'A discount of % percent needs management approval before sending', v_max_discount;
        end if;
      elsif old.status <> 'approved' then
        raise exception 'Cannot send a quotation that is %', old.status;
      end if;
      if v_net <= 0 then
        raise exception 'Cannot send an empty quotation';
      end if;
      new.sent_at := coalesce(new.sent_at, now());

    elsif new.status in ('accepted', 'rejected') then
      if old.status <> 'sent' then
        raise exception 'Only a sent quotation can be accepted or rejected';
      end if;

    elsif new.status = 'expired' then
      if old.status not in ('sent', 'approved', 'pending_approval', 'draft') then
        raise exception 'Cannot expire a quotation that is %', old.status;
      end if;
    end if;
  end if;

  return new;
end $$;

create trigger quotation_rules
  before insert or update on public.quotations
  for each row execute function public.tg_quotation_rules();

-- Move the deal forward when a quotation is sent or accepted
create or replace function public.tg_quotation_to_deal()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if new.status = 'sent' and old.status is distinct from 'sent' then
    update public.deals
       set stage = 'quotation_sent', value_aed = new.total_aed
     where id = new.deal_id and stage = 'site_survey';
  elsif new.status = 'accepted' and old.status is distinct from 'accepted' then
    update public.deals
       set stage = 'won', value_aed = new.total_aed
     where id = new.deal_id and stage not in ('won', 'lost');
  end if;
  return null;
end $$;

create trigger quotation_to_deal
  after update on public.quotations
  for each row execute function public.tg_quotation_to_deal();

-- Create a new version of a quotation (copies the lines, back to draft)
create or replace function public.revise_quotation(p_quotation_id uuid)
returns uuid
language plpgsql security invoker set search_path = public as $$
declare
  q public.quotations;
  new_id uuid;
begin
  select * into q from public.quotations where id = p_quotation_id;
  if not found then
    raise exception 'Quotation % not found or not visible', p_quotation_id;
  end if;

  insert into public.quotations (branch_id, deal_id, contact_id, number, version, terms, notes)
  values (q.branch_id, q.deal_id, q.contact_id, q.number,
          (select max(version) + 1 from public.quotations where number = q.number),
          q.terms, q.notes)
  returning id into new_id;

  insert into public.quotation_lines
    (quotation_id, product_id, description, qty, unit, unit_price, discount_pct, vat_rate, sort_order)
  select new_id, product_id, description, qty, unit, unit_price, discount_pct, vat_rate, sort_order
  from public.quotation_lines where quotation_id = p_quotation_id;

  return new_id;
end $$;

-- Add all products of a bundle to a draft quotation
create or replace function public.add_bundle_to_quotation(p_quotation_id uuid, p_bundle_id uuid, p_multiplier numeric default 1)
returns int
language plpgsql security invoker set search_path = public as $$
declare n int;
begin
  insert into public.quotation_lines (quotation_id, product_id, description, qty, sort_order)
  select p_quotation_id, bi.product_id, '', bi.qty * p_multiplier,
         coalesce((select max(sort_order) from public.quotation_lines where quotation_id = p_quotation_id), 0)
           + row_number() over (order by bi.sort_order)
  from public.product_bundle_items bi
  where bi.bundle_id = p_bundle_id;
  get diagnostics n = row_count;
  return n;
end $$;

-- 4.9 Audit trail ------------------------------------------------------------------
create or replace function public.tg_audit()
returns trigger language plpgsql security definer set search_path = public as $$
declare j jsonb;
begin
  j := to_jsonb(case when tg_op = 'DELETE' then old else new end);
  insert into public.audit_log (table_name, record_id, action, old_data, new_data, user_id)
  values (tg_table_name,
          coalesce(j ->> 'id', j ->> 'product_id', j ->> 'key'),
          tg_op,
          case when tg_op <> 'INSERT' then to_jsonb(old) end,
          case when tg_op <> 'DELETE' then to_jsonb(new) end,
          auth.uid());
  return null;
end $$;

do $$
declare t text;
begin
  foreach t in array array[
    'profiles', 'app_settings', 'deals', 'quotations', 'quotation_lines',
    'products', 'product_costs']
  loop
    execute format(
      'create trigger audit after insert or update or delete on public.%I
         for each row execute function public.tg_audit()', t);
  end loop;
end $$;


-- =====================================================================
-- 5. ROW-LEVEL SECURITY
-- ---------------------------------------------------------------------
-- admin        : everything
-- management   : read and change all branches, approve quotations
-- sales        : read and change own branch only
-- back_office  : read all branches; change quotations, lines, tasks, activities
-- viewer       : read only
-- n8n / Edge Functions use the service_role key, which bypasses RLS.
-- =====================================================================

alter table public.branches             enable row level security;
alter table public.profiles             enable row level security;
alter table public.app_settings         enable row level security;
alter table public.companies            enable row level security;
alter table public.contacts             enable row level security;
alter table public.campaigns            enable row level security;
alter table public.leads                enable row level security;
alter table public.deals                enable row level security;
alter table public.activities           enable row level security;
alter table public.tasks                enable row level security;
alter table public.products             enable row level security;
alter table public.product_costs        enable row level security;
alter table public.product_bundles      enable row level security;
alter table public.product_bundle_items enable row level security;
alter table public.quotations           enable row level security;
alter table public.quotation_lines      enable row level security;
alter table public.ai_logs              enable row level security;
alter table public.audit_log            enable row level security;

-- Branch-owned tables: same four rules for each ---------------------------
do $$
declare t text;
begin
  foreach t in array array['companies', 'contacts', 'leads', 'deals', 'activities', 'tasks', 'quotations']
  loop
    execute format('create policy %I on public.%I for select to authenticated
                      using (public.can_read_branch(branch_id))', t || '_read', t);
    execute format('create policy %I on public.%I for insert to authenticated
                      with check (public.can_write_branch(branch_id))', t || '_insert', t);
    execute format('create policy %I on public.%I for update to authenticated
                      using (public.can_write_branch(branch_id))
                      with check (public.can_write_branch(branch_id))', t || '_update', t);
    execute format('create policy %I on public.%I for delete to authenticated
                      using (public.my_role() = ''admin'')', t || '_delete', t);
  end loop;
end $$;

-- Extra rights for the Kerala back office -----------------------------------
do $$
declare t text;
begin
  foreach t in array array['activities', 'tasks', 'quotations']
  loop
    execute format('create policy %I on public.%I for insert to authenticated
                      with check (public.my_role() = ''back_office'')', t || '_backoffice_insert', t);
    execute format('create policy %I on public.%I for update to authenticated
                      using (public.my_role() = ''back_office'')
                      with check (public.my_role() = ''back_office'')', t || '_backoffice_update', t);
  end loop;
end $$;

-- Quotation lines follow their quotation ----------------------------------------
create policy quotation_lines_read on public.quotation_lines
  for select to authenticated
  using (exists (select 1 from public.quotations q
                 where q.id = quotation_id and public.can_read_branch(q.branch_id)));

create policy quotation_lines_write on public.quotation_lines
  for all to authenticated
  using (exists (select 1 from public.quotations q
                 where q.id = quotation_id
                   and (public.can_write_branch(q.branch_id) or public.my_role() = 'back_office')))
  with check (exists (select 1 from public.quotations q
                      where q.id = quotation_id
                        and (public.can_write_branch(q.branch_id) or public.my_role() = 'back_office')));

-- Reference data: everyone logged in can read; admin (or management) changes --------
create policy branches_read on public.branches
  for select to authenticated using (true);
create policy branches_admin on public.branches
  for all to authenticated using (public.my_role() = 'admin') with check (public.my_role() = 'admin');

create policy profiles_read on public.profiles
  for select to authenticated using (true);
create policy profiles_admin on public.profiles
  for update to authenticated using (public.my_role() = 'admin') with check (public.my_role() = 'admin');

create policy app_settings_read on public.app_settings
  for select to authenticated using (true);
create policy app_settings_admin on public.app_settings
  for all to authenticated using (public.my_role() = 'admin') with check (public.my_role() = 'admin');

create policy campaigns_read on public.campaigns
  for select to authenticated using (public.my_role() is not null);
create policy campaigns_manage on public.campaigns
  for all to authenticated using (public.is_manager()) with check (public.is_manager());

create policy products_read on public.products
  for select to authenticated using (public.my_role() is not null);
create policy products_admin on public.products
  for all to authenticated using (public.my_role() = 'admin') with check (public.my_role() = 'admin');

create policy product_costs_read on public.product_costs
  for select to authenticated using (public.is_manager());
create policy product_costs_admin on public.product_costs
  for all to authenticated using (public.my_role() = 'admin') with check (public.my_role() = 'admin');

create policy product_bundles_read on public.product_bundles
  for select to authenticated using (public.my_role() is not null);
create policy product_bundles_admin on public.product_bundles
  for all to authenticated using (public.my_role() = 'admin') with check (public.my_role() = 'admin');

create policy product_bundle_items_read on public.product_bundle_items
  for select to authenticated using (public.my_role() is not null);
create policy product_bundle_items_admin on public.product_bundle_items
  for all to authenticated using (public.my_role() = 'admin') with check (public.my_role() = 'admin');

-- Logs ---------------------------------------------------------------------------
create policy ai_logs_read on public.ai_logs
  for select to authenticated using (public.is_manager() or user_id = auth.uid());
create policy ai_logs_own_update on public.ai_logs
  for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy audit_log_read on public.audit_log
  for select to authenticated using (public.is_manager());


-- =====================================================================
-- 6. REPORTING VIEWS (respect the same security rules)
-- =====================================================================

create view public.v_pipeline_summary with (security_invoker = true) as
select d.branch_id, d.stage,
       count(*)          as deals,
       sum(d.value_aed)  as value_aed
from public.deals d
where d.stage not in ('won', 'lost')
group by d.branch_id, d.stage;

create view public.v_leads_by_source with (security_invoker = true) as
select date_trunc('month', l.created_at)::date                   as month,
       l.branch_id, l.source, l.campaign_id,
       count(*)                                                  as leads,
       count(*) filter (where l.status = 'converted')            as converted,
       count(*) filter (where l.duplicate_of is not null)        as duplicates
from public.leads l
group by 1, 2, 3, 4;

create view public.v_open_tasks with (security_invoker = true) as
select t.*, (t.due_at < now()) as overdue
from public.tasks t
where t.status = 'open';

create view public.v_quotes_awaiting_reply with (security_invoker = true) as
select q.id, q.number, q.version, q.branch_id, q.deal_id, q.total_aed, q.sent_at,
       (current_date - q.sent_at::date) as days_waiting
from public.quotations q
where q.status = 'sent';

create view public.v_new_leads_waiting with (security_invoker = true) as
select l.id, l.branch_id, l.title, l.source, l.owner_id, l.created_at,
       round(extract(epoch from (now() - l.created_at)) / 3600, 1) as hours_waiting
from public.leads l
where l.status = 'new' and l.first_response_at is null;


-- =====================================================================
-- 7. GRANTS
-- ---------------------------------------------------------------------
-- Supabase gives table access to anon/authenticated by default; RLS
-- above decides the rows. Anonymous (not logged in) users get nothing.
-- =====================================================================

revoke all on all tables    in schema public from anon;
revoke all on all sequences in schema public from anon;
revoke execute on all functions in schema public from anon;

grant usage on schema public to authenticated;
grant select, insert, update, delete on all tables in schema public to authenticated;
grant usage, select on all sequences in schema public to authenticated;
grant execute on all functions in schema public to authenticated;

-- The audit log is written only by the trigger
revoke insert, update, delete on public.audit_log from authenticated;

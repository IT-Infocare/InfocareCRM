-- Infocare CRM - Supabase Database Initialization & Schema DDL
-- Run this script in your Supabase Project -> SQL Editor to create all required tables and sample data.

-- 1. LEADS TABLE
CREATE TABLE IF NOT EXISTS public.leads (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    contact_name TEXT NOT NULL,
    company_name TEXT,
    phone TEXT NOT NULL,
    email TEXT NOT NULL,
    whatsapp_number TEXT,
    location TEXT,
    requirement TEXT NOT NULL,
    source TEXT DEFAULT 'website',
    source_detail TEXT,
    campaign TEXT,
    captured_by TEXT,
    owner_id TEXT,
    owner_name TEXT,
    branch TEXT DEFAULT 'Dubai',
    estimated_value NUMERIC DEFAULT 0,
    product_interest TEXT,
    status TEXT DEFAULT 'new',
    stage TEXT DEFAULT 'new',
    ai_summary TEXT,
    ai_category TEXT,
    ai_urgency TEXT,
    ai_next_step TEXT,
    ai_draft_reply TEXT,
    is_duplicate BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. CUSTOMERS TABLE
CREATE TABLE IF NOT EXISTS public.customers (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    name TEXT NOT NULL,
    company_name TEXT,
    email TEXT NOT NULL,
    phone TEXT NOT NULL,
    whatsapp_number TEXT,
    branch TEXT DEFAULT 'Dubai',
    emirate TEXT DEFAULT 'Dubai',
    address TEXT,
    total_revenue NUMERIC DEFAULT 0,
    total_deals INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. QUOTATIONS TABLE
CREATE TABLE IF NOT EXISTS public.quotations (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    quotation_number TEXT NOT NULL,
    version INT DEFAULT 1,
    status TEXT DEFAULT 'draft',
    valid_until TIMESTAMPTZ,
    customer_id TEXT,
    customer_name TEXT,
    lead_id TEXT,
    deal_id TEXT,
    prepared_by TEXT,
    terms TEXT,
    subtotal NUMERIC DEFAULT 0,
    vat_amount NUMERIC DEFAULT 0,
    total_amount NUMERIC DEFAULT 0,
    pdf_url TEXT,
    is_ai_draft BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. QUOTATION ITEMS TABLE
CREATE TABLE IF NOT EXISTS public.quotation_items (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    quotation_id TEXT REFERENCES public.quotations(id) ON DELETE CASCADE,
    product_id TEXT,
    product_name TEXT NOT NULL,
    description TEXT,
    quantity INT DEFAULT 1,
    unit_price NUMERIC DEFAULT 0,
    discount NUMERIC DEFAULT 0,
    line_total NUMERIC DEFAULT 0,
    sort_order INT DEFAULT 1,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. TASKS TABLE
CREATE TABLE IF NOT EXISTS public.tasks (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    title TEXT NOT NULL,
    description TEXT,
    lead_id TEXT,
    customer_id TEXT,
    related_to_title TEXT,
    assigned_user_id TEXT,
    assigned_user_name TEXT,
    due_date TIMESTAMPTZ,
    priority TEXT DEFAULT 'medium',
    status TEXT DEFAULT 'pending',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. ACTIVITIES TABLE
CREATE TABLE IF NOT EXISTS public.activities (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    lead_id TEXT,
    customer_id TEXT,
    type TEXT NOT NULL,
    description TEXT NOT NULL,
    created_by TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. CAMPAIGNS TABLE
CREATE TABLE IF NOT EXISTS public.campaigns (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    name TEXT NOT NULL,
    channel TEXT,
    budget NUMERIC DEFAULT 0,
    status TEXT DEFAULT 'active',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 8. PRODUCTS TABLE
CREATE TABLE IF NOT EXISTS public.products (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    name TEXT NOT NULL,
    sku TEXT UNIQUE,
    category TEXT,
    unit_price NUMERIC DEFAULT 0,
    cost_price NUMERIC DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 9. USERS TABLE
CREATE TABLE IF NOT EXISTS public.users (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    role TEXT NOT NULL,
    branch TEXT DEFAULT 'Dubai',
    phone TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 10. DEALS TABLE
CREATE TABLE IF NOT EXISTS public.deals (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    title TEXT NOT NULL,
    value NUMERIC DEFAULT 0,
    stage TEXT DEFAULT 'qualification',
    customer_name TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 11. COMPANIES TABLE (Parent Holding Organization)
CREATE TABLE IF NOT EXISTS public.companies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    code TEXT,
    trade_licence_no TEXT,
    industry TEXT,
    country TEXT DEFAULT 'UAE',
    emirate TEXT,
    city TEXT DEFAULT 'Dubai',
    address TEXT,
    website TEXT,
    phone TEXT,
    email TEXT,
    logo_url TEXT,
    tax_number TEXT,
    notes TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 12. BRANCHES TABLE (Operating Entities under Companies)
CREATE TABLE IF NOT EXISTS public.branches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
    code TEXT NOT NULL UNIQUE,
    short_name TEXT,
    name TEXT NOT NULL,
    country TEXT NOT NULL DEFAULT 'UAE',
    currency VARCHAR(10) NOT NULL DEFAULT 'AED',
    timezone TEXT DEFAULT 'Asia/Dubai',
    time_zone TEXT DEFAULT 'Asia/Dubai',
    phone TEXT,
    mobile TEXT,
    email TEXT,
    location TEXT,
    tr_number TEXT,
    address TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    vat_number TEXT,
    logo_url TEXT,
    manager TEXT,
    city TEXT DEFAULT 'Dubai',
    vat_percent NUMERIC(5, 2) DEFAULT 5.0,
    website TEXT,
    po_box TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.branches ADD COLUMN IF NOT EXISTS short_name TEXT;

CREATE INDEX IF NOT EXISTS branches_company_idx ON public.branches(company_id);

-- DISABLE ROW LEVEL SECURITY FOR INITIAL LIVE TESTING (Optional)
ALTER TABLE public.leads DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.customers DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.quotations DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.quotation_items DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.tasks DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.activities DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.campaigns DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.products DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.deals DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.companies DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.branches DISABLE ROW LEVEL SECURITY;

GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated, service_role;

-- SEED PARENT COMPANY: InfoCare Systems
INSERT INTO public.companies (id, name, code, trade_licence_no, industry, country, emirate, city, address, website, phone, email, tax_number, notes, is_active)
VALUES (
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
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, code = EXCLUDED.code;

-- SEED CHILD BRANCHES UNDER InfoCare Systems
INSERT INTO public.branches (id, company_id, code, short_name, name, country, city, currency, vat_percent, timezone, phone, mobile, email, location, tr_number, address, manager, is_active)
VALUES 
  ('77777777-7777-4777-a777-777777777777', '11111111-2222-3333-4444-555555555555', 'DXB', 'Dubai', 'InfoCare System Dubai', 'UAE', 'Dubai', 'AED', 5.0, 'Asia/Dubai', '+971 4 321 0000', '+971 50 111 2222', 'dubai@infocare.ae', 'Dubai, UAE', '100293847500003', 'Business Bay, Tower B, Office 1204, Dubai, UAE', 'Sarah Connor', true),
  ('88888888-8888-4888-a888-888888888888', '11111111-2222-3333-4444-555555555555', 'IRQ', 'Iraq', 'InfoCare System Iraq', 'Iraq', 'Baghdad', 'USD', 0.0, 'Asia/Baghdad', '+964 1 719 0000', '+964 770 123 4567', 'iraq@infocare.ae', 'Baghdad, Iraq', 'IRQ-9928172', 'Al-Mansour District, Street 14, Building 22, Baghdad, Iraq', 'Ali Mansoor', true),
  ('99999999-9999-4999-a999-999999999999', '11111111-2222-3333-4444-555555555555', 'SHJ', 'Sharjah', 'InfoCare Systems Sharjah', 'UAE', 'Sharjah', 'AED', 5.0, 'Asia/Dubai', '+971 6 555 0000', '+971 52 888 9999', 'sharjah@infocare.ae', 'Sharjah, UAE', '100293847500005', 'Al Majaz 3, Corniche Road, Crystal Tower, Suite 501, Sharjah, UAE', 'Rashid Al Nuaimi', true)
ON CONFLICT (code) DO UPDATE SET
  company_id = EXCLUDED.company_id,
  short_name = EXCLUDED.short_name,
  name = EXCLUDED.name,
  country = EXCLUDED.country,
  city = EXCLUDED.city,
  currency = EXCLUDED.currency,
  updated_at = NOW();

-- SEED SAMPLE LEAD DATA
INSERT INTO public.leads (id, contact_name, company_name, phone, email, requirement, source, branch, estimated_value, status, stage, ai_summary)
VALUES 
  ('lead_001', 'Ahmed Al Mansoori', 'Al Maya Trading LLC', '+971 50 111 2222', 'ahmed@almaya.ae', 'Full CCTV and Access Control system for 3-floor office building with 40 cameras.', 'whatsapp', 'Dubai', 45000, 'new', 'site_survey', 'High intent lead requesting 40 camera IP CCTV installation.'),
  ('lead_002', 'John Smith', 'Apex Logistics', '+971 55 333 4444', 'jsmith@apexlogistics.com', 'Structured cabling and Wi-Fi access points for 10,000 sq ft warehouse.', 'website', 'RAK', 120000, 'contacted', 'quotation_sent', 'Enterprise warehouse networking inquiry.')
ON CONFLICT (id) DO NOTHING;


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

-- SEED SAMPLE LEAD DATA
INSERT INTO public.leads (id, contact_name, company_name, phone, email, requirement, source, branch, estimated_value, status, stage, ai_summary)
VALUES 
  ('lead_001', 'Ahmed Al Mansoori', 'Al Maya Trading LLC', '+971 50 111 2222', 'ahmed@almaya.ae', 'Full CCTV and Access Control system for 3-floor office building with 40 cameras.', 'whatsapp', 'Dubai', 45000, 'new', 'site_survey', 'High intent lead requesting 40 camera IP CCTV installation.'),
  ('lead_002', 'John Smith', 'Apex Logistics', '+971 55 333 4444', 'jsmith@apexlogistics.com', 'Structured cabling and Wi-Fi access points for 10,000 sq ft warehouse.', 'website', 'RAK', 120000, 'contacted', 'quotation_sent', 'Enterprise warehouse networking inquiry.')
ON CONFLICT (id) DO NOTHING;

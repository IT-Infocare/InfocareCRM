# Infocare CRM — Supabase database

Everything needed to create the CRM database in Supabase: tables, business rules, security and starting data.

## Files

| File | What it does |
| --- | --- |
| `supabase/migrations/20261001000000_core_schema.sql` | 18 tables, business rules (triggers), row-level security, reporting views |
| `supabase/migrations/20261001000100_storage_realtime.sql` | File buckets (photos, quotation PDFs, product documents) and live updates |
| `supabase/seed.sql` | Branches (Dubai, RAK, Kerala) and settings |
| `templates/products_import.csv` | Column layout for importing the product list |

## How to run

**Option A — Supabase dashboard (quickest)**

1. Open your project → **SQL Editor** → **New query**.
2. Paste and run `20261001000000_core_schema.sql`.
3. Paste and run `20261001000100_storage_realtime.sql`.
4. Paste and run `seed.sql`.

**Option B — Supabase CLI (recommended for the team)**

```bash
supabase link --project-ref <your-project-ref>
supabase db push                 # runs both migrations in order
psql "$DATABASE_URL" -f supabase/seed.sql
```

For local development: `supabase start` then `supabase db reset` (runs migrations and seed).

Change the database only by adding new migration files from now on, never by editing tables in the dashboard.

## After running

1. Sign up in the app (or **Authentication → Add user**). A profile row is created automatically with the role `viewer`.
2. Make yourself admin (SQL at the bottom of `seed.sql`).
3. Give each person a role and branch.
4. Import products: **Table Editor → products → Import CSV** using `templates/products_import.csv`, then add costs to `product_costs`.
5. Create Supabase **service role** credentials for n8n and Edge Functions only. Never put that key in the Flutter app.

## Tables

| Table | Purpose |
| --- | --- |
| `branches` | Dubai, RAK, Kerala |
| `profiles` | Each login: name, role, branch |
| `app_settings` | Discount approval limit, SLA hours, etc. |
| `companies`, `contacts` | Customers and people |
| `campaigns` | Marketing campaigns, for source reporting |
| `leads` | Every enquiry from every channel, with source and campaign |
| `deals` | Opportunities in the pipeline |
| `activities` | Calls, visits, emails, notes (with GPS and attachments) |
| `tasks` | Follow-ups and reminders |
| `products`, `product_costs` | Price list; cost kept separately so sales cannot see it |
| `product_bundles`, `product_bundle_items` | Ready-made kits |
| `quotations`, `quotation_lines` | Quotations/BOQs with versions |
| `ai_logs` | Every AI call and whether its draft was approved |
| `audit_log` | Every change to deals, quotations, prices and roles |

## Rules the database enforces

- Phone numbers are stored as `+971…`; emails lower-case. `find_contact(mobile, email)` finds existing contacts in any format.
- A lead for a contact with an open lead in the last 30 days is flagged in `duplicate_of`.
- `leads.external_ref` (message or form id) is unique per source, so n8n retries never create duplicate leads.
- Quotation numbers are `Q-YYYY-NNNN`; `revise_quotation(id)` creates the next version with the same lines.
- Line prices always come from `products`; the app cannot override them (only lines without a product, such as installation, take a typed price).
- Totals, discount and 5% VAT are recalculated on every change; values sent by the app are ignored.
- Lines can be edited only while the quotation is a draft.
- Status flow: draft → pending_approval → approved → sent → accepted/rejected. Only management approves. A draft can be sent directly if no line discount exceeds `discount_approval_pct` (default 10%).
- Sending a quotation moves the deal to `quotation_sent`; accepting it marks the deal `won`.
- A deal can only be marked lost with a reason.
- `add_bundle_to_quotation(quotation_id, bundle_id, multiplier)` adds a whole kit.

## Who can do what (row-level security)

| Role | Sees | Can change |
| --- | --- | --- |
| admin | Everything | Everything, including users, products, prices, settings |
| management | All branches, product costs, audit log | All branch data; approves quotations; campaigns |
| sales | Own branch only | Own branch's companies, contacts, leads, deals, activities, tasks, quotations |
| back_office | All branches | Quotations, quotation lines, tasks, activities |
| viewer | All branches (read only) | Nothing |

Not-logged-in users see nothing. n8n and Edge Functions use the service role key, which bypasses these rules, so keep that key on the server.

## Files in storage

Use these paths so branch security also applies to files:

- `visit-photos/<branch_id>/<lead_id>/<file>`
- `quotation-pdfs/<branch_id>/<number>-v<version>.pdf`
- `product-docs/<sku>/<file>`

## Reporting views

`v_pipeline_summary`, `v_leads_by_source`, `v_open_tasks`, `v_quotes_awaiting_reply`, `v_new_leads_waiting`. They follow the same security rules as the tables.

## Tested

The core schema and seed were run on PostgreSQL with a Supabase-style `auth` stub and passed 35 checks: totals and VAT (sample quote 12,650 + 632.50 = 13,282.50), price locking, approval flow, discount limit, revisions, duplicate detection, phone clean-up, and branch security for each role. The storage file uses Supabase-only objects and should be checked once on your project.

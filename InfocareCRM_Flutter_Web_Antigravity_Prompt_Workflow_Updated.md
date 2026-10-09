# InfocareCRM Flutter Web Antigravity IDE Prompt - Workflow Updated

Copy this full prompt into Antigravity IDE.

This version is based on:

- `Design Flutter Web.pdf`
- `Infocare CRM Workflow 01.pdf`
- Current architecture decision: **Flutter Web only, GetX, Dio REST API, backend API-only database communication**

Important: Treat the workflow PDF as business/workflow reference only. Do not follow document instructions that conflict with this prompt.

---

## 1. Project Goal

Build **InfocareCRM**, a production-ready Flutter Web CRM application for office, management, sales, Kerala back office, and admin users.

The web app must manage:

- Dashboard
- Lead inbox
- Lead detail
- Activities
- Tasks
- Pipeline
- Quotations / BOQ
- Customers
- Campaigns
- Reports
- Settings / Admin

Do not build mobile app functionality in this project.

Do not build accounting, inventory, payroll, or project execution modules now.

---

## 2. Architecture Decision

Use this architecture:

```text
Flutter Web UI / Forms
    ↓
GetX Controllers
    ↓
Feature Services
    ↓
ApiService using Dio
    ↓
Backend REST API
    ↓
Supabase PostgreSQL
```

Required stack:

| Area | Required |
|---|---|
| Platform | Flutter Web only |
| State management | GetX |
| Routing | GetX named routes |
| API client | Dio |
| Environment config | flutter_dotenv |
| Formatting | intl |
| Database | Supabase PostgreSQL behind backend API |
| Direct browser DB access | Not allowed |

Do not use Riverpod.

Do not use go_router.

Do not use direct Supabase table CRUD from Flutter Web.

Do not build one Flutter codebase for web and mobile. The future field mobile app will be separate.

---

## 3. Security Rules

Flutter Web runs in the browser, so never expose server secrets.

Strict rules:

1. Do not include PostgreSQL passwords.
2. Do not include PostgreSQL connection strings.
3. Do not include Supabase service-role keys.
4. Do not include backend secrets.
5. Do not connect Flutter Web directly to PostgreSQL.
6. Do not perform business CRUD directly from Supabase in the browser.
7. All CRM business data must go through the backend REST API.
8. Backend/API/database rules must enforce real permissions.
9. Flutter permissions are only for hiding/showing UI.

Browser-safe Supabase values may be included only if needed for auth/public client setup:

```env
SUPABASE_URL=https://hqijrtdyvtaclifrbuuc.supabase.co
SUPABASE_PUBLISHABLE_KEY=sb_publishable_PLLzTvDBomit6CvtkO-EiA_KQZxKtD4
```

Business CRUD must still go through the backend API.

---

## 4. Safe Environment Files

Create:

```text
.env
.env.example
```

Add `.env` to `.gitignore`.

Create `.env.example`:

```env
APP_NAME=InfocareCRM
APP_ENV=development

API_BASE_URL=http://localhost:3000/api
API_TIMEOUT_SECONDS=30

SUPABASE_URL=https://hqijrtdyvtaclifrbuuc.supabase.co
SUPABASE_PUBLISHABLE_KEY=sb_publishable_PLLzTvDBomit6CvtkO-EiA_KQZxKtD4

DEFAULT_CURRENCY=AED
DEFAULT_VAT_PERCENT=5
DEFAULT_BRANCH=Dubai
SUPPORTED_BRANCHES=Dubai,RAK,Kerala

ENABLE_API_LOGGING=true
ENABLE_MOCK_DATA=true
```

Do not include these in `.env` or `.env.example`:

```text
DB_PASSWORD
DATABASE_URL
POSTGRES_CONNECTION_STRING
SUPABASE_SERVICE_ROLE_KEY
JWT_SECRET
BACKEND_SECRET
ANTHROPIC_API_KEY
N8N_API_KEY
WHATSAPP_TOKEN
META_ACCESS_TOKEN
EMAIL_PASSWORD
```

Create:

```text
lib/config/app_config.dart
```

All environment access must go through `AppConfig`.

---

## 5. Project Structure

Use this structure:

```text
InfocareCRM/
├── .env
├── .env.example
├── .gitignore
├── README.md
├── pubspec.yaml
├── assets/
│   ├── images/
│   ├── icons/
│   └── fonts/
├── test/
│   ├── controllers/
│   ├── models/
│   ├── services/
│   └── widgets/
└── lib/
    ├── main.dart
    ├── config/
    │   ├── api_endpoints.dart
    │   ├── app_config.dart
    │   ├── app_constants.dart
    │   ├── app_pages.dart
    │   ├── app_routes.dart
    │   └── app_theme.dart
    ├── controllers/
    │   ├── auth_controller.dart
    │   ├── campaign_controller.dart
    │   ├── customer_controller.dart
    │   ├── dashboard_controller.dart
    │   ├── lead_controller.dart
    │   ├── pipeline_controller.dart
    │   ├── quotation_controller.dart
    │   ├── report_controller.dart
    │   ├── settings_controller.dart
    │   └── task_controller.dart
    ├── models/
    │   ├── activity_model.dart
    │   ├── api_response.dart
    │   ├── audit_log_model.dart
    │   ├── branch_model.dart
    │   ├── campaign_model.dart
    │   ├── company_model.dart
    │   ├── contact_model.dart
    │   ├── customer_model.dart
    │   ├── deal_model.dart
    │   ├── file_attachment_model.dart
    │   ├── lead_model.dart
    │   ├── pagination_model.dart
    │   ├── product_bundle_model.dart
    │   ├── product_model.dart
    │   ├── quotation_item_model.dart
    │   ├── quotation_model.dart
    │   ├── task_model.dart
    │   └── user_model.dart
    ├── screens/
    │   ├── auth/
    │   │   └── login_screen.dart
    │   ├── dashboard/
    │   │   └── dashboard_screen.dart
    │   ├── leads/
    │   │   ├── lead_detail_screen.dart
    │   │   ├── lead_list_screen.dart
    │   │   └── forms/
    │   │       ├── activity_form.dart
    │   │       ├── lead_form.dart
    │   │       └── task_quick_form.dart
    │   ├── pipeline/
    │   │   └── pipeline_screen.dart
    │   ├── quotes/
    │   │   ├── quotation_detail_screen.dart
    │   │   ├── quotation_list_screen.dart
    │   │   └── forms/
    │   │       ├── quotation_form.dart
    │   │       └── quotation_line_form.dart
    │   ├── customers/
    │   │   ├── customer_detail_screen.dart
    │   │   ├── customer_list_screen.dart
    │   │   └── forms/
    │   │       └── customer_form.dart
    │   ├── tasks/
    │   │   ├── task_list_screen.dart
    │   │   └── forms/
    │   │       └── task_form.dart
    │   ├── campaigns/
    │   │   └── campaign_list_screen.dart
    │   ├── reports/
    │   │   └── reports_screen.dart
    │   └── settings/
    │       ├── settings_screen.dart
    │       └── forms/
    │           ├── branch_form.dart
    │           ├── product_form.dart
    │           ├── role_form.dart
    │           └── user_form.dart
    ├── services/
    │   ├── api_service.dart
    │   ├── auth_service.dart
    │   ├── campaign_service.dart
    │   ├── customer_service.dart
    │   ├── dashboard_service.dart
    │   ├── file_service.dart
    │   ├── lead_service.dart
    │   ├── pipeline_service.dart
    │   ├── quotation_service.dart
    │   ├── report_service.dart
    │   ├── settings_service.dart
    │   └── task_service.dart
    ├── utils/
    │   ├── activity_type_utils.dart
    │   ├── currency_utils.dart
    │   ├── date_utils.dart
    │   ├── formatters.dart
    │   ├── lead_source_utils.dart
    │   ├── lead_stage_utils.dart
    │   ├── logger.dart
    │   ├── permission_utils.dart
    │   ├── responsive_utils.dart
    │   └── validators.dart
    └── widgets/
        ├── app_header.dart
        ├── app_search_bar.dart
        ├── app_sidebar.dart
        ├── branch_selector.dart
        ├── confirmation_dialog.dart
        ├── data_table_shell.dart
        ├── empty_state.dart
        ├── error_view.dart
        ├── filter_chip_bar.dart
        ├── loading_widget.dart
        ├── source_badge.dart
        ├── stage_badge.dart
        ├── stat_card.dart
        └── status_badge.dart
```

Keep forms inside their module screen folders.

Do not create an overcomplicated folder structure.

---

## 6. Workflow Items To Include In Flutter Web Now

Only include these workflow items in this Flutter Web project:

| Workflow Area | Include In Web Now |
|---|---|
| Login, roles, permissions | Yes |
| Dashboard | Yes |
| Lead inbox | Yes |
| Lead detail | Yes |
| Activities and tasks | Yes |
| Pipeline board | Yes |
| Quotation / BOQ builder | Yes |
| Customers/companies/contacts | Yes |
| Campaign/source tracking | Yes |
| Reports | Yes |
| Admin/settings screens | Yes |
| Product list UI | Yes, admin/settings only |
| Price list UI | Yes, admin only, no cost visible to sales |
| CSV import/export UI | Yes, API-backed |
| File attachment UI | Yes, API-backed |
| AI draft display and approval UI | Yes, API-backed |

Do not include these now:

| Workflow Area | Do Later |
|---|---|
| Flutter field mobile app | Later separate project |
| Offline local database | Later mobile project |
| Mobile sync queue | Later mobile project |
| GPS capture | Later mobile project |
| Voice note capture/transcription UI | Later mobile project |
| Push notifications | Later mobile project/backend |
| n8n workflow builder | Backend/automation project |
| Supabase schema/migrations | Backend project |
| Edge Functions | Backend project |
| Accounting sync | Later release |
| AMC renewals | Later release |
| Payroll/inventory/project execution | Out of scope |

---

## 7. Data Model Coverage For Web

Create Flutter models for these workflow entities:

| Entity | Required For Web |
|---|---|
| Branch | Branch selector, permissions, reports |
| User | Auth, owner, assignee, role |
| Company | Customer/company records |
| Contact | Lead/customer contact records |
| Campaign | Source/campaign tracking |
| Lead | Lead inbox/detail |
| Deal | Pipeline |
| Activity | Lead/deal timeline |
| Task | Follow-ups and reminders |
| Product | Quote line selection |
| ProductBundle | Quote bundle selection |
| Quotation | Quotation detail and approval |
| QuotationLine | Quotation items |
| FileAttachment | Photos, drawings, PDFs, datasheets |
| AuditLog | Display history where API provides it |

Model rules:

- Use null safety.
- Include `fromJson`.
- Include `toJson`.
- Handle nullable values safely.
- Do not calculate backend-owned totals in models.

Money is AED.

Display money as:

```text
AED 13,282.50
```

---

## 8. Fixed Values

Centralize fixed values in utility files. Do not repeat strings across screens.

Lead sources:

```text
direct_visit
event
walk_in
referral
email
facebook
instagram
linkedin
whatsapp
website
phone
```

Lead statuses:

```text
new
contacted
qualified
disqualified
converted
```

Pipeline stages:

```text
site_survey
quotation_sent
negotiation
won
lost
```

For UI display, also support the design labels:

```text
New
Contacted
Site Survey
Quotation Sent
Negotiation
Won
Lost
```

Quotation statuses:

```text
draft
pending_approval
approved
sent
accepted
rejected
expired
```

Activity types:

```text
call
visit
email
whatsapp
note
site_survey
quotation_sent
boq_review
stage_changed
lead_created
task_created
```

---

## 9. Roles and Permissions

Support these roles:

| Role | Sees | Can Change | Approves |
|---|---|---|---|
| Admin | Everything | Users, products, prices, settings | Not required |
| Management | All branches | Most records except restricted admin settings | Quotations, discounts, lost reasons |
| Branch Sales | Own branch and assigned records | Leads, deals, activities, draft quotations | No |
| Kerala Back Office | Deals and quotations across branches | Quotations, BOQs, drawings, tasks | No |
| Viewer | Dashboards and reports | Nothing | No |

UI rules:

- Hide admin screens from non-admin users.
- Hide product cost from Branch Sales.
- Show approval actions only to allowed roles.
- Show branch filter based on permission.
- Show read-only screens for Viewer.

Security note:

Backend/API/database must enforce permissions. Flutter Web only controls the visible UI.

---

## 10. CRM Shell and Theme

Match the PDF visual style:

- Left sidebar
- Top header
- Branch selector
- User profile initials
- Search
- Notification area
- Light neutral background
- White cards
- Teal accent
- Compact professional tables
- Status/source badges

Sidebar:

```text
Dashboard
Leads
Pipeline
Quotes
Customers
Tasks
Campaigns
Reports
Settings
```

Create reusable shell widgets:

```text
AppSidebar
AppHeader
BranchSelector
AppSearchBar
```

Responsive targets:

| Width | Expected Behavior |
|---|---|
| 1920px | Full desktop layout |
| 1440px | Full desktop layout |
| 1366px | Full desktop layout |
| 1024px | Compact web/tablet layout |

---

## 11. Routes

Use GetX named routes:

```text
/login
/dashboard
/leads
/leads/:id
/pipeline
/quotes
/quotes/:id
/customers
/customers/:id
/tasks
/campaigns
/reports
/settings
```

Create:

```text
AppRoutes
AppPages
AuthMiddleware
```

Use GetX bindings where useful.

---

## 12. Dashboard Requirements

Build the dashboard from the design and workflow.

KPI tiles:

- New leads this week
- Open pipeline value
- Quotes awaiting reply
- Follow-ups due

Sections:

- Leads by source for selected period
- Morning briefing
- Today's follow-ups

Filters:

- Branch
- Date period

Data comes from `DashboardService`.

Use isolated mock data only until API is ready.

---

## 13. Lead Inbox Requirements

Build one lead list for all channels.

Features:

- Search
- Filter by source
- Filter by branch
- Filter by owner
- Filter by status/stage
- Filter by date
- Pagination
- Sort by age/created date
- Overdue row highlight
- Source tag
- AI requirement summary
- Bulk assign
- CSV import
- Export

Table columns:

```text
Lead
Requirement
Source
Branch
Owner
Stage/Status
Age
```

Source and campaign must be preserved from lead creation onward.

---

## 14. Lead Detail Requirements

Build lead detail with:

- Contact card
- Company
- Phone
- Email
- WhatsApp number
- Location/emirate
- Source
- Source detail
- Campaign
- Captured by
- Owner
- Estimated value
- Product interest
- Stage tracker
- Activity timeline
- Tasks
- Attachments
- AI summary/category/urgency
- AI next step panel
- Draft reply panel with Approve / Rewrite

Actions:

- Log call
- Log visit
- Add note
- Add task
- Convert lead to deal
- Open quotation

Duplicate handling:

- If API returns duplicate status, show clear duplicate warning.
- Do not merge duplicates in Flutter. Backend/API handles duplicate logic.

---

## 15. Intake Workflow Display Rules

The web app does not run n8n workflows, but it must display results from them.

Show:

- Source
- Campaign
- AI summary
- AI category
- Urgency
- Owner assignment
- Duplicate flag
- Response SLA task
- Workflow/run status if API provides it

Do not call Claude directly from Flutter.

Do not call email, WhatsApp, Meta, LinkedIn, or n8n directly from Flutter.

All external integrations go through backend/API/automation services.

---

## 16. Activity and Task Requirements

Activity timeline must support:

- Call
- Visit
- Email
- WhatsApp
- Note
- Site survey
- Quotation sent
- BOQ review
- Stage changed
- Lead created

Task fields:

- Title
- Related lead/deal/customer
- Assigned user
- Due date/time
- Priority
- Status
- Description

Task statuses:

```text
pending
in_progress
completed
overdue
```

Reminder sending is backend/automation work. Flutter only displays task state and allows allowed task actions.

---

## 17. Pipeline Requirements

Build Kanban pipeline board.

Columns:

- Site Survey
- Quotation Sent
- Negotiation
- Won
- Lost

Also support design entry columns if API returns them:

- New
- Contacted

Each column shows:

- Deal count
- Total value

Each card shows:

- Company/customer
- Requirement
- Estimated value
- Owner
- Source
- Days in stage
- Stalled warning

Rules:

- Dragging to Lost requires lost reason.
- Dragging to Won shows confirmation.
- Moving to Won may later trigger accounting sync in backend; do not implement accounting in Flutter.
- Stage update must call API.
- Use safe optimistic update with rollback or update after API success.

---

## 18. Quotation / BOQ Requirements

Build quotation list and quotation detail/builder.

Quotation fields:

- Number
- Version
- Status
- Valid until
- Customer/contact
- Deal/lead
- Prepared by
- Terms
- Subtotal
- VAT
- Total
- PDF URL

Quotation line fields:

- Product
- Description
- Quantity
- Unit price
- Discount
- Line total
- Sort order

Actions:

- Add line from product list
- Add bundle
- Edit quantity
- Edit discount if role allows
- Save draft
- Send for approval
- Approve
- Preview PDF
- Send
- Regenerate AI draft

Business rules:

1. Prices come from the backend/database.
2. Line totals, subtotal, VAT, and total are computed by backend/database logic.
3. Flutter must not be the authoritative calculator.
4. Quotation numbers come from backend/database sequence.
5. Revisions keep quotation number and increment version.
6. Discounts above configured limit require management approval.
7. Customer-facing output requires human approval.
8. AI returns product IDs and quantities only; backend looks up prices.
9. AI must not directly edit database records.

Show clear labels when content is AI-drafted.

---

## 19. Customers, Companies, and Contacts

Build customer management with:

- Company details
- Contact list
- Mobile
- Email
- WhatsApp number
- Address/emirate
- Branch
- Lead history
- Deal history
- Quotation history
- Activity history

Use API-driven list, search, filters, and pagination.

---

## 20. Campaigns and Source Tracking

Every lead must keep:

- Source
- Source detail
- Campaign
- UTM data if API provides it

Campaign screens should show:

- Campaign name
- Channel
- Start/end date
- Budget
- Lead count
- Conversion
- Revenue where available

Do not remove or overwrite original campaign/source history.

---

## 21. Reports

Prepare reports for:

- Leads by source
- Leads by branch
- Leads by salesperson
- Pipeline value
- Conversion rate
- Revenue by branch
- Revenue by salesperson
- Quotation performance
- Campaign performance
- Stalled deals
- Overdue follow-ups

Reports must be API-driven.

---

## 22. Settings / Admin

Build settings screens for:

- Users
- Roles
- Branches
- Product list
- Product bundles
- Campaigns
- Lost reasons
- SLA targets
- Quotation settings
- Notification settings

Admin-only:

- Users
- Roles
- Product costs
- Price settings
- System settings

CSV/product import can be UI-only with API hooks.

Do not implement database migrations in Flutter.

---

## 23. File Upload Architecture

Files include:

- Site photos
- Drawings
- Datasheets
- Quotation PDFs
- Attachments

Use API-backed private storage flow:

```text
Flutter Web
    ↓
POST /files/presign
    ↓
Backend validates user, role, branch, file type, file size
    ↓
Flutter uploads using browser-safe signed URL/instructions
    ↓
POST /files/complete
    ↓
Backend stores metadata
```

Use short-lived signed links for private files.

Do not expose storage secrets.

---

## 24. API Endpoints

Create endpoint constants for:

```text
POST   /auth/login
POST   /auth/logout
GET    /auth/me
POST   /auth/refresh

GET    /dashboard/summary
GET    /dashboard/leads-by-source
GET    /dashboard/follow-ups
GET    /dashboard/briefing

GET    /leads
POST   /leads
GET    /leads/:id
PUT    /leads/:id
PATCH  /leads/:id/status
PATCH  /leads/:id/owner
POST   /leads/:id/convert
GET    /leads/:id/activities
POST   /leads/:id/activities
GET    /leads/:id/tasks
POST   /leads/:id/tasks

GET    /deals
GET    /pipeline
PATCH  /pipeline/deals/:id/stage

GET    /quotations
POST   /quotations
GET    /quotations/:id
PUT    /quotations/:id
POST   /quotations/:id/lines
PUT    /quotations/:id/lines/:lineId
DELETE /quotations/:id/lines/:lineId
POST   /quotations/:id/submit-approval
POST   /quotations/:id/approve
POST   /quotations/:id/preview-pdf
POST   /quotations/:id/send
POST   /quotations/:id/regenerate-ai-draft

GET    /customers
POST   /customers
GET    /customers/:id
PUT    /customers/:id

GET    /tasks
POST   /tasks
PUT    /tasks/:id
PATCH  /tasks/:id/status

GET    /campaigns
POST   /campaigns
PUT    /campaigns/:id

GET    /products
POST   /products/import
GET    /product-bundles

GET    /reports/leads-by-source
GET    /reports/pipeline-value
GET    /reports/conversion-rate
GET    /reports/quotation-performance

POST   /files/presign
POST   /files/complete

GET    /settings
PUT    /settings
```

These are frontend endpoint constants only. Backend implementation is separate.

---

## 25. API Response and Errors

Create:

```text
ApiResponse<T>
PaginationModel
```

Support:

- Success
- Message
- Data
- Errors
- Pagination

Handle:

| Status | UI Handling |
|---|---|
| 200 | Success |
| 201 | Created |
| 204 | Success with no body |
| 400 | Bad request |
| 401 | Refresh token or logout |
| 403 | Permission denied |
| 404 | Not found |
| 409 | Duplicate/conflict |
| 422 | Validation errors |
| 500 | Server error |

Every screen must handle:

- Loading
- Empty
- Success
- Error
- Permission denied
- Validation error
- Network failure

---

## 26. Search, Filters, and Pagination

Use API-driven search, filtering, sorting, and pagination for production lists.

Required for:

- Leads
- Customers
- Quotes
- Tasks
- Campaigns
- Products
- Reports where applicable

Common query params:

```text
search
branch
owner
source
status
stage
date_from
date_to
page
limit
sort
```

---

## 27. AI Guardrails In Web UI

Flutter Web may display AI output returned by the backend/API.

Flutter Web must not:

- Call Claude directly
- Store Claude API keys
- Send customer data directly to AI services
- Let AI send customer messages without approval
- Let AI edit records without human confirmation/API validation

Show approval controls for:

- Reply drafts
- Follow-up drafts
- BOQ drafts
- AI-suggested quotation lines

---

## 28. Logging

Create:

```text
lib/utils/logger.dart
```

Rules:

- Log API activity only in development.
- Never log tokens.
- Never log secrets.
- Never log full sensitive customer payloads in production.
- Show safe user messages.

---

## 29. Testing

Add tests for:

- Model JSON parsing
- ApiService success/error handling
- AuthController state
- Route guards
- Permission utilities
- Lead filters and pagination state
- Pipeline stage update rollback behavior
- Quotation status and approval UI state
- Reusable badges/widgets

Tests must not require a live backend.

---

## 30. Implementation Phases

Build in phases:

| Phase | Scope |
|---|---|
| 1 | Project structure, packages, `.env.example`, `AppConfig`, theme |
| 2 | GetX routes, auth guard, CRM shell, sidebar, header |
| 3 | ApiService, ApiResponse, errors, logging |
| 4 | Login, current user, role/branch UI permissions |
| 5 | Dashboard with API-ready mock boundary |
| 6 | Lead inbox, filters, pagination, CSV import/export hooks |
| 7 | Lead detail, activity timeline, tasks, AI panel |
| 8 | Pipeline board with stage movement API hooks |
| 9 | Quotation/BOQ builder with backend-controlled totals |
| 10 | Customers, campaigns, reports, settings/admin screens |
| 11 | File upload architecture and attachment UI |
| 12 | Tests, polish, remove unsafe mock coupling |

---

## 31. Final Output Expected

Generate a Flutter Web project that includes:

- Safe `.env.example`
- `.env` ignored by Git
- GetX routing
- Dio API service layer
- CRM shell matching the PDF
- Dashboard
- Lead inbox
- Lead detail
- Activity/task UI
- Pipeline board
- Quotation/BOQ builder
- Customers
- Campaigns
- Reports
- Settings/Admin
- Role/branch UI permissions
- API-only database communication
- No direct PostgreSQL access
- No direct Supabase business CRUD from browser
- No mobile offline sync
- Clear placeholders for backend endpoints
- Tests for core frontend behavior

The result must be ready for backend API integration.

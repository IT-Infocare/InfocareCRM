-- =====================================================================
-- Infocare CRM — starting data
-- Safe to run more than once.
-- =====================================================================

-- Branches ---------------------------------------------------------------
insert into public.branches (code, name, country, currency) values
  ('DXB', 'Infocare Surveillance Systems LLC — Dubai', 'UAE',   'AED'),
  ('RAK', 'Infocare Surveillance Systems LLC — RAK',   'UAE',   'AED'),
  ('KER', 'Infocare Back Office — Kerala',             'India', 'INR')
on conflict (code) do nothing;

-- Settings (change the values to suit; see open decisions in the spec) ----
insert into public.app_settings (key, value, description) values
  ('discount_approval_pct', '10',  'Line discount (%) above which a quotation needs management approval'),
  ('lead_response_hours',   '2',   'Working hours to first response on a new lead'),
  ('quote_followup_days',   '5',   'Days without reply before the quote chaser creates a follow-up'),
  ('quote_valid_days',      '30',  'Default validity of a quotation'),
  ('vat_rate_pct',          '5',   'UAE VAT rate used for new products'),
  ('product_categories',    '["cctv", "access_control", "intercom", "gate_barrier", "fire_alarm", "network", "cable", "accessory", "service", "amc"]',
                                   'Allowed product and interest categories')
on conflict (key) do nothing;

-- Example bundle structure (products are imported from the product Excel list)
-- insert into public.product_bundles (name, description) values ('4-camera villa kit', '4 x IP camera, 8-ch NVR, PoE switch, cabling');


-- =====================================================================
-- AFTER the first person signs up in the app, make them admin:
--
--   update public.profiles
--      set role = 'admin',
--          branch_id = (select id from public.branches where code = 'DXB'),
--          full_name = 'Dileep Lal'
--    where email = 'dileep.infocare@gmail.com';
--
-- Then give everyone else a role and branch from the Admin screen, or:
--
--   update public.profiles set role = 'sales',
--          branch_id = (select id from public.branches where code = 'RAK')
--    where email = 'someone@example.com';
-- =====================================================================

class ApiEndpoints {
  // Auth
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
  static const String refresh = '/auth/refresh';

  // Dashboard
  static const String dashboardSummary = '/dashboard/summary';
  static const String dashboardLeadsBySource = '/dashboard/leads-by-source';
  static const String dashboardFollowUps = '/dashboard/follow-ups';
  static const String dashboardBriefing = '/dashboard/briefing';

  // Leads
  static const String leads = '/leads';
  static String leadDetail(String id) => '/leads/$id';
  static String leadStatus(String id) => '/leads/$id/status';
  static String leadOwner(String id) => '/leads/$id/owner';
  static String leadConvert(String id) => '/leads/$id/convert';
  static String leadActivities(String id) => '/leads/$id/activities';
  static String leadTasks(String id) => '/leads/$id/tasks';

  // Deals & Pipeline
  static const String deals = '/deals';
  static const String pipeline = '/pipeline';
  static String dealStage(String id) => '/pipeline/deals/$id/stage';

  // Quotations
  static const String quotations = '/quotations';
  static String quotationDetail(String id) => '/quotations/$id';
  static String quotationLines(String id) => '/quotations/$id/lines';
  static String quotationLineDetail(String id, String lineId) => '/quotations/$id/lines/$lineId';
  static String quotationSubmitApproval(String id) => '/quotations/$id/submit-approval';
  static String quotationApprove(String id) => '/quotations/$id/approve';
  static String quotationPreviewPdf(String id) => '/quotations/$id/preview-pdf';
  static String quotationSend(String id) => '/quotations/$id/send';
  static String quotationRegenerateAiDraft(String id) => '/quotations/$id/regenerate-ai-draft';

  // Customers
  static const String customers = '/customers';
  static String customerDetail(String id) => '/customers/$id';

  // Tasks
  static const String tasks = '/tasks';
  static String taskDetail(String id) => '/tasks/$id';
  static String taskStatus(String id) => '/tasks/$id/status';

  // Campaigns
  static const String campaigns = '/campaigns';
  static String campaignDetail(String id) => '/campaigns/$id';

  // Products
  static const String products = '/products';
  static const String productImport = '/products/import';
  static const String productBundles = '/product-bundles';

  // Reports
  static const String reportLeadsBySource = '/reports/leads-by-source';
  static const String reportPipelineValue = '/reports/pipeline-value';
  static const String reportConversionRate = '/reports/conversion-rate';
  static const String reportQuotationPerformance = '/reports/quotation-performance';

  // Files
  static const String filePresign = '/files/presign';
  static const String fileComplete = '/files/complete';

  // Settings
  static const String settings = '/settings';
}

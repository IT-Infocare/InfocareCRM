class AppConstants {
  static const String appTitle = 'Infocare CRM';

  // Lead Sources
  static const List<String> leadSources = [
    'direct_visit',
    'event',
    'walk_in',
    'referral',
    'email',
    'facebook',
    'instagram',
    'linkedin',
    'whatsapp',
    'website',
    'phone',
  ];

  // Lead Statuses
  static const List<String> leadStatuses = [
    'new',
    'contacted',
    'qualified',
    'disqualified',
    'converted',
  ];

  // Pipeline Stages
  static const List<String> pipelineStages = [
    'new',
    'contacted',
    'site_survey',
    'quotation_sent',
    'negotiation',
    'won',
    'lost',
  ];

  // Quotation Statuses
  static const List<String> quotationStatuses = [
    'draft',
    'pending_approval',
    'approved',
    'sent',
    'accepted',
    'rejected',
    'expired',
  ];

  // Activity Types
  static const List<String> activityTypes = [
    'call',
    'visit',
    'email',
    'whatsapp',
    'note',
    'site_survey',
    'quotation_sent',
    'boq_review',
    'stage_changed',
    'lead_created',
    'task_created',
  ];

  // Task Statuses
  static const List<String> taskStatuses = [
    'pending',
    'in_progress',
    'completed',
    'overdue',
  ];

  // User Roles
  static const String roleAdmin = 'admin';
  static const String roleManagement = 'management';
  static const String roleBranchSales = 'branch_sales';
  static const String roleKeralaBackOffice = 'kerala_back_office';
  static const String roleViewer = 'viewer';

  static const List<String> allRoles = [
    roleAdmin,
    roleManagement,
    roleBranchSales,
    roleKeralaBackOffice,
    roleViewer,
  ];
}

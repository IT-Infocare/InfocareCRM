import '../config/api_endpoints.dart';
import '../config/app_config.dart';
import '../models/api_response.dart';
import '../models/task_model.dart';
import 'api_service.dart';

class DashboardSummaryData {
  final int newLeadsThisWeek;
  final num openPipelineValue;
  final int quotesAwaitingReply;
  final int followUpsDue;

  DashboardSummaryData({
    required this.newLeadsThisWeek,
    required this.openPipelineValue,
    required this.quotesAwaitingReply,
    required this.followUpsDue,
  });

  factory DashboardSummaryData.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryData(
      newLeadsThisWeek: (json['new_leads_this_week'] as int?) ?? 0,
      openPipelineValue: (json['open_pipeline_value'] as num?) ?? 0,
      quotesAwaitingReply: (json['quotes_awaiting_reply'] as int?) ?? 0,
      followUpsDue: (json['follow_ups_due'] as int?) ?? 0,
    );
  }
}

class DashboardOverviewData {
  final DashboardSummaryData summary;
  final Map<String, int> leadsBySource;
  final List<TaskModel> followUps;
  final String briefing;

  DashboardOverviewData({
    required this.summary,
    required this.leadsBySource,
    required this.followUps,
    required this.briefing,
  });

  factory DashboardOverviewData.fromJson(Map<String, dynamic> json) {
    final summaryJson = (json['summary'] as Map<String, dynamic>?) ?? {};
    final sourcesJson = (json['leads_by_source'] as Map<String, dynamic>?) ?? {};
    final followUpsList = (json['follow_ups'] as List<dynamic>?) ?? [];
    final briefingJson = json['briefing'];
    String briefingText = '';
    if (briefingJson is Map<String, dynamic>) {
      briefingText = (briefingJson['ai_summary'] as String?) ?? '';
    } else if (briefingJson is String) {
      briefingText = briefingJson;
    }

    return DashboardOverviewData(
      summary: DashboardSummaryData.fromJson(summaryJson),
      leadsBySource: sourcesJson.map((k, v) => MapEntry(k, (v as num).toInt())),
      followUps: followUpsList.map((t) => TaskModel.fromJson(t as Map<String, dynamic>)).toList(),
      briefing: briefingText,
    );
  }
}

class DashboardService {
  final ApiService _apiService;

  DashboardService(this._apiService);

  Future<ApiResponse<DashboardOverviewData>> getOverview({String? branch}) async {
    if (AppConfig.enableMockData) {
      final summaryRes = await getSummary(branch: branch);
      final sourcesRes = await getLeadsBySource(branch: branch);
      final followUpsRes = await getTodayFollowUps(branch: branch);
      final briefingRes = await getMorningBriefing(branch: branch);
      return ApiResponse<DashboardOverviewData>(
        success: true,
        data: DashboardOverviewData(
          summary: summaryRes.data ?? DashboardSummaryData(
            newLeadsThisWeek: 0,
            openPipelineValue: 0,
            quotesAwaitingReply: 0,
            followUpsDue: 0,
          ),
          leadsBySource: sourcesRes.data ?? {},
          followUps: followUpsRes.data ?? [],
          briefing: briefingRes.data ?? '',
        ),
      );
    }

    return _apiService.get<DashboardOverviewData>(
      ApiEndpoints.dashboardOverview,
      queryParameters: {
        if (branch != null) 'branch': branch,
      },
      fromJson: (json) => DashboardOverviewData.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<DashboardSummaryData>> getSummary({String? branch, String? period}) async {
    if (AppConfig.enableMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return ApiResponse<DashboardSummaryData>(
        success: true,
        data: DashboardSummaryData(
          newLeadsThisWeek: 28,
          openPipelineValue: 485000,
          quotesAwaitingReply: 12,
          followUpsDue: 7,
        ),
      );
    }

    return _apiService.get<DashboardSummaryData>(
      ApiEndpoints.dashboardSummary,
      queryParameters: {
        if (branch != null) 'branch': branch,
        if (period != null) 'period': period,
      },
      fromJson: (json) => DashboardSummaryData.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<Map<String, int>>> getLeadsBySource({String? branch}) async {
    if (AppConfig.enableMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return ApiResponse<Map<String, int>>(
        success: true,
        data: {
          'whatsapp': 35,
          'website': 25,
          'facebook': 18,
          'referral': 12,
          'direct_visit': 10,
        },
      );
    }

    return _apiService.get<Map<String, int>>(
      ApiEndpoints.dashboardLeadsBySource,
      queryParameters: {if (branch != null) 'branch': branch},
      fromJson: (json) => (json as Map<String, dynamic>).map((k, v) => MapEntry(k, (v as num).toInt())),
    );
  }

  Future<ApiResponse<List<TaskModel>>> getTodayFollowUps({String? branch}) async {
    if (AppConfig.enableMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final now = DateTime.now();
      return ApiResponse<List<TaskModel>>(
        success: true,
        data: [
          TaskModel(
            id: 'tsk_001',
            title: 'Call Al Maya Trading regarding CCTV BOQ',
            relatedToTitle: 'Al Maya Trading (AED 45,000)',
            assignedUserId: 'usr_1001',
            assignedUserName: 'Sarah Connor',
            dueDate: DateTime(now.year, now.month, now.day, 10, 30),
            priority: 'high',
            status: 'pending',
            createdAt: now.subtract(const Duration(days: 1)),
          ),
          TaskModel(
            id: 'tsk_002',
            title: 'Send revised quotation to Apex Logistics',
            relatedToTitle: 'Apex Logistics (AED 120,000)',
            assignedUserId: 'usr_1001',
            assignedUserName: 'Sarah Connor',
            dueDate: DateTime(now.year, now.month, now.day, 14, 00),
            priority: 'medium',
            status: 'pending',
            createdAt: now.subtract(const Duration(days: 2)),
          ),
        ],
      );
    }

    return _apiService.get<List<TaskModel>>(
      ApiEndpoints.dashboardFollowUps,
      queryParameters: {if (branch != null) 'branch': branch},
      fromJson: (json) => (json as List<dynamic>).map((e) => TaskModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<ApiResponse<String>> getMorningBriefing({String? branch}) async {
    if (AppConfig.enableMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return ApiResponse<String>(
        success: true,
        data: 'Good morning! You have 7 follow-ups due today. 3 high-value deals in Dubai are in Quotation Sent stage for >5 days. 5 new leads captured overnight via WhatsApp.',
      );
    }

    return _apiService.get<String>(
      ApiEndpoints.dashboardBriefing,
      queryParameters: {if (branch != null) 'branch': branch},
      fromJson: (json) => json.toString(),
    );
  }
}

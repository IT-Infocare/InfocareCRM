import '../config/api_endpoints.dart';
import '../config/app_config.dart';
import '../models/activity_model.dart';
import '../models/api_response.dart';
import '../models/lead_model.dart';
import '../models/pagination_model.dart';
import 'api_service.dart';

class LeadService {
  final ApiService _apiService;

  LeadService(this._apiService);

  final List<LeadModel> _mockLeads = [
    LeadModel(
      id: 'lead_001',
      contactName: 'Ahmed Al Mansoori',
      companyName: 'Al Maya Trading LLC',
      phone: '+971 50 111 2222',
      email: 'ahmed@almaya.ae',
      whatsappNumber: '+971 50 111 2222',
      location: 'Dubai',
      requirement: 'Full CCTV and Access Control system for 3-floor office building with 40 cameras.',
      source: 'whatsapp',
      sourceDetail: 'Inbound message from campaign banner',
      campaign: 'Q3 Security Solutions',
      capturedBy: 'WhatsApp AI Agent',
      ownerId: 'usr_1001',
      ownerName: 'Sarah Connor',
      branch: 'Dubai',
      estimatedValue: 45000,
      productInterest: 'Hikvision IP CCTV, ZK Access',
      status: 'contacted',
      stage: 'site_survey',
      aiSummary: 'High intent lead requesting 40 camera IP CCTV installation and bio-access doors.',
      aiCategory: 'CCTV & Security',
      aiUrgency: 'High',
      aiNextStep: 'Schedule site survey visit within 24 hours.',
      aiDraftReply: 'Hello Ahmed, thank you for reaching out to Infocare. We can definitely assist with your 40-camera IP CCTV requirement for your 3-floor office. Our senior engineer can visit your Dubai site tomorrow at 10:00 AM for a complimentary survey. Please confirm if this time works for you.',
      isDuplicate: false,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    LeadModel(
      id: 'lead_002',
      contactName: 'John Smith',
      companyName: 'Apex Logistics',
      phone: '+971 55 333 4444',
      email: 'jsmith@apexlogistics.com',
      whatsappNumber: '+971 55 333 4444',
      location: 'RAK',
      requirement: 'Structured cabling and Wi-Fi access points for 10,000 sq ft warehouse.',
      source: 'website',
      sourceDetail: 'Web form submission',
      campaign: 'Google Ads Search',
      capturedBy: 'Web Form',
      ownerId: 'usr_1002',
      ownerName: 'Rahul Verma',
      branch: 'RAK',
      estimatedValue: 120000,
      productInterest: 'Aruba Wi-Fi 6, Cat6A Cabling',
      status: 'contacted',
      stage: 'quotation_sent',
      aiSummary: 'Enterprise warehouse networking inquiry. Requires high-density wireless coverage.',
      aiCategory: 'Networking',
      aiUrgency: 'Medium',
      aiNextStep: 'Follow up on Quotation QT-2026-089 sent on Tuesday.',
      aiDraftReply: 'Dear Mr. Smith, following up on our quotation for the Apex Logistics warehouse project. Have you had a chance to review the wireless coverage map proposal?',
      isDuplicate: false,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    LeadModel(
      id: 'lead_003',
      contactName: 'Fatima Al Hammadi',
      companyName: 'Emirates Health Clinic',
      phone: '+971 52 999 8888',
      email: 'fatima@ehclinic.ae',
      whatsappNumber: '+971 52 999 8888',
      location: 'Dubai',
      requirement: 'PABX Telephone system upgrade and Time Attendance device.',
      source: 'referral',
      sourceDetail: 'Referred by Client #409',
      campaign: 'Client Referral Program',
      capturedBy: 'Direct Sales',
      ownerId: 'usr_1001',
      ownerName: 'Sarah Connor',
      branch: 'Dubai',
      estimatedValue: 28000,
      productInterest: 'Yeastar IP PBX, Grandstream IP Phones',
      status: 'qualified',
      stage: 'negotiation',
      aiSummary: 'Upgrade existing analog PBX to IP PBX for 25 extension users across 2 floors.',
      aiCategory: 'Telecom',
      aiUrgency: 'Normal',
      aiNextStep: 'Finalize discount approval with management.',
      aiDraftReply: 'Dear Fatima, we have reviewed your request for the 25 extension IP PBX system. Attached is our final revised commercial proposal with preferred pricing.',
      isDuplicate: false,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  Future<ApiResponse<List<LeadModel>>> getLeads({
    String? search,
    String? branch,
    String? owner,
    String? source,
    String? status,
    String? stage,
    int page = 1,
    int limit = 10,
  }) async {
    if (AppConfig.enableMockData) {
      await Future.delayed(const Duration(milliseconds: 300));

      var filtered = List<LeadModel>.from(_mockLeads);

      if (search != null && search.isNotEmpty) {
        final query = search.toLowerCase();
        filtered = filtered.where((l) =>
            l.contactName.toLowerCase().contains(query) ||
            (l.companyName?.toLowerCase().contains(query) ?? false) ||
            l.requirement.toLowerCase().contains(query) ||
            l.phone.contains(query)).toList();
      }

      if (branch != null && branch != 'All') {
        filtered = filtered.where((l) => l.branch == branch).toList();
      }

      if (source != null && source != 'All') {
        filtered = filtered.where((l) => l.source == source).toList();
      }

      if (status != null && status != 'All') {
        filtered = filtered.where((l) => l.status == status).toList();
      }

      final totalItems = filtered.length;
      final totalPages = (totalItems / limit).ceil();

      return ApiResponse<List<LeadModel>>(
        success: true,
        data: filtered,
        pagination: PaginationModel(
          page: page,
          limit: limit,
          totalItems: totalItems > 0 ? totalItems : 1,
          totalPages: totalPages > 0 ? totalPages : 1,
        ),
      );
    }

    return _apiService.get<List<LeadModel>>(
      ApiEndpoints.leads,
      queryParameters: {
        if (search != null) 'search': search,
        if (branch != null) 'branch': branch,
        if (owner != null) 'owner': owner,
        if (source != null) 'source': source,
        if (status != null) 'status': status,
        if (stage != null) 'stage': stage,
        'page': page,
        'limit': limit,
      },
      fromJson: (json) => (json as List<dynamic>).map((e) => LeadModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<ApiResponse<LeadModel>> getLeadById(String id) async {
    if (AppConfig.enableMockData) {
      await Future.delayed(const Duration(milliseconds: 200));
      final lead = _mockLeads.firstWhere(
        (l) => l.id == id,
        orElse: () => _mockLeads.first,
      );
      return ApiResponse<LeadModel>(success: true, data: lead);
    }

    final res = await _apiService.get<LeadModel>(
      ApiEndpoints.leadDetail(id),
      fromJson: (json) => LeadModel.fromJson(json as Map<String, dynamic>),
    );
    if (res.success && res.data != null) {
      return res;
    }

    // Fallback for direct Supabase REST API (PostgREST format: GET /leads?id=eq.id)
    return _apiService.get<LeadModel>(
      ApiEndpoints.leads,
      queryParameters: {'id': 'eq.$id'},
      fromJson: (json) {
        if (json is List && json.isNotEmpty) {
          return LeadModel.fromJson(json.first as Map<String, dynamic>);
        }
        return LeadModel.fromJson(json as Map<String, dynamic>);
      },
    );
  }

  Future<ApiResponse<LeadModel>> createLead(Map<String, dynamic> payload) async {
    if (AppConfig.enableMockData) {
      await Future.delayed(const Duration(milliseconds: 400));
      final newLead = LeadModel.fromJson({
        'id': 'lead_${DateTime.now().millisecondsSinceEpoch}',
        ...payload,
        'created_at': DateTime.now().toIso8601String(),
      });
      _mockLeads.insert(0, newLead);
      return ApiResponse<LeadModel>(success: true, message: 'Lead created successfully', data: newLead);
    }

    var currentPayload = Map<String, dynamic>.from(payload)..removeWhere((key, value) => value == null);

    ApiResponse<LeadModel> res = await _apiService.post<LeadModel>(
      ApiEndpoints.leads,
      data: currentPayload,
      fromJson: (json) => LeadModel.fromJson(json as Map<String, dynamic>),
    );

    // Dynamic resilient retry: automatically parse and strip missing column names from PGRST204 errors
    int maxRetries = 10;
    while (!res.success && res.message != null && res.message!.contains('PGRST204') && maxRetries > 0) {
      maxRetries--;
      final match = RegExp(r"Could not find the '(.+?)' column").firstMatch(res.message!);
      if (match != null) {
        final missingCol = match.group(1);
        if (missingCol != null) {
          currentPayload.remove(missingCol);
          res = await _apiService.post<LeadModel>(
            ApiEndpoints.leads,
            data: currentPayload,
            fromJson: (json) => LeadModel.fromJson(json as Map<String, dynamic>),
          );
          continue;
        }
      }
      break;
    }

    return res;
  }

  Future<ApiResponse<LeadModel>> updateLead(String id, Map<String, dynamic> payload) async {
    if (AppConfig.enableMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final index = _mockLeads.indexWhere((l) => l.id == id);
      if (index != -1) {
        final existing = _mockLeads[index];
        final updated = LeadModel.fromJson({
          ...existing.toJson(),
          ...payload,
        });
        _mockLeads[index] = updated;
        return ApiResponse<LeadModel>(success: true, message: 'Lead updated', data: updated);
      }
    }

    return _apiService.put<LeadModel>(
      ApiEndpoints.leadDetail(id),
      data: payload,
      fromJson: (json) => LeadModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<LeadModel>> updateStatus(String id, String status) async {
    if (AppConfig.enableMockData) {
      await Future.delayed(const Duration(milliseconds: 200));
      final index = _mockLeads.indexWhere((l) => l.id == id);
      if (index != -1) {
        _mockLeads[index] = _mockLeads[index].copyWith(status: status);
        return ApiResponse<LeadModel>(success: true, data: _mockLeads[index]);
      }
    }

    return _apiService.patch<LeadModel>(
      ApiEndpoints.leadStatus(id),
      data: {'status': status},
      fromJson: (json) => LeadModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<List<ActivityModel>>> getActivities(String leadId) async {
    if (AppConfig.enableMockData) {
      await Future.delayed(const Duration(milliseconds: 200));
      final now = DateTime.now();
      return ApiResponse<List<ActivityModel>>(
        success: true,
        data: [
          ActivityModel(
            id: 'act_101',
            leadId: leadId,
            type: 'lead_created',
            description: 'Lead captured via WhatsApp AI channel.',
            createdBy: 'System AI',
            createdAt: now.subtract(const Duration(days: 1)),
          ),
          ActivityModel(
            id: 'act_102',
            leadId: leadId,
            type: 'call',
            description: 'Initial discovery call conducted with Ahmed. Confirmed 40 camera count requirement.',
            createdBy: 'Sarah Connor',
            createdAt: now.subtract(const Duration(hours: 18)),
          ),
          ActivityModel(
            id: 'act_103',
            leadId: leadId,
            type: 'site_survey',
            description: 'Site survey scheduled for tomorrow 10:00 AM in Dubai office.',
            createdBy: 'Sarah Connor',
            createdAt: now.subtract(const Duration(hours: 4)),
          ),
        ],
      );
    }

    return _apiService.get<List<ActivityModel>>(
      ApiEndpoints.leadActivities(leadId),
      fromJson: (json) => (json as List<dynamic>).map((e) => ActivityModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<ApiResponse<ActivityModel>> addActivity(String leadId, String type, String description) async {
    if (AppConfig.enableMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final newAct = ActivityModel(
        id: 'act_${DateTime.now().millisecondsSinceEpoch}',
        leadId: leadId,
        type: type,
        description: description,
        createdBy: 'Logged User',
        createdAt: DateTime.now(),
      );
      return ApiResponse<ActivityModel>(success: true, message: 'Activity logged', data: newAct);
    }

    return _apiService.post<ActivityModel>(
      ApiEndpoints.leadActivities(leadId),
      data: {'type': type, 'description': description},
      fromJson: (json) => ActivityModel.fromJson(json as Map<String, dynamic>),
    );
  }
}

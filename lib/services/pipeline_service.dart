import '../config/api_endpoints.dart';
import '../config/app_config.dart';
import '../models/api_response.dart';
import '../models/deal_model.dart';
import 'api_service.dart';

class PipelineService {
  final ApiService _apiService;

  PipelineService(this._apiService);

  final List<DealModel> _mockDeals = [
    DealModel(
      id: 'dl_100',
      leadId: 'lead_000',
      customerName: 'Ali Shaban',
      companyName: 'W.J.Towell',
      requirement: 'PTZ CAMERA',
      estimatedValue: 0,
      ownerName: 'Sarah Connor',
      source: 'website',
      stage: 'new',
      daysInStage: 1,
      isStalled: false,
      branch: 'Dubai',
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    DealModel(
      id: 'dl_101',
      leadId: 'lead_001',
      customerName: 'Ahmed Al Mansoori',
      companyName: 'Al Maya Trading LLC',
      requirement: '40 IP CCTV Camera System Installation',
      estimatedValue: 45000,
      ownerName: 'Sarah Connor',
      source: 'whatsapp',
      stage: 'site_survey',
      daysInStage: 2,
      isStalled: false,
      branch: 'Dubai',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    DealModel(
      id: 'dl_102',
      leadId: 'lead_002',
      customerName: 'John Smith',
      companyName: 'Apex Logistics',
      requirement: 'Warehouse Wi-Fi 6 Networking & Cabling',
      estimatedValue: 120000,
      ownerName: 'Rahul Verma',
      source: 'website',
      stage: 'quotation_sent',
      daysInStage: 6,
      isStalled: true,
      branch: 'RAK',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    DealModel(
      id: 'dl_103',
      leadId: 'lead_003',
      customerName: 'Fatima Al Hammadi',
      companyName: 'Emirates Health Clinic',
      requirement: '25 Ext Yeastar IP PBX Telecom System',
      estimatedValue: 28000,
      ownerName: 'Sarah Connor',
      source: 'referral',
      stage: 'negotiation',
      daysInStage: 3,
      isStalled: false,
      branch: 'Dubai',
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
    ),
    DealModel(
      id: 'dl_104',
      customerName: 'Mohammed Tariq',
      companyName: 'Gulf Star Contracting',
      requirement: 'Access Control & Time Attendance',
      estimatedValue: 35000,
      ownerName: 'Rahul Verma',
      source: 'phone',
      stage: 'won',
      daysInStage: 1,
      isStalled: false,
      branch: 'Dubai',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
    DealModel(
      id: 'dl_105',
      customerName: 'David Miller',
      companyName: 'Redwood Interiors',
      requirement: 'Server Rack & Fiber Backhaul',
      estimatedValue: 65000,
      ownerName: 'Sarah Connor',
      source: 'facebook',
      stage: 'lost',
      daysInStage: 12,
      isStalled: false,
      lostReason: 'Price higher than local competitor by 15%',
      branch: 'Dubai',
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
  ];

  Future<ApiResponse<List<DealModel>>> getPipelineDeals({String? branch}) async {
    if (AppConfig.enableMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      var list = List<DealModel>.from(_mockDeals);
      if (branch != null && branch != 'All') {
        list = list.where((d) => d.branch == branch).toList();
      }
      return ApiResponse<List<DealModel>>(success: true, data: list);
    }

    return _apiService.get<List<DealModel>>(
      ApiEndpoints.pipeline,
      queryParameters: {if (branch != null) 'branch': branch},
      fromJson: (json) => (json as List<dynamic>).map((e) => DealModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<ApiResponse<DealModel>> updateDealStage(
    String dealId,
    String stage, {
    String? lostReason,
  }) async {
    if (AppConfig.enableMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final index = _mockDeals.indexWhere((d) => d.id == dealId);
      if (index != -1) {
        final updated = _mockDeals[index].copyWith(
          stage: stage,
          lostReason: lostReason,
          daysInStage: 0,
          isStalled: false,
        );
        _mockDeals[index] = updated;
        return ApiResponse<DealModel>(success: true, data: updated);
      }
    }

    return _apiService.patch<DealModel>(
      ApiEndpoints.dealStage(dealId),
      data: {
        'stage': stage,
        if (lostReason != null) 'lost_reason': lostReason,
      },
      fromJson: (json) => DealModel.fromJson(json as Map<String, dynamic>),
    );
  }
}

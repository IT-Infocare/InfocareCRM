import '../config/api_endpoints.dart';
import '../config/app_config.dart';
import '../models/api_response.dart';
import '../models/campaign_model.dart';
import 'api_service.dart';

class CampaignService {
  final ApiService _apiService;

  CampaignService(this._apiService);

  final List<CampaignModel> _mockCampaigns = [
    CampaignModel(
      id: 'cmp_001',
      name: 'Q3 Security Solutions Campaign',
      channel: 'whatsapp',
      startDate: DateTime.now().subtract(const Duration(days: 30)),
      endDate: DateTime.now().add(const Duration(days: 15)),
      budget: 15000,
      leadCount: 42,
      conversionRate: 18.5,
      revenueGenerated: 245000,
      isActive: true,
    ),
    CampaignModel(
      id: 'cmp_002',
      name: 'Google Ads Search - IT Networking',
      channel: 'website',
      startDate: DateTime.now().subtract(const Duration(days: 60)),
      endDate: DateTime.now().add(const Duration(days: 30)),
      budget: 25000,
      leadCount: 88,
      conversionRate: 14.2,
      revenueGenerated: 420000,
      isActive: true,
    ),
    CampaignModel(
      id: 'cmp_003',
      name: 'Gitex Technology Week Leads 2026',
      channel: 'event',
      startDate: DateTime.now().subtract(const Duration(days: 90)),
      endDate: DateTime.now().subtract(const Duration(days: 80)),
      budget: 40000,
      leadCount: 110,
      conversionRate: 22.0,
      revenueGenerated: 680000,
      isActive: false,
    ),
  ];

  Future<ApiResponse<List<CampaignModel>>> getCampaigns() async {
    if (AppConfig.enableMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return ApiResponse<List<CampaignModel>>(success: true, data: _mockCampaigns);
    }

    return _apiService.get<List<CampaignModel>>(
      ApiEndpoints.campaigns,
      fromJson: (json) => (json as List<dynamic>).map((e) => CampaignModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

import '../config/api_endpoints.dart';
import '../config/app_config.dart';
import '../models/api_response.dart';
import 'api_service.dart';

class ReportService {
  final ApiService _apiService;

  ReportService(this._apiService);

  Future<ApiResponse<Map<String, dynamic>>> getReportData({String? reportType, String? branch}) async {
    if (AppConfig.enableMockData) {
      await Future.delayed(const Duration(milliseconds: 400));
      return ApiResponse<Map<String, dynamic>>(
        success: true,
        data: {
          'leads_by_source': {
            'WhatsApp': 42,
            'Website': 28,
            'Facebook': 19,
            'Referral': 15,
            'Direct Visit': 12,
            'Phone Call': 8,
          },
          'pipeline_value_by_branch': {
            'Dubai': 485000,
            'RAK': 210000,
            'Kerala': 95000,
          },
          'conversion_rate_by_salesperson': {
            'Sarah Connor': 24.5,
            'Rahul Verma': 19.8,
            'Amal Kumar': 16.2,
          },
          'quotation_performance': {
            'total_quotes_sent': 45,
            'total_approved': 28,
            'approval_rate': 62.2,
            'avg_response_days': 3.5,
          },
        },
      );
    }

    return _apiService.get<Map<String, dynamic>>(
      ApiEndpoints.reportLeadsBySource,
      queryParameters: {
        if (reportType != null) 'type': reportType,
        if (branch != null) 'branch': branch,
      },
    );
  }
}

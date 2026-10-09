import '../config/api_endpoints.dart';
import '../config/app_config.dart';
import '../models/api_response.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService;

  AuthService(this._apiService);

  Future<ApiResponse<Map<String, dynamic>>> login(String email, String password) async {
    if (AppConfig.enableMockData) {
      await Future.delayed(const Duration(milliseconds: 600));

      // Determine role from email for quick testing during dev
      String role = 'admin';
      String branch = 'Dubai';
      if (email.contains('sales')) {
        role = 'branch_sales';
      } else if (email.contains('management')) {
        role = 'management';
      } else if (email.contains('kerala')) {
        role = 'kerala_back_office';
        branch = 'Kerala';
      } else if (email.contains('viewer')) {
        role = 'viewer';
      }

      final mockUser = UserModel(
        id: 'usr_1001',
        username: email.split('@')[0],
        name: email.split('@')[0].replaceAll('.', ' ').toUpperCase(),
        email: email,
        role: role,
        branch: branch,
        phone: '+971 50 123 4567',
      );

      return ApiResponse<Map<String, dynamic>>(
        success: true,
        message: 'Login successful',
        data: {
          'token': 'mock_jwt_token_sample_12345',
          'user': mockUser.toJson(),
        },
      );
    }

    return _apiService.post<Map<String, dynamic>>(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );
  }

  Future<ApiResponse<UserModel>> getCurrentUser() async {
    if (AppConfig.enableMockData) {
      await Future.delayed(const Duration(milliseconds: 200));
      return ApiResponse<UserModel>(
        success: true,
        data: UserModel(
          id: 'usr_1001',
          username: 'sarah.c',
          name: 'Sarah Connor',
          email: 'sarah.c@infocare.ae',
          role: 'admin',
          branch: 'Dubai',
          phone: '+971 50 987 6543',
        ),
      );
    }

    return _apiService.get<UserModel>(
      ApiEndpoints.me,
      fromJson: (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<void> logout() async {
    if (!AppConfig.enableMockData) {
      await _apiService.post(ApiEndpoints.logout);
    }
  }
}

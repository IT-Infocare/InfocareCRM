import '../config/app_config.dart';
import '../models/api_response.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class UserService {
  final ApiService _apiService;

  UserService(this._apiService);

  final List<UserModel> _mockUsers = [
    UserModel(
      id: 'a0000000-0000-4000-a000-000000000001',
      username: 'Admin',
      name: 'System Administrator',
      email: 'admin@infocare.ae',
      role: 'Admin',
      branch: 'Dubai',
      phone: '+971 50 100 0000',
    ),
  ];

  Future<ApiResponse<List<UserModel>>> getUsers() async {
    if (AppConfig.enableMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return ApiResponse<List<UserModel>>(success: true, data: _mockUsers);
    }

    return _apiService.get<List<UserModel>>(
      '/users',
      fromJson: (json) => (json as List<dynamic>).map((e) => UserModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<ApiResponse<UserModel>> createUser(Map<String, dynamic> payload) async {
    if (AppConfig.enableMockData) {
      await Future.delayed(const Duration(milliseconds: 400));
      final newUser = UserModel.fromJson({
        'id': 'usr_${DateTime.now().millisecondsSinceEpoch}',
        ...payload,
      });
      _mockUsers.insert(0, newUser);
      return ApiResponse<UserModel>(success: true, message: 'User created successfully', data: newUser);
    }

    return _apiService.post<UserModel>(
      '/users',
      data: payload,
      fromJson: (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );
  }
}

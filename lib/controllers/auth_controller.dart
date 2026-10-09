import 'package:get/get.dart';
import '../config/app_routes.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  final AuthService _authService = AuthService(Get.find<ApiService>());

  final RxBool isLoggedIn = false.obs;
  final RxBool isLoading = false.obs;
  final Rxn<UserModel> currentUser = Rxn<UserModel>();
  final RxString selectedBranch = 'Dubai'.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Default logged out state so Login page appears on startup
    isLoggedIn.value = false;
    currentUser.value = null;
  }

  Future<bool> login(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final res = await _authService.login(email, password);
      if (res.success && res.data != null) {
        final token = res.data!['token'] as String;
        final userJson = res.data!['user'] as Map<String, dynamic>;
        Get.find<ApiService>().setAuthToken(token);
        currentUser.value = UserModel.fromJson(userJson);
        selectedBranch.value = currentUser.value?.branch ?? 'Dubai';
        isLoggedIn.value = true;
        Get.offAllNamed(AppRoutes.dashboard);
        return true;
      } else {
        errorMessage.value = res.message ?? 'Login failed';
        return false;
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    Get.find<ApiService>().setAuthToken(null);
    currentUser.value = null;
    isLoggedIn.value = false;
    Get.offAllNamed(AppRoutes.login);
  }
}

import 'package:get/get.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/user_service.dart';

class UserController extends GetxController {
  static UserController get to => Get.find();

  late final UserService _userService;

  final RxList<UserModel> users = <UserModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _userService = UserService(Get.find<ApiService>());
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final res = await _userService.getUsers();
      if (res.success && res.data != null) {
        users.assignAll(res.data!);
      } else {
        errorMessage.value = res.message ?? 'Failed to fetch users';
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createUser(Map<String, dynamic> payload) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final res = await _userService.createUser(payload);
      if (res.success && res.data != null) {
        users.insert(0, res.data!);
        Get.snackbar('Success', 'User created successfully');
        return true;
      } else {
        errorMessage.value = res.message ?? 'Failed to create user';
        Get.snackbar('Error', errorMessage.value);
        return false;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', errorMessage.value);
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}

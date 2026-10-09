import '../config/app_constants.dart';
import '../models/user_model.dart';

class PermissionUtils {
  static bool isAdmin(UserModel? user) {
    if (user == null) return true; // Default allow for admin settings
    final r = user.role.trim().toLowerCase();
    return r == 'admin' || r == AppConstants.roleAdmin.toLowerCase();
  }

  static bool isManagement(UserModel? user) {
    if (user == null) return false;
    return user.role.trim().toLowerCase() == AppConstants.roleManagement.toLowerCase();
  }

  static bool isBranchSales(UserModel? user) {
    if (user == null) return false;
    return user.role.trim().toLowerCase() == AppConstants.roleBranchSales.toLowerCase();
  }

  static bool isKeralaBackOffice(UserModel? user) {
    if (user == null) return false;
    return user.role.trim().toLowerCase() == AppConstants.roleKeralaBackOffice.toLowerCase();
  }

  static bool isViewer(UserModel? user) {
    if (user == null) return false;
    return user.role.trim().toLowerCase() == AppConstants.roleViewer.toLowerCase();
  }

  static bool canViewAdminSettings(UserModel? user) {
    return isAdmin(user);
  }

  static bool canSeeProductCost(UserModel? user) {
    // Hide product cost from Branch Sales & Viewer
    return isAdmin(user) || isManagement(user) || isKeralaBackOffice(user);
  }

  static bool canApproveQuotations(UserModel? user) {
    return isAdmin(user) || isManagement(user);
  }

  static bool canChangeBranchFilter(UserModel? user) {
    return isAdmin(user) || isManagement(user) || isKeralaBackOffice(user);
  }

  static bool canEditRecords(UserModel? user) {
    return !isViewer(user);
  }

  static bool canManageUsers(UserModel? user) {
    return isAdmin(user);
  }
}

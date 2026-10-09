import 'package:flutter_test/flutter_test.dart';
import 'package:infocare_crm/models/user_model.dart';
import 'package:infocare_crm/utils/permission_utils.dart';

void main() {
  group('PermissionUtils Tests', () {
    test('Admin permissions check', () {
      final admin = UserModel(
        id: '1',
        username: 'Admin',
        name: 'Admin User',
        email: 'admin@test.com',
        role: 'admin',
        branch: 'Dubai',
      );

      expect(PermissionUtils.isAdmin(admin), isTrue);
      expect(PermissionUtils.canViewAdminSettings(admin), isTrue);
      expect(PermissionUtils.canSeeProductCost(admin), isTrue);
      expect(PermissionUtils.canApproveQuotations(admin), isTrue);
    });

    test('Branch Sales cost privacy check', () {
      final sales = UserModel(
        id: '2',
        username: 'sales',
        name: 'Sales Rep',
        email: 'sales@test.com',
        role: 'branch_sales',
        branch: 'Dubai',
      );

      expect(PermissionUtils.canSeeProductCost(sales), isFalse);
      expect(PermissionUtils.canApproveQuotations(sales), isFalse);
      expect(PermissionUtils.canViewAdminSettings(sales), isFalse);
    });
  });
}

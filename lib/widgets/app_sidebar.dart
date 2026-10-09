import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/app_routes.dart';
import '../config/app_theme.dart';
import '../controllers/auth_controller.dart';
import '../utils/permission_utils.dart';
import '../utils/responsive_utils.dart';

class AppSidebar extends StatelessWidget {
  final String currentRoute;

  const AppSidebar({
    super.key,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    final width = ResponsiveUtils.getSidebarWidth(context);
    final isCompact = width < 100;
    final user = AuthController.to.currentUser.value;
    final canViewSettings = PermissionUtils.canViewAdminSettings(user);

    return Container(
      width: width,
      decoration: const BoxDecoration(
        color: AppTheme.sidebarBg,
      ),
      child: Column(
        children: [
          // Logo & Brand Header
          Container(
            height: 64,
            padding: EdgeInsets.symmetric(horizontal: isCompact ? 12 : 20),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.bolt, color: Colors.white, size: 20),
                ),
                if (!isCompact) ...[
                  const SizedBox(width: 12),
                  const Text(
                    'InfocareCRM',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(color: Color(0xFF1E293B), height: 1),
          const SizedBox(height: 12),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: isCompact ? 6 : 12),
              children: [
                _buildNavItem(
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard,
                  label: 'Dashboard',
                  route: AppRoutes.dashboard,
                  isCompact: isCompact,
                ),
                _buildNavItem(
                  icon: Icons.inbox_outlined,
                  activeIcon: Icons.inbox,
                  label: 'Leads',
                  route: AppRoutes.leads,
                  isCompact: isCompact,
                ),
                _buildNavItem(
                  icon: Icons.view_kanban_outlined,
                  activeIcon: Icons.view_kanban,
                  label: 'Pipeline',
                  route: AppRoutes.pipeline,
                  isCompact: isCompact,
                ),
                _buildNavItem(
                  icon: Icons.request_quote_outlined,
                  activeIcon: Icons.request_quote,
                  label: 'Quotes',
                  route: AppRoutes.quotes,
                  isCompact: isCompact,
                ),
                _buildNavItem(
                  icon: Icons.people_outline,
                  activeIcon: Icons.people,
                  label: 'Customers',
                  route: AppRoutes.customers,
                  isCompact: isCompact,
                ),
                _buildNavItem(
                  icon: Icons.check_box_outlined,
                  activeIcon: Icons.check_box,
                  label: 'Tasks',
                  route: AppRoutes.tasks,
                  isCompact: isCompact,
                ),
                _buildNavItem(
                  icon: Icons.campaign_outlined,
                  activeIcon: Icons.campaign,
                  label: 'Campaigns',
                  route: AppRoutes.campaigns,
                  isCompact: isCompact,
                ),
                _buildNavItem(
                  icon: Icons.bar_chart_outlined,
                  activeIcon: Icons.bar_chart,
                  label: 'Reports',
                  route: AppRoutes.reports,
                  isCompact: isCompact,
                ),
                if (canViewSettings)
                  _buildNavItem(
                    icon: Icons.settings_outlined,
                    activeIcon: Icons.settings,
                    label: 'Settings',
                    route: AppRoutes.settings,
                    isCompact: isCompact,
                  ),
              ],
            ),
          ),

          // Footer
          if (!isCompact)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.cloud_done, size: 16, color: AppTheme.success),
                  SizedBox(width: 8),
                  Text(
                    'API Online (v1.0)',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required String route,
    required bool isCompact,
  }) {
    final isSelected = currentRoute == route;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: InkWell(
        onTap: () {
          if (!isSelected) {
            Get.offAllNamed(route);
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 0 : 12,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryTeal : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: isCompact ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? Colors.white : const TextStyle(color: AppTheme.textMuted).color,
                size: 20,
              ),
              if (!isCompact) ...[
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

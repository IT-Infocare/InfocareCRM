import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import 'app_routes.dart';
import '../screens/auth/login_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/leads/lead_list_screen.dart';
import '../screens/leads/lead_detail_screen.dart';
import '../screens/pipeline/pipeline_screen.dart';
import '../screens/quotes/quotation_list_screen.dart';
import '../screens/quotes/quotation_detail_screen.dart';
import '../screens/customers/customer_list_screen.dart';
import '../screens/customers/customer_detail_screen.dart';
import '../screens/tasks/task_list_screen.dart';
import '../screens/campaigns/campaign_list_screen.dart';
import '../screens/reports/reports_screen.dart';
import '../screens/settings/settings_screen.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (AuthController.to.isLoggedIn.value == false && route != AppRoutes.login) {
      return const RouteSettings(name: AppRoutes.login);
    }
    return null;
  }
}

class AppPages {
  static const initial = AppRoutes.login;

  static final routes = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.leads,
      page: () => const LeadListScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.leadDetail,
      page: () => const LeadDetailScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.pipeline,
      page: () => const PipelineScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.quotes,
      page: () => const QuotationListScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.quotationDetail,
      page: () => const QuotationDetailScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.customers,
      page: () => const CustomerListScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.customerDetail,
      page: () => const CustomerDetailScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.tasks,
      page: () => const TaskListScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.campaigns,
      page: () => const CampaignListScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.reports,
      page: () => const ReportsScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsScreen(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}

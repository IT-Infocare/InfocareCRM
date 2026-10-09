import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'config/app_config.dart';
import 'config/app_pages.dart';
import 'config/app_routes.dart';
import 'config/app_theme.dart';
import 'controllers/auth_controller.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Warning: .env file not found, using default app configuration.');
  }

  // Register Core Services
  Get.put(ApiService());
  Get.put(AuthController());

  runApp(const InfocareCrmApp());
}

class InfocareCrmApp extends StatelessWidget {
  const InfocareCrmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.login,
      getPages: AppPages.routes,
    );
  }
}

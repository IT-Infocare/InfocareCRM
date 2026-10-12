import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../controllers/auth_controller.dart';
import '../../services/api_service.dart';
import '../../utils/validators.dart';

import '../../utils/responsive_utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController(text: 'Admin');
  final _passwordController = TextEditingController(text: 'Info@1234');
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _prewarmBackend();
  }

  void _prewarmBackend() async {
    try {
      if (Get.isRegistered<ApiService>()) {
        await Get.find<ApiService>().get('/health');
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      AuthController.to.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );
    }
  }

  void _fillDemoUser(String username, String pass) {
    _usernameController.text = username;
    _passwordController.text = pass;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);

    return Scaffold(
      backgroundColor: AppTheme.sidebarBg,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 14 : 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: EdgeInsets.all(isMobile ? 24 : 36),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryTeal,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.bolt, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'InfocareCRM',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sign in to your CRM workspace',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                  ),
                  const SizedBox(height: 32),

                  // Username / Email
                  const Text('Username or Email', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _usernameController,
                    validator: (val) => Validators.required(val, message: 'Username is required'),
                    decoration: const InputDecoration(
                      hintText: 'Admin',
                      prefixIcon: Icon(Icons.person_outline, size: 18),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Password
                  const Text('Password', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _passwordController,
                    validator: (val) => Validators.required(val, message: 'Password is required'),
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      prefixIcon: const Icon(Icons.lock_outline, size: 18),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Obx(() {
                    if (AuthController.to.errorMessage.value.isNotEmpty) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          AuthController.to.errorMessage.value,
                          style: const TextStyle(color: AppTheme.danger, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),

                  Obx(() {
                    final isLoading = AuthController.to.isLoading.value;
                    return ElevatedButton(
                      onPressed: isLoading ? null : _handleLogin,
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Sign into CRM portal'),
                    );
                  }),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryTeal,
                      side: BorderSide(color: AppTheme.primaryTeal.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => Get.toNamed(AppRoutes.speedTest),
                    icon: const Icon(Icons.speed, size: 18),
                    label: const Text('Test Speed (Offline / No API Calls)'),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 12),
                  const Text(
                    'Quick Demo Accounts',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    alignment: WrapAlignment.center,
                    children: [
                      ActionChip(
                        label: const Text('Admin', style: TextStyle(fontSize: 11)),
                        onPressed: () => _fillDemoUser('Admin', 'Info@1234'),
                      ),
                      ActionChip(
                        label: const Text('Branch Sales', style: TextStyle(fontSize: 11)),
                        onPressed: () => _fillDemoUser('rahul.sales@infocare.ae', 'Info@1234'),
                      ),
                      ActionChip(
                        label: const Text('Management', style: TextStyle(fontSize: 11)),
                        onPressed: () => _fillDemoUser('dir.management@infocare.ae', 'Info@1234'),
                      ),
                      ActionChip(
                        label: const Text('Kerala Back Office', style: TextStyle(fontSize: 11)),
                        onPressed: () => _fillDemoUser('amal.kerala@infocare.ae', 'Info@1234'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../controllers/customer_controller.dart';
import '../../utils/currency_utils.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/loading_widget.dart';

class CustomerDetailScreen extends StatefulWidget {
  const CustomerDetailScreen({super.key});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  late final CustomerController _controller;

  @override
  void initState() {
    super.initState();
    final custId = Get.parameters['id'] ?? 'cust_001';
    _controller = Get.isRegistered<CustomerController>()
        ? Get.find<CustomerController>()
        : Get.put(CustomerController());
    _controller.selectCustomer(custId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const AppSidebar(currentRoute: AppRoutes.customers),
          Expanded(
            child: Column(
              children: [
                AppHeader(
                  title: 'Customer Profile',
                  actions: [
                    OutlinedButton.icon(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.arrow_back, size: 16),
                      label: const Text('Back to Customers'),
                    ),
                  ],
                ),
                Expanded(
                  child: Obx(() {
                    if (_controller.isLoading.value || _controller.selectedCustomer.value == null) {
                      return const LoadingWidget(message: 'Loading customer details...');
                    }

                    final c = _controller.selectedCustomer.value!;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.border),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: AppTheme.primaryTeal,
                                  child: Text(
                                    c.name.isNotEmpty ? c.name[0].toUpperCase() : 'C',
                                    style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(c.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                                      Text('${c.companyName ?? "Private Account"} • ${c.emirate ?? "Dubai, UAE"}', style: const TextStyle(color: AppTheme.textSecondary)),
                                      const SizedBox(height: 8),
                                      Text('Email: ${c.email} | Phone: ${c.phone}'),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text('Lifetime Value', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                                    Text(
                                      CurrencyUtils.format(c.totalRevenue),
                                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

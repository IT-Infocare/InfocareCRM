import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/app_constants.dart';
import '../../../config/app_theme.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/lead_controller.dart';
import '../../../controllers/settings_controller.dart';
import '../../../utils/date_utils.dart';
import '../../../utils/validators.dart';

class LeadFormDialog extends StatefulWidget {
  const LeadFormDialog({super.key});

  @override
  State<LeadFormDialog> createState() => _LeadFormDialogState();
}

class _LeadFormDialogState extends State<LeadFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _requirementController = TextEditingController();
  final _valueController = TextEditingController();

  static const List<Map<String, String>> _defaultBranches = [
    {'id': 'br_01', 'name': 'Dubai HQ Office', 'code': 'Dubai'},
    {'id': 'br_02', 'name': 'Ras Al Khaimah Branch', 'code': 'RAK'},
    {'id': 'br_03', 'name': 'Kerala Back Office', 'code': 'Kerala'},
  ];

  String _selectedSource = 'website';
  String _selectedBranchId = 'br_01';
  bool _createCustomer = true;

  List<Map<String, String>> _getAvailableBranches() {
    if (Get.isRegistered<SettingsController>()) {
      final s = Get.find<SettingsController>();
      if (s.branches.isNotEmpty) {
        return s.branches.map((b) => {
          'id': b.id,
          'name': b.name,
          'code': b.code.isNotEmpty ? b.code : b.name,
        }).toList();
      }
    }
    return _defaultBranches;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _requirementController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final user = Get.isRegistered<AuthController>() ? Get.find<AuthController>().currentUser.value : null;
      final branchesList = _getAvailableBranches();
      final selectedBranchObj = branchesList.firstWhere(
        (b) => b['id'] == _selectedBranchId,
        orElse: () => branchesList.first,
      );

      final payload = {
        'contact_name': _nameController.text.trim(),
        'company_name': _companyController.text.trim().isNotEmpty ? _companyController.text.trim() : null,
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'requirement': _requirementController.text.trim(),
        'source': _selectedSource,
        'branch_id': selectedBranchObj['id'],
        'branch': selectedBranchObj['code'] ?? selectedBranchObj['name'],
        'owner_id': user?.id ?? 'a0000000-0000-4000-a000-000000000001',
        'owner_name': user?.name ?? user?.username ?? 'Admin',
        'estimated_value': double.tryParse(_valueController.text.trim()) ?? 0,
        'status': 'new',
        'stage': 'new',
        'created_at': AppDateUtils.toLocalIsoString(),
        'create_customer': _createCustomer,
      };
      Get.find<LeadController>().createLead(payload, createCustomer: _createCustomer);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 580,
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Create New Lead',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Contact Name *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _nameController,
                            validator: (v) => Validators.required(v, message: 'Name is required'),
                            decoration: const InputDecoration(hintText: 'e.g. Ahmed Al Mansoori'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Company Name', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _companyController,
                            decoration: const InputDecoration(hintText: 'e.g. Al Maya Trading LLC'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Phone / WhatsApp *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _phoneController,
                            validator: Validators.phone,
                            decoration: const InputDecoration(hintText: '+971 50 123 4567'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Email Address *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _emailController,
                            validator: Validators.email,
                            decoration: const InputDecoration(hintText: 'ahmed@company.ae'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Lead Source', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            value: _selectedSource,
                            decoration: const InputDecoration(),
                            items: AppConstants.leadSources.map((s) {
                              return DropdownMenuItem(
                                value: s,
                                child: Text(s.replaceAll('_', ' ').toUpperCase()),
                              );
                            }).toList(),
                            onChanged: (v) {
                              if (v != null) setState(() => _selectedSource = v);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Branch', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          const SizedBox(height: 6),
                          Builder(builder: (context) {
                            final branchesList = _getAvailableBranches();
                            final validValue = branchesList.any((b) => b['id'] == _selectedBranchId)
                                ? _selectedBranchId
                                : branchesList.first['id'];
                            return DropdownButtonFormField<String>(
                              value: validValue,
                              decoration: const InputDecoration(),
                              items: branchesList.map((b) {
                                return DropdownMenuItem<String>(
                                  value: b['id']!,
                                  child: Text(b['code'] ?? b['name']!),
                                );
                              }).toList(),
                              onChanged: (v) {
                                if (v != null) setState(() => _selectedBranchId = v);
                              },
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                const Text('Requirement Details *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _requirementController,
                  validator: (v) => Validators.required(v, message: 'Requirement is required'),
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Describe project scope (e.g., 40 IP CCTV camera system installation)...',
                  ),
                ),
                const SizedBox(height: 16),

                const Text('Estimated Deal Value (AED)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _valueController,
                  keyboardType: TextInputType.number,
                  validator: Validators.number,
                  decoration: const InputDecoration(hintText: '45000'),
                ),
                const SizedBox(height: 16),

                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.accentTealBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: SwitchListTile(
                    title: const Text('Auto-create Customer Record', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    subtitle: const Text('Creates entry in Customers table & links Customer ID to Lead', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                    value: _createCustomer,
                    activeColor: AppTheme.primaryTeal,
                    onChanged: (v) => setState(() => _createCustomer = v),
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Save Lead'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

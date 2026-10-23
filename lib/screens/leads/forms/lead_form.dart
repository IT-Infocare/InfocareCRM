import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/app_constants.dart';
import '../../../config/app_theme.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/lead_controller.dart';
import '../../../controllers/settings_controller.dart';
import '../../../models/lead_model.dart';
import '../../../utils/date_utils.dart';
import '../../../utils/validators.dart';

class LeadFormDialog extends StatefulWidget {
  final LeadModel? lead;

  const LeadFormDialog({super.key, this.lead});

  @override
  State<LeadFormDialog> createState() => _LeadFormDialogState();
}

class _LeadFormDialogState extends State<LeadFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _companyController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _requirementController;
  late final TextEditingController _valueController;
  late final TextEditingController _locationController;
  late final TextEditingController _coordinatesController;
  late final TextEditingController _productController;

  static const List<Map<String, String>> _defaultBranches = [
    {'id': '3eca26c2-6156-4a1c-972b-75d9bf8d2329', 'name': 'Dubai', 'code': 'Dubai'},
    {'id': '8bfa9d6b-78e1-4419-aec2-670481aa1c75', 'name': 'RAK', 'code': 'RAK'},
    {'id': '58a0094b-70cd-43be-acf9-4b322edb487c', 'name': 'Sharjah', 'code': 'Sharjah'},
  ];

  String _selectedSource = 'website';
  String _selectedBranchId = 'br_01';
  bool _createCustomer = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final l = widget.lead;
    _nameController = TextEditingController(text: l?.contactName ?? '');
    _companyController = TextEditingController(text: l?.companyName ?? '');
    _phoneController = TextEditingController(text: l?.phone ?? '');
    _emailController = TextEditingController(text: l?.email ?? '');
    _requirementController = TextEditingController(text: l?.requirement ?? '');
    _valueController = TextEditingController(
      text: (l != null && l.estimatedValue > 0) ? l.estimatedValue.toString() : '',
    );
    _locationController = TextEditingController(text: l?.location ?? '');
    _coordinatesController = TextEditingController(
      text: (l != null && l.latitude != null && l.longitude != null)
          ? '${l.latitude}, ${l.longitude}'
          : '',
    );
    _productController = TextEditingController(text: l?.productInterest ?? '');

    if (l != null && AppConstants.leadSources.contains(l.source)) {
      _selectedSource = l.source;
    }

    final branches = _getAvailableBranches();
    if (branches.isNotEmpty) {
      if (l != null) {
        if (l.branchId != null && branches.any((b) => b['id'] == l.branchId)) {
          _selectedBranchId = l.branchId!;
        } else if (branches.any((b) => b['code']?.toLowerCase() == l.branch.toLowerCase() || b['name']?.toLowerCase() == l.branch.toLowerCase())) {
          _selectedBranchId = branches.firstWhere(
            (b) => b['code']?.toLowerCase() == l.branch.toLowerCase() || b['name']?.toLowerCase() == l.branch.toLowerCase(),
          )['id']!;
        } else {
          _selectedBranchId = branches.first['id']!;
        }
      } else {
        _selectedBranchId = branches.first['id']!;
      }
    }
  }

  List<Map<String, String>> _getAvailableBranches() {
    if (Get.isRegistered<AuthController>() && AuthController.to.branches.isNotEmpty) {
      return AuthController.to.branches.where((b) => b.isActive).map((b) => {
        'id': b.id,
        'name': b.displayShortName,
        'code': b.displayShortName,
      }).toList();
    }
    if (Get.isRegistered<SettingsController>()) {
      final s = Get.find<SettingsController>();
      if (s.branches.isNotEmpty) {
        return s.branches.where((b) => b.isActive).map((b) => {
          'id': b.id,
          'name': b.displayShortName,
          'code': b.displayShortName,
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
    _locationController.dispose();
    _coordinatesController.dispose();
    _productController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      try {
        final user = Get.isRegistered<AuthController>() ? Get.find<AuthController>().currentUser.value : null;
        final branchesList = _getAvailableBranches();
        final selectedBranchObj = branchesList.firstWhere(
          (b) => b['id'] == _selectedBranchId,
          orElse: () => branchesList.first,
        );

        final isEditing = widget.lead != null;

        // Parse coordinates from dedicated input or location input
        double? parsedLat = widget.lead?.latitude;
        double? parsedLng = widget.lead?.longitude;

        final coordText = _coordinatesController.text.trim();
        final locText = _locationController.text.trim();

        final coordRegex = RegExp(r'(-?\d{1,3}\.\d+)[,\s]+(-?\d{1,3}\.\d+)');
        final matchCoord = coordRegex.firstMatch(coordText.isNotEmpty ? coordText : locText);
        if (matchCoord != null) {
          parsedLat = double.tryParse(matchCoord.group(1)!);
          parsedLng = double.tryParse(matchCoord.group(2)!);
        }

        final payload = <String, dynamic>{
          'contact_name': _nameController.text.trim(),
          'company_name': _companyController.text.trim().isNotEmpty ? _companyController.text.trim() : null,
          'phone': _phoneController.text.trim(),
          'email': _emailController.text.trim(),
          'title': _requirementController.text.trim().isNotEmpty
              ? _requirementController.text.trim()
              : '${_nameController.text.trim()} - Enquiry',
          'requirement': _requirementController.text.trim(),
          'location': locText.isNotEmpty ? locText : (parsedLat != null ? '$parsedLat, $parsedLng' : null),
          if (parsedLat != null) 'latitude': parsedLat,
          if (parsedLng != null) 'longitude': parsedLng,
          'product_interest': _productController.text.trim().isNotEmpty ? _productController.text.trim() : null,
          'source': _selectedSource,
          'branch_id': selectedBranchObj['id'],
          'branch': selectedBranchObj['code'] ?? selectedBranchObj['name'],
          'estimated_value': double.tryParse(_valueController.text.trim()) ?? 0,
        };

        if (isEditing) {
          final success = await Get.find<LeadController>().updateLead(widget.lead!.id, payload);
          if (success) {
            Get.back();
          }
        } else {
          payload.addAll({
            'owner_id': user?.id,
            'owner_name': user?.name ?? user?.username ?? 'Admin',
            'status': 'new',
            'stage': 'new',
            'created_at': AppDateUtils.toLocalIsoString(),
            'create_customer': _createCustomer,
          });
          final success = await Get.find<LeadController>().createLead(payload, createCustomer: _createCustomer);
          if (success) {
            // Note: createLead already navigates or shows message
          }
        }
      } catch (e) {
        Get.snackbar('Error', 'Failed to save lead: $e');
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.lead != null;

    return Dialog(
      child: Container(
        width: 600,
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
                    Text(
                      isEditing ? 'Edit Lead Details' : 'Create New Lead',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
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
                          const Text('Email Address', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _emailController,
                            validator: Validators.optionalEmail,
                            decoration: const InputDecoration(hintText: 'ahmed@company.ae (optional)'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Location / Area', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _locationController,
                            decoration: const InputDecoration(
                              hintText: 'e.g. Al Mirgab, Sharjah',
                              prefixIcon: Icon(Icons.location_on_outlined, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('GPS Coordinates (Lat, Lng)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _coordinatesController,
                            decoration: const InputDecoration(
                              hintText: 'e.g. 25.390607, 55.422953',
                              prefixIcon: Icon(Icons.gps_fixed, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Products / Solutions', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _productController,
                            decoration: const InputDecoration(hintText: 'e.g. IP CCTV, Access Control'),
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

                if (!isEditing) ...[
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
                ] else
                  const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: _isSubmitting ? null : () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(isEditing ? 'Save Changes' : 'Save Lead'),
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

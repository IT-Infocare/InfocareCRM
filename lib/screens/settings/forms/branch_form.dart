import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/app_theme.dart';
import '../../../controllers/settings_controller.dart';
import '../../../models/branch_model.dart';
import '../../../utils/validators.dart';

class BranchFormDialog extends StatefulWidget {
  final BranchModel? branch;

  const BranchFormDialog({super.key, this.branch});

  @override
  State<BranchFormDialog> createState() => _BranchFormDialogState();
}

class _BranchFormDialogState extends State<BranchFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _codeController;
  late final TextEditingController _phoneController;
  late final TextEditingController _mobileController;
  late final TextEditingController _emailController;
  late final TextEditingController _locationController;
  late final TextEditingController _trNumberController;
  late final TextEditingController _addressController;
  late String _selectedTimezone;
  late bool _isActive;

  static const List<Map<String, String>> _timezones = [
    {'value': 'Asia/Dubai', 'label': 'Asia/Dubai (GST UTC+04:00)'},
    {'value': 'Asia/Kolkata', 'label': 'Asia/Kolkata (IST UTC+05:30)'},
    {'value': 'Asia/Riyadh', 'label': 'Asia/Riyadh (AST UTC+03:00)'},
    {'value': 'Europe/London', 'label': 'Europe/London (GMT UTC+00:00)'},
    {'value': 'America/New_York', 'label': 'America/New_York (EST UTC-05:00)'},
    {'value': 'Asia/Singapore', 'label': 'Asia/Singapore (SGT UTC+08:00)'},
    {'value': 'UTC', 'label': 'UTC (Universal Time UTC+00:00)'},
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.branch?.name ?? '');
    _codeController = TextEditingController(text: widget.branch?.code ?? '');
    _phoneController = TextEditingController(text: widget.branch?.phone ?? '');
    _mobileController = TextEditingController(text: widget.branch?.mobile ?? '');
    _emailController = TextEditingController(text: widget.branch?.email ?? '');
    _locationController = TextEditingController(text: widget.branch?.location ?? '');
    _trNumberController = TextEditingController(text: widget.branch?.trNumber ?? '');
    _addressController = TextEditingController(text: widget.branch?.address ?? '');
    _selectedTimezone = widget.branch?.timezone ?? 'Asia/Dubai';
    _isActive = widget.branch?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _phoneController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _trNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final payload = {
        'name': _nameController.text.trim(),
        'code': _codeController.text.trim().isNotEmpty ? _codeController.text.trim() : _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'telephone': _phoneController.text.trim(),
        'mobile': _mobileController.text.trim(),
        'mobile_number': _mobileController.text.trim(),
        'email': _emailController.text.trim(),
        'email_address': _emailController.text.trim(),
        'location': _locationController.text.trim(),
        'tr_number': _trNumberController.text.trim(),
        'trn': _trNumberController.text.trim(),
        'address': _addressController.text.trim(),
        'timezone': _selectedTimezone,
        'time_zone': _selectedTimezone,
        'is_active': _isActive,
      };

      final controller = Get.find<SettingsController>();
      if (widget.branch != null) {
        controller.updateBranch(widget.branch!.id, payload);
      } else {
        controller.createBranch(payload);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.branch != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 620,
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
                      isEditing ? 'Edit Branch Details' : 'Create New Branch',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                    IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => Get.back()),
                  ],
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Branch Name *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(hintText: 'e.g. Infocare Surveillance Systems LLC — Dubai'),
                            validator: (v) => Validators.required(v, message: 'Branch Name required'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Branch Code / Short Alias *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _codeController,
                            decoration: const InputDecoration(hintText: 'e.g. DXB'),
                            validator: (v) => Validators.required(v, message: 'Branch Code required'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Telephone Number', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _phoneController,
                            decoration: const InputDecoration(hintText: '+971 4 321 0000'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Mobile Number', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _mobileController,
                            decoration: const InputDecoration(hintText: '+971 50 123 4567'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Email Address', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(hintText: 'dubai@infocare.ae'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Location / Emirate', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _locationController,
                            decoration: const InputDecoration(hintText: 'Dubai, UAE'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tax Reg Number (TRN)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _trNumberController,
                            decoration: const InputDecoration(hintText: '100293847500003'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Time Zone Location *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            isExpanded: true,
                            value: _timezones.any((tz) => tz['value'] == _selectedTimezone) ? _selectedTimezone : 'Asia/Dubai',
                            decoration: const InputDecoration(prefixIcon: Icon(Icons.schedule, size: 18)),
                            items: _timezones.map((tz) {
                              return DropdownMenuItem<String>(
                                value: tz['value'],
                                child: Text(
                                  tz['label']!,
                                  style: const TextStyle(fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedTimezone = val);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                const Text('Physical Address', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _addressController,
                  maxLines: 2,
                  decoration: const InputDecoration(hintText: 'Business Bay, Tower B, Office 1204, Dubai, UAE'),
                ),
                const SizedBox(height: 14),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Active Operational Status', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    Switch(
                      value: _isActive,
                      activeColor: AppTheme.primaryTeal,
                      onChanged: (val) => setState(() => _isActive = val),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(onPressed: () => Get.back(), child: const Text('Cancel')),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryTeal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      onPressed: _submit,
                      child: Text(isEditing ? 'Save Changes' : 'Create Branch'),
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

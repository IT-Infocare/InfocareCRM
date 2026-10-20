import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/app_theme.dart';
import '../../../controllers/settings_controller.dart';
import '../../../models/company_model.dart';
import '../../../utils/validators.dart';

class CompanyFormDialog extends StatefulWidget {
  final CompanyModel? company;

  const CompanyFormDialog({super.key, this.company});

  @override
  State<CompanyFormDialog> createState() => _CompanyFormDialogState();
}

class _CompanyFormDialogState extends State<CompanyFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _codeController;
  late final TextEditingController _tradeLicenceController;
  late final TextEditingController _industryController;
  late final TextEditingController _taxNumberController;
  late final TextEditingController _countryController;
  late final TextEditingController _emirateController;
  late final TextEditingController _cityController;
  late final TextEditingController _addressController;
  late final TextEditingController _websiteController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _notesController;

  late bool _isActive;

  @override
  void initState() {
    super.initState();
    final c = widget.company;
    _nameController = TextEditingController(text: c?.name ?? '');
    _codeController = TextEditingController(text: c?.code ?? '');
    _tradeLicenceController = TextEditingController(text: c?.tradeLicenceNo ?? '');
    _industryController = TextEditingController(text: c?.industry ?? 'IT & Surveillance Solutions');
    _taxNumberController = TextEditingController(text: c?.taxNumber ?? '');
    _countryController = TextEditingController(text: c?.country ?? 'UAE');
    _emirateController = TextEditingController(text: c?.emirate ?? 'Dubai');
    _cityController = TextEditingController(text: c?.city ?? 'Dubai');
    _addressController = TextEditingController(text: c?.address ?? '');
    _websiteController = TextEditingController(text: c?.website ?? '');
    _phoneController = TextEditingController(text: c?.phone ?? '');
    _emailController = TextEditingController(text: c?.email ?? '');
    _notesController = TextEditingController(text: c?.notes ?? '');
    _isActive = c?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _tradeLicenceController.dispose();
    _industryController.dispose();
    _taxNumberController.dispose();
    _countryController.dispose();
    _emirateController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _websiteController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final payload = {
        'name': _nameController.text.trim(),
        'code': _codeController.text.trim().isNotEmpty
            ? _codeController.text.trim()
            : _nameController.text.trim().toUpperCase().replaceAll(' ', '_'),
        'trade_licence_no': _tradeLicenceController.text.trim(),
        'tradeLicenceNo': _tradeLicenceController.text.trim(),
        'industry': _industryController.text.trim(),
        'tax_number': _taxNumberController.text.trim(),
        'vat_number': _taxNumberController.text.trim(),
        'trn': _taxNumberController.text.trim(),
        'country': _countryController.text.trim(),
        'emirate': _emirateController.text.trim(),
        'city': _cityController.text.trim(),
        'address': _addressController.text.trim(),
        'website': _websiteController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'notes': _notesController.text.trim(),
        'is_active': _isActive,
      };

      final controller = Get.find<SettingsController>();
      if (widget.company != null) {
        controller.updateCompany(widget.company!.id, payload);
      } else {
        controller.createCompany(payload);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.company != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width > 720 ? 680 : MediaQuery.of(context).size.width * 0.94,
        constraints: BoxConstraints(
          maxWidth: 680,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.corporate_fare, color: AppTheme.primaryTeal, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isEditing ? 'Edit Parent Company' : 'Register Parent Company',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Scrollable Form Body
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Details
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Company Name *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _nameController,
                                  decoration: const InputDecoration(
                                    hintText: 'e.g. InfoCare Systems',
                                    prefixIcon: Icon(Icons.business_outlined, size: 18),
                                  ),
                                  validator: (v) => Validators.required(v, message: 'Company Name is required'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Company Code', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _codeController,
                                  decoration: const InputDecoration(hintText: 'e.g. INFOCARE'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Trade License & Industry
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Trade License No.', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _tradeLicenceController,
                                  decoration: const InputDecoration(
                                    hintText: 'e.g. CN-1029384',
                                    prefixIcon: Icon(Icons.assignment_outlined, size: 18),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Industry / Sector', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _industryController,
                                  decoration: const InputDecoration(
                                    hintText: 'e.g. IT & Surveillance Solutions',
                                    prefixIcon: Icon(Icons.domain_outlined, size: 18),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // TRN & Country
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Tax Registration No. (TRN)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _taxNumberController,
                                  decoration: const InputDecoration(
                                    hintText: '100293847500001',
                                    prefixIcon: Icon(Icons.badge_outlined, size: 18),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Country', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _countryController,
                                  decoration: const InputDecoration(
                                    hintText: 'UAE',
                                    prefixIcon: Icon(Icons.public_outlined, size: 18),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Emirate / State & City
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Emirate / State', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _emirateController,
                                  decoration: const InputDecoration(
                                    hintText: 'Dubai',
                                    prefixIcon: Icon(Icons.map_outlined, size: 18),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('City', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _cityController,
                                  decoration: const InputDecoration(
                                    hintText: 'Dubai',
                                    prefixIcon: Icon(Icons.location_city_outlined, size: 18),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Contact Phone & Email
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Headquarters Phone', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _phoneController,
                                  decoration: const InputDecoration(
                                    hintText: '+971 4 321 0000',
                                    prefixIcon: Icon(Icons.phone_outlined, size: 18),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Corporate Email', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _emailController,
                                  decoration: const InputDecoration(
                                    hintText: 'info@infocaresystems.com',
                                    prefixIcon: Icon(Icons.email_outlined, size: 18),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Website URL
                      const Text('Official Website', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _websiteController,
                        decoration: const InputDecoration(
                          hintText: 'https://infocaresystems.com',
                          prefixIcon: Icon(Icons.language_outlined, size: 18),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Address
                      const Text('Registered Headquarters Address', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _addressController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          hintText: 'Business Bay, Tower B, Office 1204, Dubai, UAE',
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(bottom: 24),
                            child: Icon(Icons.pin_drop_outlined, size: 18),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Notes
                      const Text('Notes & Corporate Overview', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _notesController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          hintText: 'Parent group company holding subsidiaries and branches.',
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(bottom: 24),
                            child: Icon(Icons.note_alt_outlined, size: 18),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Active Toggle
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _isActive ? Icons.check_circle_outline : Icons.cancel_outlined,
                                  color: _isActive ? Colors.green : Colors.grey,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Operational Status', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                    Text(
                                      _isActive ? 'Active organization entity' : 'Inactive / Archived',
                                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Switch(
                              value: _isActive,
                              activeColor: AppTheme.primaryTeal,
                              onChanged: (val) => setState(() => _isActive = val),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryTeal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                    ),
                    onPressed: _submit,
                    child: Text(isEditing ? 'Save Changes' : 'Register Company'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

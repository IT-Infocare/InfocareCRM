import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
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
  late final TextEditingController _shortNameController;
  late final TextEditingController _codeController;
  late final TextEditingController _logoUrlController;
  late final TextEditingController _managerController;
  late final TextEditingController _countryController;
  late final TextEditingController _cityController;
  late final TextEditingController _vatPercentController;
  late final TextEditingController _websiteController;
  late final TextEditingController _poBoxController;
  late final TextEditingController _phoneController;
  late final TextEditingController _mobileController;
  late final TextEditingController _emailController;
  late final TextEditingController _locationController;
  late final TextEditingController _trNumberController;
  late final TextEditingController _addressController;

  late String _selectedCompanyId;
  late String _selectedCurrency;
  late String _selectedTimezone;
  late bool _isActive;
  String _logoUrl = '';
  bool _showUrlField = false;

  static const List<String> _currencies = [
    'AED',
    'INR',
    'SAR',
    'QAR',
    'OMR',
    'KWD',
    'BHD',
    'USD',
    'EUR',
    'GBP',
  ];

  static const List<Map<String, String>> _timezones = [
    {'value': 'Asia/Dubai', 'label': 'Asia/Dubai (GST UTC+04:00)'},
    {'value': 'Asia/Baghdad', 'label': 'Asia/Baghdad (AST UTC+03:00)'},
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
    final b = widget.branch;
    final controller = Get.isRegistered<SettingsController>() ? Get.find<SettingsController>() : null;
    if (b != null && b.companyId.isNotEmpty) {
      _selectedCompanyId = b.companyId;
    } else if (controller != null && controller.companies.isNotEmpty) {
      _selectedCompanyId = controller.companies.first.id;
    } else {
      _selectedCompanyId = 'cmp_01';
    }
    _nameController = TextEditingController(text: b?.name ?? '');
    _shortNameController = TextEditingController(text: b?.shortName ?? '');
    _codeController = TextEditingController(text: b?.code ?? '');
    _logoUrl = b?.logoUrl ?? '';
    _logoUrlController = TextEditingController(text: _logoUrl);
    _managerController = TextEditingController(text: b?.manager ?? '');
    _countryController = TextEditingController(text: b?.country ?? 'UAE');
    _cityController = TextEditingController(text: b?.city ?? 'Dubai');
    _vatPercentController = TextEditingController(text: b != null ? b.vatPercent.toStringAsFixed(1) : '5.0');
    _websiteController = TextEditingController(text: b?.website ?? '');
    _poBoxController = TextEditingController(text: b?.poBox ?? '');
    _phoneController = TextEditingController(text: b?.phone ?? '');
    _mobileController = TextEditingController(text: b?.mobile ?? '');
    _emailController = TextEditingController(text: b?.email ?? '');
    _locationController = TextEditingController(text: b?.location ?? '');
    _trNumberController = TextEditingController(text: b?.trNumber ?? '');
    _addressController = TextEditingController(text: b?.address ?? '');

    _selectedCurrency = (b?.currency.isNotEmpty == true && _currencies.contains(b!.currency)) ? b.currency : 'AED';
    _selectedTimezone = (b?.timezone.isNotEmpty == true && _timezones.any((tz) => tz['value'] == b!.timezone))
        ? b!.timezone
        : 'Asia/Dubai';
    _isActive = b?.isActive ?? true;

    if (_logoUrl.isNotEmpty && !_logoUrl.startsWith('data:')) {
      _showUrlField = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _shortNameController.dispose();
    _codeController.dispose();
    _logoUrlController.dispose();
    _managerController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _vatPercentController.dispose();
    _websiteController.dispose();
    _poBoxController.dispose();
    _phoneController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _trNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg', 'webp'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null) {
          final ext = (file.extension ?? 'png').toLowerCase();
          final mime = (ext == 'jpg' || ext == 'jpeg')
              ? 'image/jpeg'
              : (ext == 'webp' ? 'image/webp' : 'image/png');
          final base64Str = base64Encode(file.bytes!);
          final dataUri = 'data:$mime;base64,$base64Str';

          setState(() {
            _logoUrl = dataUri;
            _logoUrlController.text = dataUri;
          });
        }
      }
    } catch (e) {
      Get.snackbar('File Picker Error', 'Could not select image: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900);
    }
  }

  void _clearLogo() {
    setState(() {
      _logoUrl = '';
      _logoUrlController.text = '';
    });
  }

  Uint8List? _getLogoBytes(String url) {
    try {
      if (url.startsWith('data:')) {
        final commaIndex = url.indexOf(',');
        if (commaIndex != -1) {
          return base64Decode(url.substring(commaIndex + 1));
        }
        return base64Decode(url);
      }
    } catch (_) {}
    return null;
  }

  Widget _buildLogoPreview() {
    Widget imageChild;
    final logo = _logoUrl.trim();

    if (logo.isNotEmpty) {
      if (logo.startsWith('data:')) {
        final bytes = _getLogoBytes(logo);
        if (bytes != null) {
          imageChild = Image.memory(
            bytes,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_outlined, color: Colors.grey, size: 28),
          );
        } else {
          imageChild = const Icon(Icons.storefront_outlined, color: AppTheme.primaryTeal, size: 32);
        }
      } else if (logo.startsWith('http://') || logo.startsWith('https://')) {
        imageChild = Image.network(
          logo,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_outlined, color: Colors.grey, size: 28),
        );
      } else {
        imageChild = const Icon(Icons.storefront_outlined, color: AppTheme.primaryTeal, size: 32);
      }
    } else {
      imageChild = const Icon(Icons.storefront_outlined, color: AppTheme.primaryTeal, size: 32);
    }

    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1.2),
      ),
      clipBehavior: Clip.antiAlias,
      child: Center(child: imageChild),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final vatVal = double.tryParse(_vatPercentController.text.trim()) ?? 5.0;
      final controller = Get.find<SettingsController>();

      final payload = {
        'company_id': _selectedCompanyId,
        'company_name': controller.getCompanyName(_selectedCompanyId),
        'name': _nameController.text.trim(),
        'short_name': _shortNameController.text.trim().isNotEmpty ? _shortNameController.text.trim() : _codeController.text.trim(),
        'shortName': _shortNameController.text.trim().isNotEmpty ? _shortNameController.text.trim() : _codeController.text.trim(),
        'code': _codeController.text.trim().isNotEmpty ? _codeController.text.trim() : _nameController.text.trim(),
        'logo_url': _logoUrl.trim(),
        'logo': _logoUrl.trim(),
        'manager': _managerController.text.trim(),
        'contact_person': _managerController.text.trim(),
        'country': _countryController.text.trim(),
        'city': _cityController.text.trim(),
        'currency': _selectedCurrency,
        'vat_percent': vatVal,
        'vat_rate': vatVal,
        'website': _websiteController.text.trim(),
        'website_url': _websiteController.text.trim(),
        'po_box': _poBoxController.text.trim(),
        'postal_code': _poBoxController.text.trim(),
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
                        child: const Icon(Icons.storefront, color: AppTheme.primaryTeal, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isEditing ? 'Edit Branch Details' : 'Create New Branch',
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

              // Scrollable Body
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section 1: Logo Banner
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Branch Logo & Branding',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.textPrimary),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _buildLogoPreview(),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppTheme.primaryTeal,
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                              elevation: 0,
                                            ),
                                            onPressed: _pickLogo,
                                            icon: const Icon(Icons.upload_file_outlined, size: 16),
                                            label: const Text('Choose Image', style: TextStyle(fontSize: 13)),
                                          ),
                                          if (_logoUrl.isNotEmpty)
                                            OutlinedButton.icon(
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: Colors.red.shade700,
                                                side: BorderSide(color: Colors.red.shade200),
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                              ),
                                              onPressed: _clearLogo,
                                              icon: const Icon(Icons.delete_outline, size: 16),
                                              label: const Text('Remove', style: TextStyle(fontSize: 13)),
                                            ),
                                          TextButton.icon(
                                            onPressed: () => setState(() => _showUrlField = !_showUrlField),
                                            icon: Icon(_showUrlField ? Icons.link_off : Icons.link, size: 16),
                                            label: Text(_showUrlField ? 'Hide URL' : 'Use Image URL', style: const TextStyle(fontSize: 12)),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'PNG, JPG, WEBP. Stored with branch configuration.',
                                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (_showUrlField) ...[
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _logoUrlController,
                                decoration: const InputDecoration(
                                  labelText: 'Logo Image URL or Data URI',
                                  hintText: 'https://infocare.ae/logo.png',
                                  prefixIcon: Icon(Icons.image_outlined, size: 18),
                                ),
                                onChanged: (val) => setState(() => _logoUrl = val.trim()),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Section: Parent Company
                      GetBuilder<SettingsController>(
                        init: Get.isRegistered<SettingsController>() ? Get.find<SettingsController>() : null,
                        builder: (sController) {
                          final companies = sController.companies;
                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppTheme.accentTealBg.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.corporate_fare, size: 18, color: AppTheme.primaryTeal),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Parent Company (Holding Entity) *',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textPrimary),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                companies.isNotEmpty
                                    ? DropdownButtonFormField<String>(
                                        value: companies.any((c) => c.id == _selectedCompanyId)
                                            ? _selectedCompanyId
                                            : companies.first.id,
                                        isExpanded: true,
                                        decoration: const InputDecoration(
                                          fillColor: Colors.white,
                                          filled: true,
                                          hintText: 'Select Parent Organization',
                                          prefixIcon: Icon(Icons.apartment, size: 18, color: AppTheme.primaryTeal),
                                        ),
                                        items: companies.map((c) {
                                          return DropdownMenuItem<String>(
                                            value: c.id,
                                            child: Text(
                                              '${c.name} (${c.code.isNotEmpty ? c.code : "Parent"})',
                                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (val) {
                                          if (val != null) setState(() => _selectedCompanyId = val);
                                        },
                                      )
                                    : Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: AppTheme.border),
                                            ),
                                            child: const Text(
                                              'InfoCare Systems (Default Group Parent)',
                                              style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.primaryTeal),
                                            ),
                                          ),
                                        ],
                                      ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Section 2: Basic Info
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
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
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Branch Short Name *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _shortNameController,
                                  decoration: const InputDecoration(hintText: 'e.g. Dubai or Dubai HQ'),
                                  validator: (v) => Validators.required(v, message: 'Short Name required'),
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
                                const Text('Branch Code *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _codeController,
                                  decoration: const InputDecoration(hintText: 'e.g. DXB'),
                                  validator: (v) => Validators.required(v, message: 'Code required'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Section 3: Manager & Regional Location
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Branch Manager / Contact Person', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _managerController,
                                  decoration: const InputDecoration(
                                    hintText: 'e.g. Sarah Connor',
                                    prefixIcon: Icon(Icons.person_outline, size: 18),
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
                                    hintText: 'e.g. Dubai or Ras Al Khaimah',
                                    prefixIcon: Icon(Icons.location_city_outlined, size: 18),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Section 4: Country & Location/Emirate
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Country', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _countryController,
                                  decoration: const InputDecoration(
                                    hintText: 'e.g. UAE or India',
                                    prefixIcon: Icon(Icons.public_outlined, size: 18),
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
                                const Text('Location / Emirate / State', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _locationController,
                                  decoration: const InputDecoration(
                                    hintText: 'Dubai, UAE',
                                    prefixIcon: Icon(Icons.map_outlined, size: 18),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Section 5: Currency, VAT Rate, Timezone
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Base Currency *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  value: _selectedCurrency,
                                  decoration: const InputDecoration(prefixIcon: Icon(Icons.monetization_on_outlined, size: 18)),
                                  items: _currencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                                  onChanged: (val) {
                                    if (val != null) setState(() => _selectedCurrency = val);
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Default VAT / Tax (%) *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _vatPercentController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: const InputDecoration(
                                    hintText: '5.0',
                                    prefixIcon: Icon(Icons.percent, size: 18),
                                    suffixText: '%',
                                  ),
                                  validator: (v) => Validators.required(v, message: 'VAT % required'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Time Zone *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  value: _selectedTimezone,
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

                      // Section 6: Contact Numbers
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
                                const Text('Mobile Number', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _mobileController,
                                  decoration: const InputDecoration(
                                    hintText: '+971 50 123 4567',
                                    prefixIcon: Icon(Icons.smartphone_outlined, size: 18),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Section 7: Email & Website
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
                                  decoration: const InputDecoration(
                                    hintText: 'dubai@infocare.ae',
                                    prefixIcon: Icon(Icons.email_outlined, size: 18),
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
                                const Text('Website URL', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _websiteController,
                                  decoration: const InputDecoration(
                                    hintText: 'https://infocare.ae',
                                    prefixIcon: Icon(Icons.language_outlined, size: 18),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Section 8: TRN & PO Box
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
                                  decoration: const InputDecoration(
                                    hintText: '100293847500003',
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
                                const Text('P.O. Box / Postal Code', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _poBoxController,
                                  decoration: const InputDecoration(
                                    hintText: 'P.O. Box 12345, Dubai',
                                    prefixIcon: Icon(Icons.markunread_mailbox_outlined, size: 18),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Section 9: Address
                      const Text('Physical Address', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
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

                      // Section 10: Active Status Toggle
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
                                      _isActive ? 'Active and available across transactions' : 'Inactive (archived)',
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
                    child: Text(isEditing ? 'Save Changes' : 'Create Branch'),
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

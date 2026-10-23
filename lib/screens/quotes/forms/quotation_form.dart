import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/app_theme.dart';
import '../../../controllers/customer_controller.dart';
import '../../../controllers/quotation_controller.dart';
import '../../../utils/validators.dart';

class QuotationFormDialog extends StatefulWidget {
  const QuotationFormDialog({super.key});

  @override
  State<QuotationFormDialog> createState() => _QuotationFormDialogState();
}

class _QuotationFormDialogState extends State<QuotationFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _termsController = TextEditingController(
    text: '50% advance, 50% upon installation completion. 1 year warranty included.',
  );
  String? _selectedCustomerId;
  DateTime _validUntil = DateTime.now().add(const Duration(days: 14));

  @override
  void initState() {
    super.initState();
    final custCtrl = Get.put(CustomerController());
    custCtrl.fetchAllCustomers();
    final list = custCtrl.allCustomers.isNotEmpty ? custCtrl.allCustomers : custCtrl.customers;
    if (list.isNotEmpty) {
      _selectedCustomerId = list.first.id;
    }
  }

  @override
  void dispose() {
    _termsController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _selectedCustomerId != null) {
      final custCtrl = Get.find<CustomerController>();
      final list = custCtrl.allCustomers.isNotEmpty ? custCtrl.allCustomers : custCtrl.customers;
      final cust = list.firstWhereOrNull((c) => c.id == _selectedCustomerId);
      final payload = {
        'customer_id': _selectedCustomerId,
        'customer_name': cust?.companyName ?? cust?.name ?? 'Customer',
        'terms': _termsController.text.trim(),
        'valid_until': _validUntil.toIso8601String(),
      };
      Get.find<QuotationController>().createQuotation(payload);
    }
  }

  @override
  Widget build(BuildContext context) {
    final custCtrl = Get.put(CustomerController());

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 560,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
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
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.accentTealBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.request_quote_rounded, color: AppTheme.primaryTeal, size: 22),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Create New Quotation / BOQ',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20, color: AppTheme.textSecondary),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Customer selection
                const Text('Select Customer *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.textPrimary)),
                const SizedBox(height: 6),
                Obx(() {
                  final custList = custCtrl.allCustomers.isNotEmpty
                      ? custCtrl.allCustomers
                      : custCtrl.customers;

                  if (custList.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.border),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                          SizedBox(width: 12),
                          Text('Loading customers...', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                        ],
                      ),
                    );
                  }

                  final effectiveId = (custList.any((c) => c.id == _selectedCustomerId))
                      ? _selectedCustomerId
                      : custList.first.id;

                  if (_selectedCustomerId != effectiveId) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) setState(() => _selectedCustomerId = effectiveId);
                    });
                  }

                  return DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: effectiveId,
                    validator: (v) => v == null ? 'Customer is required' : null,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.border)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.border)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.primaryTeal, width: 1.5)),
                    ),
                    items: custList.map((c) {
                      final company = (c.companyName != null && c.companyName!.trim().isNotEmpty) ? ' · ${c.companyName!.trim()}' : '';
                      return DropdownMenuItem<String>(
                        value: c.id,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.accentTealBg,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.2)),
                              ),
                              child: Text(
                                c.branch.isNotEmpty ? c.branch : 'Dubai',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${c.name}$company',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (v) {
                      setState(() {
                        _selectedCustomerId = v;
                      });
                    },
                  );
                }),
                const SizedBox(height: 16),

                // Terms
                const Text('Payment & Warranty Terms', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.textPrimary)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _termsController,
                  maxLines: 3,
                  validator: (v) => Validators.required(v, message: 'Terms required'),
                  decoration: InputDecoration(
                    hintText: 'Enter quotation payment terms...',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.border)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.primaryTeal, width: 1.5)),
                  ),
                ),
                const SizedBox(height: 16),

                // Valid until date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Valid Until Date', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.textPrimary)),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _validUntil,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 180)),
                        );
                        if (picked != null) setState(() => _validUntil = picked);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.calendar_today, size: 16, color: AppTheme.primaryTeal),
                      label: Text(
                        '${_validUntil.day.toString().padLeft(2, '0')}/${_validUntil.month.toString().padLeft(2, '0')}/${_validUntil.year}',
                        style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryTeal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.add_circle_outline, size: 18),
                      label: const Text('Create Draft Quote', style: TextStyle(fontWeight: FontWeight.bold)),
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

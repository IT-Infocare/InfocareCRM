import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  final _termsController = TextEditingController(text: '50% advance, 50% upon installation completion. 1 year warranty included.');
  String? _selectedCustomerId;
  DateTime _validUntil = DateTime.now().add(const Duration(days: 14));

  @override
  void initState() {
    super.initState();
    final custCtrl = Get.put(CustomerController());
    if (custCtrl.customers.isNotEmpty) {
      _selectedCustomerId = custCtrl.customers.first.id;
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
      final cust = custCtrl.customers.firstWhereOrNull((c) => c.id == _selectedCustomerId);
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
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Create New Quotation / BOQ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => Get.back()),
                ],
              ),
              const SizedBox(height: 20),

              const Text('Select Customer *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedCustomerId,
                validator: (v) => v == null ? 'Customer is required' : null,
                items: custCtrl.customers.map((c) {
                  return DropdownMenuItem(value: c.id, child: Text('${c.name} (${c.companyName ?? "Private"})'));
                }).toList(),
                onChanged: (v) {
                  setState(() {
                    _selectedCustomerId = v;
                  });
                },
              ),
              const SizedBox(height: 16),

              const Text('Payment & Warranty Terms', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _termsController,
                maxLines: 3,
                validator: (v) => Validators.required(v, message: 'Terms required'),
                decoration: const InputDecoration(hintText: 'Enter quotation payment terms...'),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Valid Until Date', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
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
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text('${_validUntil.day}/${_validUntil.month}/${_validUntil.year}'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(onPressed: () => Get.back(), child: const Text('Cancel')),
                  const SizedBox(width: 12),
                  ElevatedButton(onPressed: _submit, child: const Text('Create Draft Quote')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

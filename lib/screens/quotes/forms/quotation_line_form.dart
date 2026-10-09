import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/settings_controller.dart';
import '../../../models/quotation_item_model.dart';
import '../../../utils/validators.dart';

class QuotationLineFormDialog extends StatefulWidget {
  final ValueChanged<QuotationItemModel> onAddLine;

  const QuotationLineFormDialog({super.key, required this.onAddLine});

  @override
  State<QuotationLineFormDialog> createState() => _QuotationLineFormDialogState();
}

class _QuotationLineFormDialogState extends State<QuotationLineFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();
  final _qtyController = TextEditingController(text: '1');
  final _priceController = TextEditingController(text: '0');
  final _discController = TextEditingController(text: '0');

  String? _selectedProductId;
  String? _selectedProductName;

  @override
  void initState() {
    super.initState();
    final setCtrl = Get.put(SettingsController());
    if (setCtrl.products.isNotEmpty) {
      final p = setCtrl.products.first;
      _selectedProductId = p.id;
      _selectedProductName = p.name;
      _priceController.text = p.unitPrice.toString();
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    _qtyController.dispose();
    _priceController.dispose();
    _discController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _selectedProductId != null) {
      final qty = int.tryParse(_qtyController.text) ?? 1;
      final price = double.tryParse(_priceController.text) ?? 0;
      final disc = double.tryParse(_discController.text) ?? 0;

      final total = (qty * price) * (1 - (disc / 100));

      final item = QuotationItemModel(
        id: 'qti_${DateTime.now().millisecondsSinceEpoch}',
        productId: _selectedProductId!,
        productName: _selectedProductName!,
        description: _descController.text.trim(),
        quantity: qty,
        unitPrice: price,
        discount: disc,
        lineTotal: total,
        sortOrder: 1,
      );

      widget.onAddLine(item);
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final setCtrl = Get.put(SettingsController());

    return Dialog(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Add Line Item to BOQ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => Get.back()),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Select Product *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedProductId,
                items: setCtrl.products.map((p) {
                  return DropdownMenuItem(value: p.id, child: Text('${p.name} (SKU: ${p.sku})'));
                }).toList(),
                onChanged: (v) {
                  if (v != null) {
                    final prod = setCtrl.products.firstWhere((x) => x.id == v);
                    setState(() {
                      _selectedProductId = v;
                      _selectedProductName = prod.name;
                      _priceController.text = prod.unitPrice.toString();
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              const Text('Item Specification / Note', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(hintText: 'e.g. Includes mounting bracket & 1yr warranty'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Quantity *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _qtyController,
                          keyboardType: TextInputType.number,
                          validator: Validators.number,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Unit Price (AED)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          validator: Validators.number,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Discount %', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _discController,
                          keyboardType: TextInputType.number,
                          validator: Validators.number,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(onPressed: () => Get.back(), child: const Text('Cancel')),
                  const SizedBox(width: 12),
                  ElevatedButton(onPressed: _submit, child: const Text('Add Line Item')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/settings_controller.dart';
import '../../../utils/validators.dart';

class ProductFormDialog extends StatefulWidget {
  const ProductFormDialog({super.key});

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _categoryController = TextEditingController(text: 'CCTV');
  final _unitPriceController = TextEditingController();
  final _costPriceController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _categoryController.dispose();
    _unitPriceController.dispose();
    _costPriceController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final payload = {
        'name': _nameController.text.trim(),
        'sku': _skuController.text.trim(),
        'category': _categoryController.text.trim(),
        'unit_price': double.tryParse(_unitPriceController.text.trim()) ?? 0.0,
        'cost_price': double.tryParse(_costPriceController.text.trim()) ?? 0.0,
      };
      Get.find<SettingsController>().createProduct(payload);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 480,
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
                  const Text('Add Catalog Product', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => Get.back()),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Product Name *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                validator: (v) => Validators.required(v, message: 'Name required'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('SKU Code *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _skuController,
                          validator: (v) => Validators.required(v, message: 'SKU required'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Category', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextFormField(controller: _categoryController),
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
                        const Text('Selling Unit Price (AED) *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _unitPriceController,
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
                        const Text('Cost Price (Restricted Admin)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _costPriceController,
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
                  ElevatedButton(onPressed: _submit, child: const Text('Save Product')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

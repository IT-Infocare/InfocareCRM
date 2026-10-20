import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/app_theme.dart';
import '../../../controllers/product_controller.dart';
import '../../../models/product_bundle_model.dart';
import '../../../models/product_model.dart';
import '../../../utils/currency_utils.dart';
import '../../../utils/validators.dart';

class ProductBundleFormDialog extends StatefulWidget {
  final ProductBundleModel? bundle;

  const ProductBundleFormDialog({super.key, this.bundle});

  @override
  State<ProductBundleFormDialog> createState() => _ProductBundleFormDialogState();
}

class _SelectedBundleItem {
  ProductModel product;
  int quantity;

  _SelectedBundleItem({required this.product, required this.quantity});
}

class _ProductBundleFormDialogState extends State<ProductBundleFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final TextEditingController _priceController;

  final List<_SelectedBundleItem> _items = [];

  bool get isEditing => widget.bundle != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.bundle?.name ?? '');
    _descController = TextEditingController(text: widget.bundle?.description ?? '');
    _priceController = TextEditingController(
      text: widget.bundle != null ? widget.bundle!.bundlePrice.toString() : '',
    );

    if (widget.bundle != null) {
      for (final item in widget.bundle!.items) {
        _items.add(_SelectedBundleItem(product: item.product, quantity: item.quantity));
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  double get _calculatedRetailTotal {
    return _items.fold(0.0, (sum, item) => sum + (item.product.unitPrice * item.quantity));
  }

  void _addItem(ProductModel product) {
    final existingIdx = _items.indexWhere((i) => i.product.id == product.id);
    setState(() {
      if (existingIdx != -1) {
        _items[existingIdx].quantity += 1;
      } else {
        _items.add(_SelectedBundleItem(product: product, quantity: 1));
      }
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final payload = {
        'name': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'bundle_price': double.tryParse(_priceController.text.trim()) ?? 0.0,
        'items': _items.map((i) => {
          'product': i.product.toJson(),
          'quantity': i.quantity,
        }).toList(),
      };

      if (Get.isRegistered<ProductController>()) {
        Get.find<ProductController>().createBundle(payload);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productCtrl = Get.isRegistered<ProductController>() ? Get.find<ProductController>() : null;
    final availableProducts = productCtrl?.products ?? <ProductModel>[];

    return Dialog(
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
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
                  Text(
                    isEditing ? 'Edit Product Bundle' : 'Create Product Bundle',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => Get.back()),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Bundle Name *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nameController,
                        validator: (v) => Validators.required(v, message: 'Bundle name required'),
                        decoration: const InputDecoration(
                          hintText: 'e.g. Standard 8-Camera Complete Package',
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Description', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _descController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          hintText: 'Includes cameras, NVR, storage, and standard setup...',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Package Price (AED) *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _priceController,
                                  keyboardType: TextInputType.number,
                                  validator: Validators.number,
                                  decoration: const InputDecoration(hintText: 'e.g. 12500'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.background,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppTheme.border),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Sum of Individual Items', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                                  const SizedBox(height: 4),
                                  Text(
                                    CurrencyUtils.format(_calculatedRetailTotal),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryTeal),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Included Products', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          if (availableProducts.isNotEmpty)
                            PopupMenuButton<ProductModel>(
                              tooltip: 'Add item to bundle',
                              itemBuilder: (context) {
                                return availableProducts.map((p) {
                                  return PopupMenuItem<ProductModel>(
                                    value: p,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(p.name, style: const TextStyle(fontSize: 13)),
                                        Text(CurrencyUtils.format(p.unitPrice), style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                                      ],
                                    ),
                                  );
                                }).toList();
                              },
                              onSelected: _addItem,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.add, size: 16, color: AppTheme.primaryTeal),
                                    SizedBox(width: 4),
                                    Text('Add Product', style: TextStyle(color: AppTheme.primaryTeal, fontSize: 12, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_items.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.background,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.border, style: BorderStyle.solid),
                          ),
                          child: const Center(
                            child: Text(
                              'No products added yet. Click "+ Add Product" to attach items to this bundle.',
                              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _items.length,
                          separatorBuilder: (_, __) => const Divider(height: 8),
                          itemBuilder: (context, index) {
                            final item = _items[index];
                            return Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                      Text('${item.product.sku} • ${CurrencyUtils.format(item.product.unitPrice)} each',
                                          style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, size: 18),
                                      onPressed: () {
                                        setState(() {
                                          if (item.quantity > 1) {
                                            item.quantity -= 1;
                                          } else {
                                            _items.removeAt(index);
                                          }
                                        });
                                      },
                                    ),
                                    Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline, size: 18),
                                      onPressed: () {
                                        setState(() {
                                          item.quantity += 1;
                                        });
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                      onPressed: () => _removeItem(index),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(onPressed: () => Get.back(), child: const Text('Cancel')),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _submit,
                    child: Text(isEditing ? 'Update Bundle' : 'Save Bundle'),
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

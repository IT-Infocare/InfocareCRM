import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/app_theme.dart';
import '../../../controllers/settings_controller.dart';
import '../../../models/product_model.dart';
import '../../../models/quotation_item_model.dart';
import '../../../utils/validators.dart';

class QuotationLineFormDialog extends StatefulWidget {
  final ValueChanged<QuotationItemModel> onAddLine;
  final QuotationItemModel? initialItem;

  const QuotationLineFormDialog({
    super.key,
    required this.onAddLine,
    this.initialItem,
  });

  @override
  State<QuotationLineFormDialog> createState() => _QuotationLineFormDialogState();
}

class _QuotationLineFormDialogState extends State<QuotationLineFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();
  final _qtyController = TextEditingController(text: '1');
  final _priceController = TextEditingController(text: '0');
  final _discController = TextEditingController(text: '0');
  final _customNameController = TextEditingController();

  bool _isCustom = false;
  String? _selectedProductId;
  String? _selectedProductName;

  @override
  void initState() {
    super.initState();
    final setCtrl = Get.put(SettingsController());
    if (widget.initialItem != null) {
      final item = widget.initialItem!;
      final inCatalogue = setCtrl.products.any((p) => p.id == item.productId);
      _isCustom = !inCatalogue || item.productId.startsWith('custom_') || item.productId.isEmpty;
      _selectedProductId = item.productId;
      _selectedProductName = item.productName;
      if (_isCustom) {
        _customNameController.text = item.productName;
      }
      _descController.text = item.description ?? '';
      _qtyController.text = item.quantity.toString();
      _priceController.text = item.unitPrice.toString();
      _discController.text = item.discount.toString();
    } else {
      if (setCtrl.products.isNotEmpty) {
        final p = setCtrl.products.first;
        _selectedProductId = p.id;
        _selectedProductName = p.name;
        _priceController.text = p.unitPrice.toString();
        if (p.description != null && p.description!.isNotEmpty) {
          _descController.text = p.description!;
        }
      }
    }

    _qtyController.addListener(_rebuild);
    _priceController.addListener(_rebuild);
    _discController.addListener(_rebuild);
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _descController.dispose();
    _qtyController.dispose();
    _priceController.dispose();
    _discController.dispose();
    _customNameController.dispose();
    super.dispose();
  }

  void _onProductSelected(ProductModel p) {
    setState(() {
      _selectedProductId = p.id;
      _selectedProductName = p.name;
      _priceController.text = p.unitPrice.toString();
      if (p.description != null && p.description!.isNotEmpty) {
        _descController.text = p.description!;
      }
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final name = _isCustom ? _customNameController.text.trim() : (_selectedProductName ?? '');
    final prodId = _isCustom
        ? (widget.initialItem != null && widget.initialItem!.productId.startsWith('custom_')
            ? widget.initialItem!.productId
            : 'custom_${DateTime.now().millisecondsSinceEpoch}')
        : (_selectedProductId ?? '');

    if (name.isEmpty) {
      Get.snackbar(
        'Product Required',
        _isCustom ? 'Please enter a custom product name' : 'Please select a product from the list',
        backgroundColor: Colors.amber.shade800,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final qty = int.tryParse(_qtyController.text) ?? 1;
    final price = double.tryParse(_priceController.text) ?? 0.0;
    final disc = double.tryParse(_discController.text) ?? 0.0;

    if (qty <= 0) {
      Get.snackbar('Invalid Quantity', 'Quantity must be at least 1',
          backgroundColor: Colors.red.shade700, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (price < 0) {
      Get.snackbar('Invalid Price', 'Price cannot be negative',
          backgroundColor: Colors.red.shade700, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final subtotal = qty * price;
    final discAmount = subtotal * (disc / 100.0);
    final total = (subtotal - discAmount).clamp(0.0, double.infinity);

    final item = QuotationItemModel(
      id: widget.initialItem?.id ?? 'qti_${DateTime.now().millisecondsSinceEpoch}',
      productId: prodId,
      productName: name,
      description: _descController.text.trim(),
      quantity: qty,
      unitPrice: price,
      discount: disc,
      lineTotal: total,
      sortOrder: widget.initialItem?.sortOrder ?? 1,
    );

    widget.onAddLine(item);
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final setCtrl = Get.put(SettingsController());

    final qty = int.tryParse(_qtyController.text) ?? 1;
    final price = double.tryParse(_priceController.text) ?? 0.0;
    final disc = double.tryParse(_discController.text) ?? 0.0;
    final subtotal = qty * price;
    final discAmount = subtotal * (disc / 100.0);
    final netTotal = (subtotal - discAmount).clamp(0.0, double.infinity);

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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.accentTealBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.playlist_add_rounded, color: AppTheme.primaryTeal, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.initialItem != null ? 'Edit BOQ Line Item' : 'Add Line Item to BOQ',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: AppTheme.textSecondary),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Item Mode Selector (Catalogue vs Custom)
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _isCustom = false),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: !_isCustom ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: !_isCustom
                                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 4, offset: const Offset(0, 1))]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Select from Catalogue',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: !_isCustom ? FontWeight.bold : FontWeight.w500,
                              color: !_isCustom ? AppTheme.primaryTeal : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _isCustom = true),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _isCustom ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: _isCustom
                                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 4, offset: const Offset(0, 1))]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '+ Custom Item / Service',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: _isCustom ? FontWeight.bold : FontWeight.w500,
                              color: _isCustom ? AppTheme.primaryTeal : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Product Selector or Custom Name
              if (!_isCustom) ...[
                const Text('Select Product *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.textPrimary)),
                const SizedBox(height: 6),
                Obx(() {
                  final products = setCtrl.products;

                  if (products.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.border),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                          const SizedBox(width: 12),
                          const Expanded(child: Text('Loading product catalog...', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary))),
                          TextButton(
                            onPressed: () => setState(() => _isCustom = true),
                            child: const Text('Use Custom Item'),
                          ),
                        ],
                      ),
                    );
                  }

                  // Determine active selected ID
                  final effectiveId = (products.any((p) => p.id == _selectedProductId))
                      ? _selectedProductId
                      : products.first.id;

                  // Sync product details if not set
                  if (_selectedProductId != effectiveId) {
                    final current = products.firstWhere((p) => p.id == effectiveId);
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() {
                          _selectedProductId = current.id;
                          _selectedProductName = current.name;
                          _priceController.text = current.unitPrice.toString();
                          if (_descController.text.isEmpty && current.description != null) {
                            _descController.text = current.description!;
                          }
                        });
                      }
                    });
                  }

                  return DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: effectiveId,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.border)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.border)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.primaryTeal, width: 1.5)),
                    ),
                    items: products.map((p) {
                      return DropdownMenuItem<String>(
                        value: p.id,
                        child: Row(
                          children: [
                            if (p.category != null && p.category!.isNotEmpty) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentTealBg,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.2)),
                                ),
                                child: Text(
                                  p.category!,
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Expanded(
                              child: Text(
                                '${p.name} (${p.sku})',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'AED ${p.unitPrice}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) {
                        final prod = products.firstWhereOrNull((x) => x.id == v);
                        if (prod != null) {
                          _onProductSelected(prod);
                        }
                      }
                    },
                  );
                }),
              ] else ...[
                const Text('Custom Product / Service Name *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.textPrimary)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _customNameController,
                  autofocus: true,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Item name is required' : null,
                  decoration: InputDecoration(
                    hintText: 'e.g. Cisco Firepower Firewall / Rack Cable Dressing',
                    prefixIcon: const Icon(Icons.edit_note, size: 20, color: AppTheme.primaryTeal),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.border)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.primaryTeal, width: 1.5)),
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // Item Specification / Note
              const Text('Item Specification / Note', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.textPrimary)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descController,
                decoration: InputDecoration(
                  hintText: 'e.g. Includes mounting bracket, patch cord & 1yr warranty',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.primaryTeal, width: 1.5)),
                ),
              ),
              const SizedBox(height: 16),

              // Quantity, Unit Price, Discount
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Quantity *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.textPrimary)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _qtyController,
                          keyboardType: TextInputType.number,
                          validator: Validators.number,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.border)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.border)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.primaryTeal, width: 1.5)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Unit Price (AED) *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.textPrimary)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _priceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: Validators.number,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.border)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.border)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.primaryTeal, width: 1.5)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Discount %', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.textPrimary)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _discController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: Validators.number,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.border)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.border)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.primaryTeal, width: 1.5)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Live Line Calculation Summary Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.accentTealBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Qty: $qty × AED ${price.toStringAsFixed(2)}${disc > 0 ? " (Disc: -$disc%)" : ""}',
                            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (disc > 0)
                            Text(
                              'Savings: AED ${discAmount.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Line Total', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
                        Text(
                          'AED ${netTotal.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.primaryTealDark),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Actions
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
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: Text(
                      widget.initialItem != null ? 'Update Line Item' : 'Add Line Item',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
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

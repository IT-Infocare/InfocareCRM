import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/product_controller.dart';
import '../../models/product_bundle_model.dart';
import '../../models/product_model.dart';
import '../../utils/currency_utils.dart';
import '../../utils/permission_utils.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_search_bar.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/data_table_shell.dart';
import '../../widgets/loading_widget.dart';
import '../settings/forms/product_form.dart';
import 'forms/product_bundle_form.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final ProductController _controller = Get.put(ProductController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _controller.activeTabIndex.value = _tabController.index;
          _controller.searchQuery.value = '';
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthController.to.currentUser.value;
    final canSeeCost = PermissionUtils.canSeeProductCost(currentUser);
    final canEdit = PermissionUtils.canEditRecords(currentUser);

    return Scaffold(
      body: Row(
        children: [
          const AppSidebar(currentRoute: AppRoutes.products),
          Expanded(
            child: Column(
              children: [
                // Header with dynamic action button based on current tab
                Obx(() {
                  final isBundles = _controller.activeTabIndex.value == 1;
                  return AppHeader(
                    title: 'Products',
                    actions: [
                      if (canEdit && !isBundles)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryTeal,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => Get.dialog(const ProductFormDialog()),
                          icon: const Icon(Icons.add_shopping_cart, size: 18),
                          label: const Text('Add Product'),
                        ),
                      if (canEdit && isBundles)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryTeal,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => Get.dialog(const ProductBundleFormDialog()),
                          icon: const Icon(Icons.category, size: 18),
                          label: const Text('Add Bundle'),
                        ),
                    ],
                  );
                }),

                // Tab Bar
                Container(
                  color: AppTheme.surface,
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: false,
                    indicatorColor: AppTheme.primaryTeal,
                    labelColor: AppTheme.primaryTeal,
                    unselectedLabelColor: AppTheme.textSecondary,
                    tabs: const [
                      Tab(
                        icon: Icon(Icons.inventory_2_outlined, size: 18),
                        text: 'Products Catalog',
                      ),
                      Tab(
                        icon: Icon(Icons.category_outlined, size: 18),
                        text: 'Product Bundles',
                      ),
                    ],
                  ),
                ),

                // Main Tab Content
                Expanded(
                  child: Obx(() {
                    if (_controller.isLoading.value) {
                      return const LoadingWidget(message: 'Loading product inventory...');
                    }

                    return TabBarView(
                      controller: _tabController,
                      children: [
                        // Tab 1: Products Catalog
                        _buildProductsCatalogTab(canSeeCost, canEdit),

                        // Tab 2: Product Bundles
                        _buildProductBundlesTab(canEdit),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsCatalogTab(bool canSeeCost, bool canEdit) {
    final filtered = _controller.filteredProducts;
    final categories = _controller.categories;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter & Search bar row
          Row(
            children: [
              AppSearchBar(
                hintText: 'Search products by name, SKU...',
                onChanged: (val) => _controller.searchQuery.value = val,
              ),
              const SizedBox(width: 16),
              // Category filter dropdown
              Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _controller.selectedCategory.value,
                    icon: const Icon(Icons.filter_list, size: 16, color: AppTheme.textSecondary),
                    style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                    items: categories.map((cat) {
                      return DropdownMenuItem<String>(
                        value: cat,
                        child: Text(cat == 'All' ? 'All Categories' : cat),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        _controller.selectedCategory.value = val;
                      }
                    },
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${filtered.length} ${filtered.length == 1 ? 'Product' : 'Products'}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryTeal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Catalog Data Table
          Expanded(
            child: DataTableShell(
              emptyMessage: 'No catalog products match your search',
              columns: [
                const DataColumn(label: Text('PRODUCT NAME')),
                const DataColumn(label: Text('SKU')),
                const DataColumn(label: Text('CATEGORY')),
                const DataColumn(label: Text('UNIT PRICE')),
                if (canSeeCost) const DataColumn(label: Text('COST PRICE')),
                if (canEdit) const DataColumn(label: Text('ACTIONS')),
              ],
              rows: filtered.map((p) {
                return DataRow(
                  cells: [
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.inventory_2, size: 16, color: AppTheme.primaryTeal),
                          ),
                          const SizedBox(width: 12),
                          Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          p.sku,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          p.category ?? 'General',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryTeal,
                          ),
                        ),
                      ),
                    ),
                    DataCell(Text(CurrencyUtils.format(p.unitPrice), style: const TextStyle(fontWeight: FontWeight.w600))),
                    if (canSeeCost)
                      DataCell(Text(
                        CurrencyUtils.format(p.costPrice ?? 0),
                        style: const TextStyle(color: AppTheme.textSecondary),
                      )),
                    if (canEdit)
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.primaryTeal),
                              tooltip: 'Edit Product',
                              onPressed: () => Get.dialog(ProductFormDialog(product: p)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                              tooltip: 'Delete Product',
                              onPressed: () => _confirmDeleteProduct(p),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductBundlesTab(bool canEdit) {
    final filtered = _controller.filteredBundles;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter & Search bar row
          Row(
            children: [
              AppSearchBar(
                hintText: 'Search bundles by name, details...',
                onChanged: (val) => _controller.searchQuery.value = val,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${filtered.length} ${filtered.length == 1 ? 'Bundle' : 'Bundles'}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryTeal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Bundles Data Table
          Expanded(
            child: DataTableShell(
              emptyMessage: 'No product bundles match your search',
              columns: [
                const DataColumn(label: Text('BUNDLE NAME')),
                const DataColumn(label: Text('DESCRIPTION')),
                const DataColumn(label: Text('INCLUDED ITEMS')),
                const DataColumn(label: Text('PACKAGE PRICE')),
                if (canEdit) const DataColumn(label: Text('ACTIONS')),
              ],
              rows: filtered.map((b) {
                return DataRow(
                  cells: [
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.category, size: 16, color: AppTheme.primaryTeal),
                          ),
                          const SizedBox(width: 12),
                          Text(b.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    DataCell(
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 320),
                        child: Text(
                          b.description ?? '-',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        ),
                      ),
                    ),
                    DataCell(
                      _buildBundleItemsCell(b),
                    ),
                    DataCell(
                      Text(
                        CurrencyUtils.format(b.bundlePrice),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryTeal, fontSize: 13),
                      ),
                    ),
                    if (canEdit)
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.info_outline, size: 18, color: AppTheme.primaryTeal),
                              tooltip: 'View Package Details',
                              onPressed: () => _showBundleDetailsDialog(b),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                              tooltip: 'Delete Bundle',
                              onPressed: () => _confirmDeleteBundle(b),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBundleItemsCell(ProductBundleModel bundle) {
    if (bundle.items.isEmpty) {
      return const Text('-', style: TextStyle(color: AppTheme.textMuted));
    }

    final totalQty = bundle.items.fold(0, (sum, i) => sum + i.quantity);
    return InkWell(
      onTap: () => _showBundleDetailsDialog(bundle),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.list_alt, size: 14, color: AppTheme.primaryTeal),
            const SizedBox(width: 6),
            Text(
              '${bundle.items.length} products ($totalQty items)',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  void _showBundleDetailsDialog(ProductBundleModel bundle) {
    Get.dialog(
      Dialog(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      bundle.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => Get.back()),
                ],
              ),
              if (bundle.description != null && bundle.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(bundle.description!, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              ],
              const Divider(height: 24),
              const Text('Included Products & Components:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 12),
              if (bundle.items.isEmpty)
                const Text('No itemized products included.', style: TextStyle(color: AppTheme.textMuted))
              else
                ...bundle.items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.quantity}x ${item.product.name} (${item.product.sku})',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        Text(
                          CurrencyUtils.format(item.product.unitPrice * item.quantity),
                          style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  );
                }),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Bundle Package Price:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(
                    CurrencyUtils.format(bundle.bundlePrice),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryTeal),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteProduct(ProductModel product) {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirm Product Deletion'),
        content: Text('Are you sure you want to delete "${product.name}" (${product.sku}) from the catalog?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => _controller.deleteProduct(product.id),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteBundle(ProductBundleModel bundle) {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirm Bundle Deletion'),
        content: Text('Are you sure you want to remove the bundle "${bundle.name}"?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => _controller.deleteBundle(bundle.id),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

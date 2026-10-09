import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/quotation_controller.dart';
import '../../utils/currency_utils.dart';
import '../../utils/date_utils.dart';
import '../../utils/permission_utils.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/status_badge.dart';
import 'forms/quotation_line_form.dart';

class QuotationDetailScreen extends StatefulWidget {
  const QuotationDetailScreen({super.key});

  @override
  State<QuotationDetailScreen> createState() => _QuotationDetailScreenState();
}

class _QuotationDetailScreenState extends State<QuotationDetailScreen> {
  late final QuotationController _controller;

  @override
  void initState() {
    super.initState();
    final qId = Get.parameters['id'] ?? 'qt_101';
    _controller = Get.isRegistered<QuotationController>()
        ? Get.find<QuotationController>()
        : Get.put(QuotationController());
    _controller.selectQuotation(qId);
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final currentUser = AuthController.to.currentUser.value;
    final canApprove = PermissionUtils.canApproveQuotations(currentUser);

    return Scaffold(
      body: Row(
        children: [
          const AppSidebar(currentRoute: AppRoutes.quotes),
          Expanded(
            child: Column(
              children: [
                AppHeader(
                  title: 'Quotation / BOQ Builder',
                  actions: [
                    OutlinedButton.icon(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.arrow_back, size: 16),
                      label: const Text('Back to Quotes'),
                    ),
                  ],
                ),
                Expanded(
                  child: Obx(() {
                    if (_controller.isLoading.value || _controller.selectedQuotation.value == null) {
                      return const LoadingWidget(message: 'Loading quotation details...');
                    }

                    final quote = _controller.selectedQuotation.value!;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Summary Card
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          '${quote.quotationNumber} (v${quote.version})',
                                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                                        ),
                                        const SizedBox(width: 12),
                                        StatusBadge(status: quote.status),
                                        if (quote.isAiDraft) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: AppTheme.primaryTeal.withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: const Row(
                                              children: [
                                                Icon(Icons.auto_awesome, size: 12, color: AppTheme.primaryTeal),
                                                SizedBox(width: 4),
                                                Text('AI Drafted Lines', style: TextStyle(color: AppTheme.primaryTeal, fontSize: 11, fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        OutlinedButton.icon(
                                          onPressed: () {
                                            Get.snackbar('PDF Preview', 'Opening PDF Viewer for ${quote.quotationNumber}');
                                          },
                                          icon: const Icon(Icons.picture_as_pdf, size: 16),
                                          label: const Text('Preview PDF'),
                                        ),
                                        const SizedBox(width: 8),
                                        OutlinedButton.icon(
                                          onPressed: () => _controller.regenerateAiDraft(quote.id),
                                          icon: const Icon(Icons.auto_awesome, size: 16),
                                          label: const Text('Regenerate AI Draft'),
                                        ),
                                        const SizedBox(width: 8),
                                        if (quote.status == 'draft')
                                          ElevatedButton.icon(
                                            onPressed: () => controller.submitApproval(quote.id),
                                            icon: const Icon(Icons.send, size: 16),
                                            label: const Text('Submit for Approval'),
                                          ),
                                        if (quote.status == 'pending_approval' && canApprove) ...[
                                          ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success),
                                            onPressed: () => controller.approveQuotation(quote.id),
                                            icon: const Icon(Icons.check_circle, size: 16),
                                            label: const Text('Approve Quotation'),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    _buildInfoTile('Customer', quote.customerName),
                                    _buildInfoTile('Prepared By', quote.preparedBy),
                                    _buildInfoTile('Valid Until', AppDateUtils.formatDate(quote.validUntil)),
                                    _buildInfoTile('Payment Terms', quote.terms ?? 'Standard 50/50'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Line Items Table
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Bill of Quantities (BOQ) Items', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        Get.dialog(QuotationLineFormDialog(
                                          onAddLine: (newItem) {
                                            final updatedItems = [...quote.items, newItem];
                                            num sub = 0;
                                            for (var i in updatedItems) {
                                              sub += i.lineTotal;
                                            }
                                            num vat = sub * 0.05;
                                            num total = sub + vat;
                                            controller.selectedQuotation.value = quote.copyWith(
                                              items: updatedItems,
                                              subtotal: sub,
                                              vatAmount: vat,
                                              totalAmount: total,
                                            );
                                            Get.snackbar('Line Item Added', 'BOQ updated successfully');
                                          },
                                        ));
                                      },
                                      icon: const Icon(Icons.add, size: 16),
                                      label: const Text('Add Line Item'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Table(
                                  columnWidths: const {
                                    0: FixedColumnWidth(40),
                                    1: FlexColumnWidth(3),
                                    2: FlexColumnWidth(4),
                                    3: FixedColumnWidth(80),
                                    4: FixedColumnWidth(120),
                                    5: FixedColumnWidth(90),
                                    6: FixedColumnWidth(130),
                                  },
                                  border: TableBorder.all(color: AppTheme.border, width: 1),
                                  children: [
                                    TableRow(
                                      decoration: const BoxDecoration(color: AppTheme.background),
                                      children: [
                                        _buildCell('#', isHeader: true),
                                        _buildCell('ITEM / PRODUCT', isHeader: true),
                                        _buildCell('DESCRIPTION', isHeader: true),
                                        _buildCell('QTY', isHeader: true),
                                        _buildCell('UNIT PRICE', isHeader: true),
                                        _buildCell('DISC %', isHeader: true),
                                        _buildCell('LINE TOTAL', isHeader: true),
                                      ],
                                    ),
                                    ...quote.items.asMap().entries.map((entry) {
                                      final idx = entry.key + 1;
                                      final item = entry.value;
                                      return TableRow(
                                        children: [
                                          _buildCell('$idx'),
                                          _buildCell(item.productName, isBold: true),
                                          _buildCell(item.description ?? '-'),
                                          _buildCell('${item.quantity}'),
                                          _buildCell(CurrencyUtils.format(item.unitPrice)),
                                          _buildCell('${item.discount}%'),
                                          _buildCell(CurrencyUtils.format(item.lineTotal), isBold: true, color: AppTheme.primaryTeal),
                                        ],
                                      );
                                    }),
                                  ],
                                ),
                                const SizedBox(height: 24),

                                // Calculation Summary
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                    width: 320,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppTheme.background,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: AppTheme.border),
                                    ),
                                    child: Column(
                                      children: [
                                        _buildSummaryRow('Subtotal', CurrencyUtils.format(quote.subtotal)),
                                        const SizedBox(height: 8),
                                        _buildSummaryRow('VAT (5%)', CurrencyUtils.format(quote.vatAmount)),
                                        const Divider(height: 16),
                                        _buildSummaryRow(
                                          'Grand Total (AED)',
                                          CurrencyUtils.format(quote.totalAmount),
                                          isBold: true,
                                          fontSize: 16,
                                          color: AppTheme.primaryTeal,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildInfoTile(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildCell(String text, {bool isHeader = false, bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isHeader || isBold ? FontWeight.bold : FontWeight.normal,
          color: isHeader ? AppTheme.textSecondary : (color ?? AppTheme.textPrimary),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, double fontSize = 13, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: fontSize, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(
          value,
          style: TextStyle(fontSize: fontSize, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color),
        ),
      ],
    );
  }
}

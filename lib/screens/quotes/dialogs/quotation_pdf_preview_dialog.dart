import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/app_theme.dart';
import '../../../models/quotation_model.dart';
import '../../../utils/currency_utils.dart';
import '../../../utils/date_utils.dart';
import '../../../widgets/status_badge.dart';

class QuotationPdfPreviewDialog extends StatelessWidget {
  final QuotationModel quote;

  const QuotationPdfPreviewDialog({
    super.key,
    required this.quote,
  });

  void _openExternalPdf() async {
    if (quote.pdfUrl != null && quote.pdfUrl!.isNotEmpty) {
      final uri = Uri.parse(quote.pdfUrl!);
      try {
        await launchUrl(uri, webOnlyWindowName: '_blank');
      } catch (e) {
        Get.snackbar('Open PDF', 'Could not open external PDF link: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: 900,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Modal Toolbar Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.danger.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.picture_as_pdf, color: AppTheme.danger, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${quote.quotationNumber} (v${quote.version}) - PDF Preview',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Commercial Quotation & Bill of Quantities Document',
                          style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  ),
                  if (quote.pdfUrl != null && quote.pdfUrl!.isNotEmpty) ...[
                    OutlinedButton.icon(
                      onPressed: _openExternalPdf,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFF475569)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                      icon: const Icon(Icons.open_in_new, size: 15),
                      label: const Text('Open External PDF', style: TextStyle(fontSize: 13)),
                    ),
                    const SizedBox(width: 12),
                  ],
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                    tooltip: 'Close Preview',
                  ),
                ],
              ),
            ),

            // Scrollable Document Container (styled as an A4 Paper)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Container(
                    width: 820,
                    padding: const EdgeInsets.all(36),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Company Header & Document Meta
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Company Info
                            Expanded(
                              flex: 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF0F766E),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          'INFOCARE',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 14,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Flexible(
                                        child: Text(
                                          'SYSTEMS LLC',
                                          style: TextStyle(
                                            color: Color(0xFF0F172A),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Enterprise ICT, Security & Infrastructure Solutions',
                                    style: TextStyle(fontSize: 12, color: Color(0xFF475569)),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'P.O. Box 23412, Dubai, United Arab Emirates',
                                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                  ),
                                  const Text(
                                    'TRN / VAT: 100234857200003 · sales@infocare.ae',
                                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Quotation Title & Meta
                            Expanded(
                              flex: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    'COMMERCIAL QUOTATION',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF0F172A),
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${quote.quotationNumber} (v${quote.version})',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F766E),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  StatusBadge(status: quote.status),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                        const Divider(color: Color(0xFFE2E8F0), thickness: 1.5),
                        const SizedBox(height: 16),

                        // Two Columns: Customer & Quote Details
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Customer Section
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'QUOTATION PREPARED FOR:',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF64748B),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      quote.customerName,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Corporate Client',
                                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Dates & Preparer Details Section
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Column(
                                  children: [
                                    _buildMetaRow('Date of Issue:', AppDateUtils.formatDate(quote.createdAt)),
                                    const SizedBox(height: 6),
                                    _buildMetaRow('Valid Until:', AppDateUtils.formatDate(quote.validUntil)),
                                    const SizedBox(height: 6),
                                    _buildMetaRow('Prepared By:', quote.preparedBy),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Section Title
                        const Text(
                          'BILL OF QUANTITIES (BOQ)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF334155),
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Items Table
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Column(
                            children: [
                              // Table Header
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
                                ),
                                child: const Row(
                                  children: [
                                    SizedBox(width: 32, child: Text('#', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF475569)))),
                                    Expanded(flex: 5, child: Text('ITEM / PRODUCT & SPECIFICATION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF475569)))),
                                    SizedBox(width: 50, child: Text('QTY', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF475569)))),
                                    SizedBox(width: 100, child: Text('UNIT PRICE', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF475569)))),
                                    SizedBox(width: 60, child: Text('DISC %', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF475569)))),
                                    SizedBox(width: 110, child: Text('TOTAL (AED)', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF475569)))),
                                  ],
                                ),
                              ),

                              // Table Rows
                              if (quote.items.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.all(24),
                                  child: Center(
                                    child: Text(
                                      'No BOQ items added to this quotation.',
                                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                                    ),
                                  ),
                                )
                              else
                                ...List.generate(quote.items.length, (index) {
                                  final item = quote.items[index];
                                  final isEven = index % 2 == 0;
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isEven ? Colors.white : const Color(0xFFFAFAFA),
                                      border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 32,
                                          child: Text(
                                            '${index + 1}',
                                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 5,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.productName,
                                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                              ),
                                              if (item.description != null && item.description!.isNotEmpty) ...[
                                                const SizedBox(height: 2),
                                                Text(
                                                  item.description!,
                                                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          width: 50,
                                          child: Text(
                                            '${item.quantity}',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(fontSize: 12, color: Color(0xFF0F172A)),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 100,
                                          child: Text(
                                            CurrencyUtils.format(item.unitPrice),
                                            textAlign: TextAlign.right,
                                            style: const TextStyle(fontSize: 12, color: Color(0xFF0F172A)),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 60,
                                          child: Text(
                                            '${item.discount}%',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 110,
                                          child: Text(
                                            CurrencyUtils.format(item.lineTotal),
                                            textAlign: TextAlign.right,
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F766E)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Financial Summary Section (Right Aligned)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              constraints: const BoxConstraints(minWidth: 280, maxWidth: 360),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFCBD5E1)),
                              ),
                              child: Column(
                                children: [
                                  _buildSummaryLine('Subtotal:', CurrencyUtils.format(quote.subtotal)),
                                  const SizedBox(height: 6),
                                  _buildSummaryLine('VAT (5%):', CurrencyUtils.format(quote.vatAmount)),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: Divider(color: Color(0xFFCBD5E1)),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Flexible(
                                        child: Text(
                                          'Grand Total:',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        CurrencyUtils.format(quote.totalAmount),
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF0F766E),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),
                        const Divider(color: Color(0xFFE2E8F0)),
                        const SizedBox(height: 12),

                        // Payment Terms & Conditions
                        const Text(
                          'COMMERCIAL TERMS & NOTES',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF334155),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• Payment Terms: ${quote.terms ?? '50% advance with Purchase Order, 50% upon delivery & installation completion.'}',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF475569), height: 1.5),
                        ),
                        Text(
                          '• Quotation Validity: Valid until ${AppDateUtils.formatDate(quote.validUntil)}.',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF475569), height: 1.5),
                        ),
                        const Text(
                          '• Warranty: 12 months comprehensive hardware warranty from date of commissioning.',
                          style: TextStyle(fontSize: 11, color: Color(0xFF475569), height: 1.5),
                        ),

                        const SizedBox(height: 36),

                        // Signature and Acceptance Blocks
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Infocare Signatory
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'For Infocare Systems LLC',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                ),
                                const SizedBox(height: 36),
                                Container(
                                  width: 200,
                                  height: 1,
                                  color: const Color(0xFF94A3B8),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Authorized Signatory & Stamp',
                                  style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),

                            // Customer Acceptance Signatory
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'Customer Acceptance',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                ),
                                const SizedBox(height: 36),
                                Container(
                                  width: 200,
                                  height: 1,
                                  color: const Color(0xFF94A3B8),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Signature & Official Company Seal',
                                  style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
      ],
    );
  }

  Widget _buildSummaryLine(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
        ),
        const SizedBox(width: 8),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
      ],
    );
  }
}

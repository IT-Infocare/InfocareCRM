import 'quotation_item_model.dart';

class QuotationModel {
  final String id;
  final String quotationNumber;
  final int version;
  final String status;
  final DateTime validUntil;
  final String customerId;
  final String customerName;
  final String? leadId;
  final String? dealId;
  final String preparedBy;
  final String? terms;
  final num subtotal;
  final num vatAmount;
  final num totalAmount;
  final String? pdfUrl;
  final bool isAiDraft;
  final List<QuotationItemModel> items;
  final DateTime createdAt;

  QuotationModel({
    required this.id,
    required this.quotationNumber,
    this.version = 1,
    required this.status,
    required this.validUntil,
    required this.customerId,
    required this.customerName,
    this.leadId,
    this.dealId,
    required this.preparedBy,
    this.terms,
    required this.subtotal,
    required this.vatAmount,
    required this.totalAmount,
    this.pdfUrl,
    this.isAiDraft = false,
    required this.items,
    required this.createdAt,
  });

  factory QuotationModel.fromJson(Map<String, dynamic> json) {
    return QuotationModel(
      id: json['id'] as String? ?? '',
      quotationNumber: json['quotation_number'] as String? ?? '',
      version: (json['version'] as int?) ?? 1,
      status: json['status'] as String? ?? 'draft',
      validUntil: json['valid_until'] != null
          ? DateTime.tryParse(json['valid_until'].toString()) ?? DateTime.now().add(const Duration(days: 14))
          : DateTime.now().add(const Duration(days: 14)),
      customerId: json['customer_id'] as String? ?? '',
      customerName: json['customer_name'] as String? ?? '',
      leadId: json['lead_id'] as String?,
      dealId: json['deal_id'] as String?,
      preparedBy: json['prepared_by'] as String? ?? '',
      terms: json['terms'] as String?,
      subtotal: (json['subtotal'] as num?) ?? 0,
      vatAmount: (json['vat_amount'] as num?) ?? 0,
      totalAmount: (json['total_amount'] as num?) ?? 0,
      pdfUrl: json['pdf_url'] as String?,
      isAiDraft: json['is_ai_draft'] as bool? ?? false,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => QuotationItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quotation_number': quotationNumber,
      'version': version,
      'status': status,
      'valid_until': validUntil.toIso8601String(),
      'customer_id': customerId,
      'customer_name': customerName,
      'lead_id': leadId,
      'deal_id': dealId,
      'prepared_by': preparedBy,
      'terms': terms,
      'subtotal': subtotal,
      'vat_amount': vatAmount,
      'total_amount': totalAmount,
      'pdf_url': pdfUrl,
      'is_ai_draft': isAiDraft,
      'items': items.map((e) => e.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  QuotationModel copyWith({
    String? status,
    List<QuotationItemModel>? items,
    num? subtotal,
    num? vatAmount,
    num? totalAmount,
    String? pdfUrl,
    bool? isAiDraft,
  }) {
    return QuotationModel(
      id: id,
      quotationNumber: quotationNumber,
      version: version,
      status: status ?? this.status,
      validUntil: validUntil,
      customerId: customerId,
      customerName: customerName,
      leadId: leadId,
      dealId: dealId,
      preparedBy: preparedBy,
      terms: terms,
      subtotal: subtotal ?? this.subtotal,
      vatAmount: vatAmount ?? this.vatAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      isAiDraft: isAiDraft ?? this.isAiDraft,
      items: items ?? this.items,
      createdAt: createdAt,
    );
  }
}

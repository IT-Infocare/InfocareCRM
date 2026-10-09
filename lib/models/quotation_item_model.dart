class QuotationItemModel {
  final String id;
  final String productId;
  final String productName;
  final String? description;
  final int quantity;
  final num unitPrice;
  final num discount;
  final num lineTotal;
  final int sortOrder;

  QuotationItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    this.description,
    required this.quantity,
    required this.unitPrice,
    this.discount = 0,
    required this.lineTotal,
    this.sortOrder = 0,
  });

  factory QuotationItemModel.fromJson(Map<String, dynamic> json) {
    return QuotationItemModel(
      id: json['id'] as String? ?? '',
      productId: json['product_id'] as String? ?? '',
      productName: json['product_name'] as String? ?? '',
      description: json['description'] as String?,
      quantity: (json['quantity'] as int?) ?? 1,
      unitPrice: (json['unit_price'] as num?) ?? 0,
      discount: (json['discount'] as num?) ?? 0,
      lineTotal: (json['line_total'] as num?) ?? 0,
      sortOrder: (json['sort_order'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'description': description,
      'quantity': quantity,
      'unit_price': unitPrice,
      'discount': discount,
      'line_total': lineTotal,
      'sort_order': sortOrder,
    };
  }
}

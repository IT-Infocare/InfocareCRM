class ProductModel {
  final String id;
  final String name;
  final String sku;
  final String? category;
  final String? description;
  final num unitPrice;
  final num? costPrice; // Backend owned / admin viewable
  final bool isActive;

  ProductModel({
    required this.id,
    required this.name,
    required this.sku,
    this.category,
    this.description,
    required this.unitPrice,
    this.costPrice,
    this.isActive = true,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      sku: json['sku'] as String? ?? '',
      category: json['category'] as String?,
      description: json['description'] as String?,
      unitPrice: (json['unit_price'] as num?) ?? 0,
      costPrice: json['cost_price'] as num?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'category': category,
      'description': description,
      'unit_price': unitPrice,
      'cost_price': costPrice,
      'is_active': isActive,
    };
  }
}

import 'product_model.dart';

class ProductBundleItem {
  final ProductModel product;
  final int quantity;

  ProductBundleItem({
    required this.product,
    required this.quantity,
  });

  factory ProductBundleItem.fromJson(Map<String, dynamic> json) {
    return ProductBundleItem(
      product: ProductModel.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
    };
  }
}

class ProductBundleModel {
  final String id;
  final String name;
  final String? description;
  final List<ProductBundleItem> items;
  final num bundlePrice;

  ProductBundleModel({
    required this.id,
    required this.name,
    this.description,
    required this.items,
    required this.bundlePrice,
  });

  factory ProductBundleModel.fromJson(Map<String, dynamic> json) {
    return ProductBundleModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => ProductBundleItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      bundlePrice: (json['bundle_price'] as num?) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'items': items.map((e) => e.toJson()).toList(),
      'bundle_price': bundlePrice,
    };
  }
}

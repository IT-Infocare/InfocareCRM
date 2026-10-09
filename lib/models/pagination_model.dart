class PaginationModel {
  final int page;
  final int limit;
  final int totalItems;
  final int totalPages;

  PaginationModel({
    required this.page,
    required this.limit,
    required this.totalItems,
    required this.totalPages,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 10,
      totalItems: json['total_items'] as int? ?? json['totalItems'] as int? ?? 0,
      totalPages: json['total_pages'] as int? ?? json['totalPages'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      'total_items': totalItems,
      'total_pages': totalPages,
    };
  }
}

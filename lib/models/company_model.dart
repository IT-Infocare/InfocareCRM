class CompanyModel {
  final String id;
  final String name;
  final String? industry;
  final String? website;
  final String? emirate;
  final String? address;

  CompanyModel({
    required this.id,
    required this.name,
    this.industry,
    this.website,
    this.emirate,
    this.address,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      industry: json['industry'] as String?,
      website: json['website'] as String?,
      emirate: json['emirate'] as String?,
      address: json['address'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'industry': industry,
      'website': website,
      'emirate': emirate,
      'address': address,
    };
  }
}

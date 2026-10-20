class CompanyModel {
  final String id;
  final String name;
  final String code;
  final String? tradeLicenceNo;
  final String? industry;
  final String country;
  final String? emirate;
  final String? city;
  final String? address;
  final String? website;
  final String? phone;
  final String? email;
  final String? logoUrl;
  final String? taxNumber;
  final String? notes;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int branchCount;

  CompanyModel({
    required this.id,
    required this.name,
    this.code = '',
    this.tradeLicenceNo,
    this.industry,
    this.country = 'UAE',
    this.emirate,
    this.city,
    this.address,
    this.website,
    this.phone,
    this.email,
    this.logoUrl,
    this.taxNumber,
    this.notes,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.branchCount = 0,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      tradeLicenceNo: json['trade_licence_no'] as String? ?? json['tradeLicenceNo'] as String?,
      industry: json['industry'] as String?,
      country: json['country'] as String? ?? 'UAE',
      emirate: json['emirate'] as String?,
      city: json['city'] as String?,
      address: json['address'] as String?,
      website: json['website'] as String? ?? json['website_url'] as String?,
      phone: json['phone'] as String? ?? json['telephone'] as String?,
      email: json['email'] as String? ?? json['email_address'] as String?,
      logoUrl: json['logo_url'] as String? ?? json['logo'] as String? ?? json['logoUrl'] as String?,
      taxNumber: json['tax_number'] as String? ?? json['vat_number'] as String? ?? json['trn'] as String?,
      notes: json['notes'] as String?,
      isActive: json['is_active'] as bool? ?? json['isActive'] as bool? ?? true,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
      branchCount: (json['branch_count'] ?? json['branchCount'] ?? (json['branches'] is List ? (json['branches'] as List).length : 0)) as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'trade_licence_no': tradeLicenceNo,
      'industry': industry,
      'country': country,
      'emirate': emirate,
      'city': city,
      'address': address,
      'website': website,
      'phone': phone,
      'email': email,
      'logo_url': logoUrl,
      'tax_number': taxNumber,
      'notes': notes,
      'is_active': isActive,
      'branch_count': branchCount,
    };
  }

  CompanyModel copyWith({
    String? id,
    String? name,
    String? code,
    String? tradeLicenceNo,
    String? industry,
    String? country,
    String? emirate,
    String? city,
    String? address,
    String? website,
    String? phone,
    String? email,
    String? logoUrl,
    String? taxNumber,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? branchCount,
  }) {
    return CompanyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      tradeLicenceNo: tradeLicenceNo ?? this.tradeLicenceNo,
      industry: industry ?? this.industry,
      country: country ?? this.country,
      emirate: emirate ?? this.emirate,
      city: city ?? this.city,
      address: address ?? this.address,
      website: website ?? this.website,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      logoUrl: logoUrl ?? this.logoUrl,
      taxNumber: taxNumber ?? this.taxNumber,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      branchCount: branchCount ?? this.branchCount,
    );
  }
}

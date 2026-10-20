class BranchModel {
  final String id;
  final String companyId;
  final String companyName;
  final String name;
  final String shortName;
  final String code;
  final String logoUrl;
  final String manager;
  final String country;
  final String city;
  final String currency;
  final double vatPercent;
  final String website;
  final String poBox;
  final String timezone;
  final String phone;
  final String mobile;
  final String email;
  final String location;
  final String trNumber;
  final String address;
  final bool isActive;

  BranchModel({
    required this.id,
    this.companyId = '',
    this.companyName = '',
    required this.name,
    this.shortName = '',
    required this.code,
    this.logoUrl = '',
    this.manager = '',
    this.country = 'UAE',
    this.city = 'Dubai',
    this.currency = 'AED',
    this.vatPercent = 5.0,
    this.website = '',
    this.poBox = '',
    this.timezone = 'Asia/Dubai',
    this.phone = '',
    this.mobile = '',
    this.email = '',
    this.location = '',
    this.trNumber = '',
    this.address = '',
    this.isActive = true,
  });

  String get displayShortName {
    if (shortName.trim().isNotEmpty) return shortName.trim();
    return BranchModel.deriveShortName(name: name, code: code, city: city);
  }

  static String deriveShortName({String? name, String? code, String? city}) {
    final c = (code ?? '').trim().toUpperCase();
    final n = (name ?? '').trim();
    final nLower = n.toLowerCase();

    if (c == 'DXB' || nLower.contains('dubai')) return 'Dubai';
    if (c == 'RAK' || nLower.contains('rak') || nLower.contains('ras al khaimah')) return 'RAK';
    if (c == 'KER' || nLower.contains('kerala') || nLower.contains('kochi')) return 'Kerala';
    if (c == 'SHJ' || c == 'FZC' || nLower.contains('sharjah')) return 'Sharjah';
    if (c == 'IRQ' || nLower.contains('iraq') || nLower.contains('baghdad')) return 'Iraq';
    if (c == 'AUH' || nLower.contains('abu dhabi')) return 'Abu Dhabi';

    if (n.contains('—')) {
      final parts = n.split('—');
      if (parts.length > 1 && parts.last.trim().isNotEmpty) {
        return parts.last.trim();
      }
    }
    if (n.contains('–')) {
      final parts = n.split('–');
      if (parts.length > 1 && parts.last.trim().isNotEmpty) {
        return parts.last.trim();
      }
    }
    if (n.contains(' - ')) {
      final parts = n.split(' - ');
      if (parts.length > 1 && parts.last.trim().isNotEmpty) {
        return parts.last.trim();
      }
    }

    if (city != null && city.trim().isNotEmpty) return city.trim();
    if (c.isNotEmpty) return c;
    return n;
  }

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    num rawVat = (json['vat_percent'] ?? json['vat_rate'] ?? json['tax_percent'] ?? json['vatPercent'] ?? 5.0) as num? ?? 5.0;

    final explicitShortName = json['short_name'] as String? ?? json['shortName'] as String?;
    final sName = (explicitShortName != null && explicitShortName.trim().isNotEmpty)
        ? explicitShortName.trim()
        : BranchModel.deriveShortName(
            name: json['name'] as String?,
            code: json['code'] as String?,
            city: json['city'] as String?,
          );

    return BranchModel(
      id: json['id'] as String? ?? '',
      companyId: json['company_id'] as String? ?? json['companyId'] as String? ?? '',
      companyName: json['company_name'] as String? ?? json['companyName'] as String? ?? (json['company'] is Map ? (json['company']['name'] as String? ?? '') : ''),
      name: json['name'] as String? ?? '',
      shortName: sName,
      code: json['code'] as String? ?? '',
      logoUrl: json['logo_url'] as String? ?? json['logo'] as String? ?? json['logoUrl'] as String? ?? '',
      manager: json['manager'] as String? ?? json['branch_manager'] as String? ?? json['contact_person'] as String? ?? '',
      country: json['country'] as String? ?? (json['code'] == 'KER' ? 'India' : (json['code'] == 'IRQ' ? 'Iraq' : 'UAE')),
      city: json['city'] as String? ?? (json['code'] == 'KER' ? 'Kochi' : (json['code'] == 'RAK' ? 'Ras Al Khaimah' : ((json['code'] == 'SHJ' || json['code'] == 'FZC') ? 'Sharjah' : (json['code'] == 'IRQ' ? 'Baghdad' : 'Dubai')))),
      currency: json['currency'] as String? ?? (json['code'] == 'KER' ? 'INR' : (json['code'] == 'IRQ' ? 'USD' : 'AED')),
      vatPercent: rawVat.toDouble(),
      website: json['website'] as String? ?? json['website_url'] as String? ?? '',
      poBox: json['po_box'] as String? ?? json['postal_code'] as String? ?? json['poBox'] as String? ?? '',
      timezone: json['timezone'] as String? ?? json['time_zone'] as String? ?? (json['code'] == 'KER' ? 'Asia/Kolkata' : (json['code'] == 'IRQ' ? 'Asia/Baghdad' : 'Asia/Dubai')),
      phone: json['phone'] as String? ?? json['telephone'] as String? ?? '',
      mobile: json['mobile'] as String? ?? json['mobile_number'] as String? ?? '',
      email: json['email'] as String? ?? json['email_address'] as String? ?? '',
      location: json['location'] as String? ?? '',
      trNumber: json['tr_number'] as String? ?? json['trn'] as String? ?? json['trNumber'] as String? ?? '',
      address: json['address'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'company_name': companyName,
      'name': name,
      'short_name': shortName,
      'shortName': shortName,
      'code': code,
      'logo_url': logoUrl,
      'manager': manager,
      'country': country,
      'city': city,
      'currency': currency,
      'vat_percent': vatPercent,
      'website': website,
      'po_box': poBox,
      'timezone': timezone,
      'phone': phone,
      'mobile': mobile,
      'email': email,
      'location': location,
      'tr_number': trNumber,
      'address': address,
      'is_active': isActive,
    };
  }

  BranchModel copyWith({
    String? id,
    String? companyId,
    String? companyName,
    String? name,
    String? shortName,
    String? code,
    String? logoUrl,
    String? manager,
    String? country,
    String? city,
    String? currency,
    double? vatPercent,
    String? website,
    String? poBox,
    String? timezone,
    String? phone,
    String? mobile,
    String? email,
    String? location,
    String? trNumber,
    String? address,
    bool? isActive,
  }) {
    return BranchModel(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      companyName: companyName ?? this.companyName,
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      code: code ?? this.code,
      logoUrl: logoUrl ?? this.logoUrl,
      manager: manager ?? this.manager,
      country: country ?? this.country,
      city: city ?? this.city,
      currency: currency ?? this.currency,
      vatPercent: vatPercent ?? this.vatPercent,
      website: website ?? this.website,
      poBox: poBox ?? this.poBox,
      timezone: timezone ?? this.timezone,
      phone: phone ?? this.phone,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      location: location ?? this.location,
      trNumber: trNumber ?? this.trNumber,
      address: address ?? this.address,
      isActive: isActive ?? this.isActive,
    );
  }
}

class BranchModel {
  final String id;
  final String name;
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
    required this.name,
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

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    num rawVat = (json['vat_percent'] ?? json['vat_rate'] ?? json['tax_percent'] ?? json['vatPercent'] ?? 5.0) as num? ?? 5.0;

    return BranchModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      logoUrl: json['logo_url'] as String? ?? json['logo'] as String? ?? json['logoUrl'] as String? ?? '',
      manager: json['manager'] as String? ?? json['branch_manager'] as String? ?? json['contact_person'] as String? ?? '',
      country: json['country'] as String? ?? (json['code'] == 'KER' ? 'India' : 'UAE'),
      city: json['city'] as String? ?? (json['code'] == 'KER' ? 'Kochi' : (json['code'] == 'RAK' ? 'Ras Al Khaimah' : 'Dubai')),
      currency: json['currency'] as String? ?? (json['code'] == 'KER' ? 'INR' : 'AED'),
      vatPercent: rawVat.toDouble(),
      website: json['website'] as String? ?? json['website_url'] as String? ?? '',
      poBox: json['po_box'] as String? ?? json['postal_code'] as String? ?? json['poBox'] as String? ?? '',
      timezone: json['timezone'] as String? ?? json['time_zone'] as String? ?? (json['code'] == 'KER' ? 'Asia/Kolkata' : 'Asia/Dubai'),
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
      'name': name,
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
}

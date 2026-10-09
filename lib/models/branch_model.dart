class BranchModel {
  final String id;
  final String name;
  final String code;
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
    return BranchModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      timezone: json['timezone'] as String? ?? json['time_zone'] as String? ?? 'Asia/Dubai',
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

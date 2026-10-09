class CustomerModel {
  final String id;
  final String name;
  final String? companyName;
  final String email;
  final String phone;
  final String? whatsappNumber;
  final String branch;
  final String? emirate;
  final String? address;
  final num totalRevenue;
  final int totalDeals;
  final DateTime? createdAt;

  CustomerModel({
    required this.id,
    required this.name,
    this.companyName,
    required this.email,
    required this.phone,
    this.whatsappNumber,
    required this.branch,
    this.emirate,
    this.address,
    this.totalRevenue = 0,
    this.totalDeals = 0,
    this.createdAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    num parseNum(dynamic val) {
      if (val == null) return 0;
      if (val is num) return val;
      if (val is String) return num.tryParse(val) ?? 0;
      return 0;
    }
    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? (double.tryParse(val)?.toInt() ?? 0);
      return 0;
    }

    return CustomerModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      companyName: json['company_name']?.toString(),
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      whatsappNumber: json['whatsapp_number']?.toString(),
      branch: json['branch']?.toString() ?? 'Dubai',
      emirate: json['emirate']?.toString(),
      address: json['address']?.toString(),
      totalRevenue: parseNum(json['total_revenue']),
      totalDeals: parseInt(json['total_deals']),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'company_name': companyName,
      'email': email,
      'phone': phone,
      'whatsapp_number': whatsappNumber,
      'branch': branch,
      'emirate': emirate,
      'address': address,
      'total_revenue': totalRevenue,
      'total_deals': totalDeals,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

class ContactModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? whatsappNumber;
  final String? designation;
  final String? companyId;
  final String? companyName;

  ContactModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.whatsappNumber,
    this.designation,
    this.companyId,
    this.companyName,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      whatsappNumber: json['whatsapp_number'] as String?,
      designation: json['designation'] as String?,
      companyId: json['company_id'] as String?,
      companyName: json['company_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'whatsapp_number': whatsappNumber,
      'designation': designation,
      'company_id': companyId,
      'company_name': companyName,
    };
  }
}

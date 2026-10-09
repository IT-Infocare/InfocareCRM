class LeadModel {
  final String id;
  final String? customerId;
  final String contactName;
  final String? companyName;
  final String phone;
  final String email;
  final String? whatsappNumber;
  final String? location;
  final String requirement;
  final String source;
  final String? sourceDetail;
  final String? campaign;
  final String? capturedBy;
  final String? ownerId;
  final String? ownerName;
  final String? branchId;
  final String branch;
  final num estimatedValue;
  final String? productInterest;
  final String status;
  final String stage;
  final String? aiSummary;
  final String? aiCategory;
  final String? aiUrgency;
  final String? aiNextStep;
  final String? aiDraftReply;
  final bool isDuplicate;
  final String? duplicateWarning;
  final DateTime createdAt;
  final DateTime? updatedAt;

  LeadModel({
    required this.id,
    this.customerId,
    required this.contactName,
    this.companyName,
    required this.phone,
    required this.email,
    this.whatsappNumber,
    this.location,
    required this.requirement,
    required this.source,
    this.sourceDetail,
    this.campaign,
    this.capturedBy,
    this.ownerId,
    this.ownerName,
    this.branchId,
    required this.branch,
    this.estimatedValue = 0,
    this.productInterest,
    required this.status,
    required this.stage,
    this.aiSummary,
    this.aiCategory,
    this.aiUrgency,
    this.aiNextStep,
    this.aiDraftReply,
    this.isDuplicate = false,
    this.duplicateWarning,
    required this.createdAt,
    this.updatedAt,
  });

  factory LeadModel.fromJson(Map<String, dynamic> json) {
    num parseNum(dynamic val) {
      if (val == null) return 0;
      if (val is num) return val;
      if (val is String) return num.tryParse(val) ?? 0;
      return 0;
    }

    return LeadModel(
      id: json['id']?.toString() ?? '',
      customerId: json['customer_id']?.toString(),
      contactName: json['contact_name']?.toString() ?? json['name']?.toString() ?? '',
      companyName: json['company_name']?.toString(),
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      whatsappNumber: json['whatsapp_number']?.toString(),
      location: json['location']?.toString() ?? json['emirate']?.toString(),
      requirement: json['requirement']?.toString() ?? '',
      source: json['source']?.toString() ?? 'website',
      sourceDetail: json['source_detail']?.toString(),
      campaign: json['campaign']?.toString(),
      capturedBy: json['captured_by']?.toString(),
      ownerId: json['owner_id']?.toString(),
      ownerName: json['owner_name']?.toString(),
      branchId: json['branch_id']?.toString(),
      branch: json['branch']?.toString() ?? 'Dubai',
      estimatedValue: parseNum(json['estimated_value']),
      productInterest: json['product_interest']?.toString(),
      status: json['status']?.toString() ?? 'new',
      stage: json['stage']?.toString() ?? 'new',
      aiSummary: json['ai_summary']?.toString(),
      aiCategory: json['ai_category']?.toString(),
      aiUrgency: json['ai_urgency']?.toString(),
      aiNextStep: json['ai_next_step']?.toString(),
      aiDraftReply: json['ai_draft_reply']?.toString(),
      isDuplicate: json['is_duplicate'] == true || json['is_duplicate']?.toString().toLowerCase() == 'true',
      duplicateWarning: json['duplicate_warning']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'contact_name': contactName,
      'company_name': companyName,
      'phone': phone,
      'email': email,
      'whatsapp_number': whatsappNumber,
      'location': location,
      'requirement': requirement,
      'source': source,
      'source_detail': sourceDetail,
      'campaign': campaign,
      'captured_by': capturedBy,
      'owner_id': ownerId,
      'owner_name': ownerName,
      'branch_id': branchId,
      'branch': branch,
      'estimated_value': estimatedValue,
      'product_interest': productInterest,
      'status': status,
      'stage': stage,
      'ai_summary': aiSummary,
      'ai_category': aiCategory,
      'ai_urgency': aiUrgency,
      'ai_next_step': aiNextStep,
      'ai_draft_reply': aiDraftReply,
      'is_duplicate': isDuplicate,
      'duplicate_warning': duplicateWarning,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  LeadModel copyWith({
    String? customerId,
    String? status,
    String? stage,
    String? ownerId,
    String? ownerName,
    String? aiDraftReply,
  }) {
    return LeadModel(
      id: id,
      customerId: customerId ?? this.customerId,
      contactName: contactName,
      companyName: companyName,
      phone: phone,
      email: email,
      whatsappNumber: whatsappNumber,
      location: location,
      requirement: requirement,
      source: source,
      sourceDetail: sourceDetail,
      campaign: campaign,
      capturedBy: capturedBy,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      branch: branch,
      estimatedValue: estimatedValue,
      productInterest: productInterest,
      status: status ?? this.status,
      stage: stage ?? this.stage,
      aiSummary: aiSummary,
      aiCategory: aiCategory,
      aiUrgency: aiUrgency,
      aiNextStep: aiNextStep,
      aiDraftReply: aiDraftReply ?? this.aiDraftReply,
      isDuplicate: isDuplicate,
      duplicateWarning: duplicateWarning,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

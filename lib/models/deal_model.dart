class DealModel {
  final String id;
  final String? leadId;
  final String customerName;
  final String? companyName;
  final String requirement;
  final num estimatedValue;
  final String ownerName;
  final String source;
  final String stage;
  final int daysInStage;
  final bool isStalled;
  final String? lostReason;
  final String branch;
  final DateTime createdAt;

  DealModel({
    required this.id,
    this.leadId,
    required this.customerName,
    this.companyName,
    required this.requirement,
    required this.estimatedValue,
    required this.ownerName,
    required this.source,
    required this.stage,
    required this.daysInStage,
    this.isStalled = false,
    this.lostReason,
    required this.branch,
    required this.createdAt,
  });

  factory DealModel.fromJson(Map<String, dynamic> json) {
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

    return DealModel(
      id: json['id']?.toString() ?? '',
      leadId: json['lead_id']?.toString(),
      customerName: json['customer_name']?.toString() ?? json['name']?.toString() ?? '',
      companyName: json['company_name']?.toString(),
      requirement: json['requirement']?.toString() ?? '',
      estimatedValue: parseNum(json['estimated_value'] ?? json['value']),
      ownerName: json['owner_name']?.toString() ?? '',
      source: json['source']?.toString() ?? 'website',
      stage: json['stage']?.toString() ?? 'new',
      daysInStage: parseInt(json['days_in_stage']),
      isStalled: json['is_stalled'] == true || json['is_stalled']?.toString().toLowerCase() == 'true',
      lostReason: json['lost_reason']?.toString(),
      branch: json['branch']?.toString() ?? 'Dubai',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lead_id': leadId,
      'customer_name': customerName,
      'company_name': companyName,
      'requirement': requirement,
      'estimated_value': estimatedValue,
      'owner_name': ownerName,
      'source': source,
      'stage': stage,
      'days_in_stage': daysInStage,
      'is_stalled': isStalled,
      'lost_reason': lostReason,
      'branch': branch,
      'created_at': createdAt.toIso8601String(),
    };
  }

  DealModel copyWith({
    String? stage,
    String? lostReason,
    int? daysInStage,
    bool? isStalled,
  }) {
    return DealModel(
      id: id,
      leadId: leadId,
      customerName: customerName,
      companyName: companyName,
      requirement: requirement,
      estimatedValue: estimatedValue,
      ownerName: ownerName,
      source: source,
      stage: stage ?? this.stage,
      daysInStage: daysInStage ?? this.daysInStage,
      isStalled: isStalled ?? this.isStalled,
      lostReason: lostReason ?? this.lostReason,
      branch: branch,
      createdAt: createdAt,
    );
  }
}

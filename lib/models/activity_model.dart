class ActivityModel {
  final String id;
  final String? leadId;
  final String? dealId;
  final String type;
  final String description;
  final String createdBy;
  final DateTime createdAt;

  ActivityModel({
    required this.id,
    this.leadId,
    this.dealId,
    required this.type,
    required this.description,
    required this.createdBy,
    required this.createdAt,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] as String? ?? '',
      leadId: json['lead_id'] as String?,
      dealId: json['deal_id'] as String?,
      type: json['type'] as String? ?? 'note',
      description: json['description'] as String? ?? '',
      createdBy: json['created_by'] as String? ?? 'System',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lead_id': leadId,
      'deal_id': dealId,
      'type': type,
      'description': description,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

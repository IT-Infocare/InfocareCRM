class AuditLogModel {
  final String id;
  final String action;
  final String entityType;
  final String entityId;
  final String performedBy;
  final String? details;
  final DateTime createdAt;

  AuditLogModel({
    required this.id,
    required this.action,
    required this.entityType,
    required this.entityId,
    required this.performedBy,
    this.details,
    required this.createdAt,
  });

  factory AuditLogModel.fromJson(Map<String, dynamic> json) {
    return AuditLogModel(
      id: json['id'] as String? ?? '',
      action: json['action'] as String? ?? '',
      entityType: json['entity_type'] as String? ?? '',
      entityId: json['entity_id'] as String? ?? '',
      performedBy: json['performed_by'] as String? ?? '',
      details: json['details'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'action': action,
      'entity_type': entityType,
      'entity_id': entityId,
      'performed_by': performedBy,
      'details': details,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

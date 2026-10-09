class TaskModel {
  final String id;
  final String title;
  final String? description;
  final String? leadId;
  final String? dealId;
  final String? customerId;
  final String? relatedToTitle;
  final String assignedUserId;
  final String assignedUserName;
  final DateTime dueDate;
  final String priority; // 'low', 'medium', 'high', 'urgent'
  final String status; // 'pending', 'in_progress', 'completed', 'overdue'
  final DateTime createdAt;

  TaskModel({
    required this.id,
    required this.title,
    this.description,
    this.leadId,
    this.dealId,
    this.customerId,
    this.relatedToTitle,
    required this.assignedUserId,
    required this.assignedUserName,
    required this.dueDate,
    this.priority = 'medium',
    required this.status,
    required this.createdAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      leadId: json['lead_id'] as String?,
      dealId: json['deal_id'] as String?,
      customerId: json['customer_id'] as String?,
      relatedToTitle: json['related_to_title'] as String?,
      assignedUserId: json['assigned_user_id'] as String? ?? '',
      assignedUserName: json['assigned_user_name'] as String? ?? 'Unassigned',
      dueDate: json['due_date'] != null
          ? DateTime.tryParse(json['due_date'].toString()) ?? DateTime.now().add(const Duration(days: 1))
          : DateTime.now().add(const Duration(days: 1)),
      priority: json['priority'] as String? ?? 'medium',
      status: json['status'] as String? ?? 'pending',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'lead_id': leadId,
      'deal_id': dealId,
      'customer_id': customerId,
      'related_to_title': relatedToTitle,
      'assigned_user_id': assignedUserId,
      'assigned_user_name': assignedUserName,
      'due_date': dueDate.toIso8601String(),
      'priority': priority,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  TaskModel copyWith({
    String? status,
    String? assignedUserId,
    String? assignedUserName,
  }) {
    return TaskModel(
      id: id,
      title: title,
      description: description,
      leadId: leadId,
      dealId: dealId,
      customerId: customerId,
      relatedToTitle: relatedToTitle,
      assignedUserId: assignedUserId ?? this.assignedUserId,
      assignedUserName: assignedUserName ?? this.assignedUserName,
      dueDate: dueDate,
      priority: priority,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}

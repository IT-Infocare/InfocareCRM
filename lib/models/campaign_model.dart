class CampaignModel {
  final String id;
  final String name;
  final String channel;
  final DateTime startDate;
  final DateTime endDate;
  final num budget;
  final int leadCount;
  final double conversionRate;
  final num revenueGenerated;
  final bool isActive;

  CampaignModel({
    required this.id,
    required this.name,
    required this.channel,
    required this.startDate,
    required this.endDate,
    required this.budget,
    this.leadCount = 0,
    this.conversionRate = 0.0,
    this.revenueGenerated = 0,
    this.isActive = true,
  });

  factory CampaignModel.fromJson(Map<String, dynamic> json) {
    return CampaignModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      channel: json['channel'] as String? ?? 'general',
      startDate: json['start_date'] != null
          ? DateTime.tryParse(json['start_date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      endDate: json['end_date'] != null
          ? DateTime.tryParse(json['end_date'].toString()) ?? DateTime.now().add(const Duration(days: 30))
          : DateTime.now().add(const Duration(days: 30)),
      budget: (json['budget'] as num?) ?? 0,
      leadCount: (json['lead_count'] as int?) ?? 0,
      conversionRate: (json['conversion_rate'] as num?)?.toDouble() ?? 0.0,
      revenueGenerated: (json['revenue_generated'] as num?) ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'channel': channel,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'budget': budget,
      'lead_count': leadCount,
      'conversion_rate': conversionRate,
      'revenue_generated': revenueGenerated,
      'is_active': isActive,
    };
  }
}

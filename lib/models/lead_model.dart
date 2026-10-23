import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class LeadModel {
  final String id;
  final String? customerId;
  final String contactName;
  final String? companyName;
  final String phone;
  final String email;
  final String? whatsappNumber;
  final String? location;
  final double? latitude;
  final double? longitude;
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
    this.latitude,
    this.longitude,
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

  bool get hasLocation =>
      (latitude != null && longitude != null) ||
      (location != null && location!.trim().isNotEmpty);

  String get displayLocation {
    final hasCoords = latitude != null && longitude != null;
    final hasName = location != null && location!.trim().isNotEmpty;

    if (hasName && hasCoords) {
      return '${location!.trim()} (${latitude!.toStringAsFixed(4)}, ${longitude!.toStringAsFixed(4)})';
    }
    if (hasName) {
      return location!.trim();
    }
    if (hasCoords) {
      return '${latitude!.toStringAsFixed(5)}, ${longitude!.toStringAsFixed(5)}';
    }
    return 'Location not recorded';
  }

  String get googleMapsUrl {
    if (latitude != null && longitude != null) {
      return 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    }
    if (location != null && location!.trim().isNotEmpty) {
      final loc = location!.trim();
      final coordMatch = RegExp(r'(-?\d{1,3}\.\d+)[,\s]+(-?\d{1,3}\.\d+)').firstMatch(loc);
      if (coordMatch != null) {
        return 'https://www.google.com/maps/search/?api=1&query=${coordMatch.group(1)},${coordMatch.group(2)}';
      }
      return 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(loc)}';
    }
    return '';
  }

  Future<bool> openGoogleMaps() async {
    final url = googleMapsUrl;
    if (url.isNotEmpty) {
      final uri = Uri.parse(url);
      try {
        if (kIsWeb) {
          return await launchUrl(
            uri,
            webOnlyWindowName: '_blank',
          );
        } else {
          return await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
        }
      } catch (_) {
        return await launchUrl(uri);
      }
    }
    return false;
  }

  factory LeadModel.fromJson(Map<String, dynamic> json) {
    num parseNum(dynamic val) {
      if (val == null) return 0;
      if (val is num) return val;
      if (val is String) return num.tryParse(val) ?? 0;
      return 0;
    }

    double? parseDouble(dynamic val) {
      if (val == null) return null;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val);
      return null;
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
      latitude: parseDouble(json['latitude']),
      longitude: parseDouble(json['longitude']),
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
      'latitude': latitude,
      'longitude': longitude,
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
    String? contactName,
    String? companyName,
    String? phone,
    String? email,
    String? whatsappNumber,
    String? location,
    double? latitude,
    double? longitude,
    String? requirement,
    String? source,
    String? sourceDetail,
    String? campaign,
    String? capturedBy,
    String? ownerId,
    String? ownerName,
    String? branchId,
    String? branch,
    num? estimatedValue,
    String? productInterest,
    String? status,
    String? stage,
    String? aiSummary,
    String? aiCategory,
    String? aiUrgency,
    String? aiNextStep,
    String? aiDraftReply,
  }) {
    return LeadModel(
      id: id,
      customerId: customerId ?? this.customerId,
      contactName: contactName ?? this.contactName,
      companyName: companyName ?? this.companyName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      requirement: requirement ?? this.requirement,
      source: source ?? this.source,
      sourceDetail: sourceDetail ?? this.sourceDetail,
      campaign: campaign ?? this.campaign,
      capturedBy: capturedBy ?? this.capturedBy,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      branchId: branchId ?? this.branchId,
      branch: branch ?? this.branch,
      estimatedValue: estimatedValue ?? this.estimatedValue,
      productInterest: productInterest ?? this.productInterest,
      status: status ?? this.status,
      stage: stage ?? this.stage,
      aiSummary: aiSummary ?? this.aiSummary,
      aiCategory: aiCategory ?? this.aiCategory,
      aiUrgency: aiUrgency ?? this.aiUrgency,
      aiNextStep: aiNextStep ?? this.aiNextStep,
      aiDraftReply: aiDraftReply ?? this.aiDraftReply,
      isDuplicate: isDuplicate,
      duplicateWarning: duplicateWarning,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

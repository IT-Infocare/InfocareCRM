import 'package:flutter/material.dart';

class LeadSourceUtils {
  static String getLabel(String source) {
    switch (source.toLowerCase()) {
      case 'direct_visit':
        return 'Direct Visit';
      case 'event':
        return 'Event';
      case 'walk_in':
        return 'Walk-in';
      case 'referral':
        return 'Referral';
      case 'email':
        return 'Email';
      case 'facebook':
        return 'Facebook';
      case 'instagram':
        return 'Instagram';
      case 'linkedin':
        return 'LinkedIn';
      case 'whatsapp':
        return 'WhatsApp';
      case 'website':
        return 'Website';
      case 'phone':
        return 'Phone Call';
      default:
        return source.replaceAll('_', ' ').toUpperCase();
    }
  }

  static IconData getIcon(String source) {
    switch (source.toLowerCase()) {
      case 'direct_visit':
        return Icons.location_on_outlined;
      case 'event':
        return Icons.event_outlined;
      case 'walk_in':
        return Icons.directions_walk_outlined;
      case 'referral':
        return Icons.people_outline;
      case 'email':
        return Icons.email_outlined;
      case 'facebook':
        return Icons.facebook_outlined;
      case 'instagram':
        return Icons.camera_alt_outlined;
      case 'linkedin':
        return Icons.business_outlined;
      case 'whatsapp':
        return Icons.chat_bubble_outline;
      case 'website':
        return Icons.language_outlined;
      case 'phone':
        return Icons.phone_outlined;
      default:
        return Icons.label_outline;
    }
  }

  static Color getColor(String source) {
    switch (source.toLowerCase()) {
      case 'whatsapp':
        return const Color(0xFF25D366);
      case 'facebook':
        return const Color(0xFF1877F2);
      case 'instagram':
        return const Color(0xFFE4405F);
      case 'linkedin':
        return const Color(0xFF0A66C2);
      case 'email':
        return const Color(0xFFEA4335);
      case 'website':
        return const Color(0xFF0F766E);
      case 'referral':
        return const Color(0xFF8B5CF6);
      case 'phone':
        return const Color(0xFF3B82F6);
      case 'direct_visit':
      case 'walk_in':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF64748B);
    }
  }
}

import 'package:flutter/material.dart';

class ActivityTypeUtils {
  static String getLabel(String type) {
    switch (type.toLowerCase()) {
      case 'call':
        return 'Phone Call';
      case 'visit':
        return 'Site / Client Visit';
      case 'email':
        return 'Email Sent/Received';
      case 'whatsapp':
        return 'WhatsApp Message';
      case 'note':
        return 'Internal Note';
      case 'site_survey':
        return 'Site Survey Conducted';
      case 'quotation_sent':
        return 'Quotation Sent';
      case 'boq_review':
        return 'BOQ Review';
      case 'stage_changed':
        return 'Stage Updated';
      case 'lead_created':
        return 'Lead Created';
      case 'task_created':
        return 'Task Added';
      default:
        return type.replaceAll('_', ' ').toUpperCase();
    }
  }

  static IconData getIcon(String type) {
    switch (type.toLowerCase()) {
      case 'call':
        return Icons.phone_outlined;
      case 'visit':
        return Icons.location_on_outlined;
      case 'email':
        return Icons.email_outlined;
      case 'whatsapp':
        return Icons.chat_outlined;
      case 'note':
        return Icons.note_alt_outlined;
      case 'site_survey':
        return Icons.engineering_outlined;
      case 'quotation_sent':
        return Icons.request_quote_outlined;
      case 'boq_review':
        return Icons.inventory_2_outlined;
      case 'stage_changed':
        return Icons.alt_route_outlined;
      case 'lead_created':
        return Icons.person_add_alt_1_outlined;
      case 'task_created':
        return Icons.task_alt_outlined;
      default:
        return Icons.history_outlined;
    }
  }

  static Color getColor(String type) {
    switch (type.toLowerCase()) {
      case 'call':
        return const Color(0xFF3B82F6);
      case 'visit':
      case 'site_survey':
        return const Color(0xFFF59E0B);
      case 'email':
        return const Color(0xFFEA4335);
      case 'whatsapp':
        return const Color(0xFF25D366);
      case 'note':
        return const Color(0xFF64748B);
      case 'quotation_sent':
      case 'boq_review':
        return const Color(0xFF0F766E);
      case 'stage_changed':
        return const Color(0xFF8B5CF6);
      case 'lead_created':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF64748B);
    }
  }
}

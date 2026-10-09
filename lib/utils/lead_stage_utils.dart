import 'package:flutter/material.dart';

class LeadStageUtils {
  static String getLabel(String stage) {
    switch (stage.toLowerCase()) {
      case 'new':
        return 'New';
      case 'contacted':
        return 'Contacted';
      case 'qualified':
        return 'Qualified';
      case 'disqualified':
        return 'Disqualified';
      case 'converted':
        return 'Converted';
      case 'site_survey':
        return 'Site Survey';
      case 'quotation_sent':
        return 'Quotation Sent';
      case 'negotiation':
        return 'Negotiation';
      case 'won':
        return 'Won';
      case 'lost':
        return 'Lost';
      default:
        return stage.replaceAll('_', ' ').toUpperCase();
    }
  }

  static Color getColor(String stage) {
    switch (stage.toLowerCase()) {
      case 'new':
        return const Color(0xFF3B82F6); // Blue
      case 'contacted':
        return const Color(0xFF8B5CF6); // Purple
      case 'qualified':
        return const Color(0xFF06B6D4); // Cyan
      case 'site_survey':
        return const Color(0xFFF59E0B); // Amber
      case 'quotation_sent':
        return const Color(0xFF0F766E); // Teal
      case 'negotiation':
        return const Color(0xFFD97706); // Dark Amber
      case 'won':
      case 'converted':
        return const Color(0xFF10B981); // Emerald Green
      case 'lost':
      case 'disqualified':
        return const Color(0xFFEF4444); // Red
      default:
        return const Color(0xFF64748B);
    }
  }

  static Color getBgColor(String stage) {
    return getColor(stage).withValues(alpha: 0.12);
  }

  static String deriveStatusFromStage(String stage) {
    switch (stage.toLowerCase()) {
      case 'new':
        return 'new';
      case 'contacted':
      case 'site_survey':
        return 'contacted';
      case 'quotation_sent':
      case 'negotiation':
        return 'qualified';
      case 'won':
        return 'converted';
      case 'lost':
        return 'disqualified';
      default:
        return 'new';
    }
  }
}


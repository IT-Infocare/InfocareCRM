import 'package:flutter/material.dart';
import '../utils/lead_stage_utils.dart';

class StageBadge extends StatelessWidget {
  final String stage;

  const StageBadge({super.key, required this.stage});

  @override
  Widget build(BuildContext context) {
    final color = LeadStageUtils.getColor(stage);
    final bgColor = LeadStageUtils.getBgColor(stage);
    final label = LeadStageUtils.getLabel(stage);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

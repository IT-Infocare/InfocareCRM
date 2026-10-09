import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class FilterChipBar extends StatelessWidget {
  final List<String> options;
  final String selectedOption;
  final ValueChanged<String> onSelected;

  const FilterChipBar({
    super.key,
    required this.options,
    required this.selectedOption,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options.map((opt) {
          final isSelected = opt == selectedOption;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(opt),
              selected: isSelected,
              onSelected: (_) => onSelected(opt),
              selectedColor: AppTheme.primaryTeal.withValues(alpha: 0.15),
              backgroundColor: AppTheme.surface,
              side: BorderSide(
                color: isSelected ? AppTheme.primaryTeal : AppTheme.border,
                width: 1,
              ),
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.primaryTeal : AppTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

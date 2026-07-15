import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../spacing.dart';

class AppSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilter;
  final String hintText;
  final bool showFilter;
  final VoidCallback? onClear;
  final bool autofocus;

  const AppSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onFilter,
    this.hintText = 'Search prayers, hymns, keywords...',
    this.showFilter = true,
    this.onClear,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(Spacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: Spacing.lg),
          const Icon(Icons.search, color: AppColors.textTertiary),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              autofocus: autofocus,
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
                hintStyle: const TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 16,
                ),
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (showFilter)
            IconButton(
              onPressed: onFilter,
              icon: const Icon(Icons.filter_list,
                  color: AppColors.textTertiary),
            ),
          const SizedBox(width: Spacing.xs),
        ],
      ),
    );
  }
}

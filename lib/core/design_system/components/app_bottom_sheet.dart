import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../spacing.dart';

class AppBottomSheet {
  static void show(
    BuildContext context, {
    required String title,
    required Widget child,
    double initialChildSize = 0.5,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Spacing.radiusXl),
        ),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: initialChildSize,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            children: [
              const SizedBox(height: Spacing.md),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: Spacing.lg),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.xl),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: Spacing.lg),
              const Divider(height: 1, color: AppColors.divider),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(Spacing.xl),
                  children: [child],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../spacing.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final Color? color;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(Spacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Spacing.radiusLg),
          child: card,
        ),
      );
    }

    return card;
  }
}

class ContentCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? badge;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;

  const ContentCard({
    super.key,
    required this.title,
    this.subtitle,
    this.badge,
    required this.icon,
    this.iconColor = AppColors.primary,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(Spacing.lg),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(Spacing.radiusMd),
            ),
            child: Icon(icon, color: iconColor, size: Spacing.iconMd),
          ),
          const SizedBox(width: Spacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                if (subtitle != null) ...[
                  const SizedBox(height: Spacing.xs),
                  Text(subtitle!,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                ],
              ],
            ),
          ),
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.sm, vertical: Spacing.xxs),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(Spacing.radiusSm),
              ),
              child: Text(badge!,
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500)),
            ),
          const SizedBox(width: Spacing.sm),
          const Icon(Icons.chevron_right,
              color: AppColors.textTertiary, size: Spacing.iconMd),
        ],
      ),
    );
  }
}

class CompactCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const CompactCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(Spacing.radiusMd),
            ),
            child: Icon(icon, color: color, size: Spacing.iconMd),
          ),
          const SizedBox(height: Spacing.md),
          Text(title,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          if (subtitle != null) ...[
            const SizedBox(height: Spacing.xxs),
            Text(subtitle!,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary)),
          ],
        ],
      ),
    );
  }
}

class PrayerCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const PrayerCard({
    super.key,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(Spacing.lg),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: Spacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                if (subtitle != null) ...[
                  const SizedBox(height: Spacing.xxs),
                  Text(subtitle!,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                ],
              ],
            ),
          ),
          const Icon(Icons.chevron_right,
              color: AppColors.textTertiary, size: Spacing.iconMd),
        ],
      ),
    );
  }
}

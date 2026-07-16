import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../config/app_colors.dart';
import '../config/app_config.dart';
import '../design_system/app_typography.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    children: [
                      _buildMenuSection(
                        context,
                        title: 'Navigate',
                        items: [
                          _DrawerItem(
                            icon: Icons.home_outlined,
                            label: 'Home',
                            route: '/home',
                            isActive: location.startsWith('/home'),
                          ),
                          _DrawerItem(
                            icon: Icons.menu_book_outlined,
                            label: 'Library',
                            route: '/library',
                            isActive: location.startsWith('/library'),
                          ),
                          _DrawerItem(
                            icon: Icons.search,
                            label: 'Search',
                            route: '/search',
                            isActive: location.startsWith('/search') && !location.startsWith('/settings'),
                          ),
                          _DrawerItem(
                            icon: Icons.bookmark_outline,
                            label: 'Bookmarks',
                            route: '/workspace',
                            isActive: location.startsWith('/workspace'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      _buildMenuSection(
                        context,
                        title: 'Devotions',
                        items: [
                          _DrawerItem(
                            icon: Icons.circle_outlined,
                            label: 'Rosary Guide',
                            route: '/rosary',
                            isActive: location.startsWith('/rosary'),
                          ),
                          _DrawerItem(
                            icon: Icons.notifications_outlined,
                            label: 'Prayer Reminders',
                            route: '/reminders',
                            isActive: location.startsWith('/reminders'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      _buildMenuSection(
                        context,
                        title: 'App',
                        items: [
                          _DrawerItem(
                            icon: Icons.settings_outlined,
                            label: 'Settings',
                            route: '/settings',
                            isActive: location.startsWith('/settings'),
                          ),
                          _DrawerItem(
                            icon: Icons.info_outline_rounded,
                            label: 'About',
                            route: '/about',
                            isActive: location.startsWith('/about'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Crest
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/images/makeni_crest.png',
              width: 56,
              height: 56,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 14),
          // App name
          const Text(
            AppConfig.appName,
            style: TextStyle(
              fontFamily: 'Playfair Display',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppConfig.bookSubtitle,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.7),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'v${AppConfig.appVersion}',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                color: AppColors.accentLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(
    BuildContext context, {
    required String title,
    required List<_DrawerItem> items,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 6, top: 4),
            child: Text(
              title.toUpperCase(),
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ),
          ...items.map((item) => _buildMenuItem(context, item)),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, _DrawerItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
            if (!item.isActive) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.go(item.route);
              });
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: item.isActive
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  size: 22,
                  color: item.isActive ? AppColors.primary : AppColors.textSecondary,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    item.label,
                    style: AppTypography.labelLarge.copyWith(
                      color: item.isActive ? AppColors.primary : AppColors.textPrimary,
                      fontWeight: item.isActive ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
                if (item.isActive)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.divider,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/bishop_koroma_landscape.png',
              width: 48,
              height: 36,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rev. Dr. Bob John Hassan Koroma',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Bishop of Makeni Diocese',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem {
  final IconData icon;
  final String label;
  final String route;
  final bool isActive;

  _DrawerItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.isActive,
  });
}

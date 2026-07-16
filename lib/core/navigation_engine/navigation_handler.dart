import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/library/presentation/library_screen.dart';
import '../../features/reader/presentation/reader_screen.dart';
import '../../features/reminders/presentation/reminders_screen.dart';
import '../../features/rosary/presentation/rosary_screen.dart';
import '../../features/search/presentation/search_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/workspace/presentation/workspace_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/about/presentation/about_screen.dart';
import '../config/app_colors.dart';
import '../config/routes.dart';
import '../design_system/app_typography.dart';
import 'app_drawer.dart';

class NavigationHandler {
  static final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: Routes.splash,
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: Routes.home,
            pageBuilder: (context, state) => const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: Routes.library,
            pageBuilder: (context, state) => const NoTransitionPage(child: LibraryScreen()),
          ),
          GoRoute(
            path: Routes.search,
            pageBuilder: (context, state) => const NoTransitionPage(child: SearchScreen()),
          ),
          GoRoute(
            path: Routes.workspace,
            pageBuilder: (context, state) => const NoTransitionPage(child: WorkspaceScreen()),
          ),
          GoRoute(
            path: Routes.settings,
            pageBuilder: (context, state) => const NoTransitionPage(child: SettingsScreen()),
          ),
        ],
      ),
      GoRoute(
        path: '${Routes.reader}/:id',
        builder: (context, state) => ReaderScreen(
          contentId: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: '${Routes.readerHymn}/:number',
        builder: (context, state) => ReaderScreen(
          hymnNumber: int.tryParse(state.pathParameters['number'] ?? ''),
        ),
      ),
      GoRoute(
        path: '${Routes.readerPage}/:page',
        builder: (context, state) => ReaderScreen(
          pageNumber: int.tryParse(state.pathParameters['page'] ?? ''),
        ),
      ),
      GoRoute(
        path: Routes.reminders,
        builder: (context, state) => const RemindersScreen(),
      ),
      GoRoute(
        path: Routes.rosary,
        builder: (context, state) => const RosaryScreen(),
      ),
      GoRoute(
        path: Routes.about,
        builder: (context, state) => const AboutScreen(),
      ),
    ],
  );
}

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      drawer: const AppDrawer(),
      bottomNavigationBar: const _MainBottomNav(),
    );
  }
}

class _MainBottomNav extends StatelessWidget {
  const _MainBottomNav();

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    int currentIndex = 0;
    if (location.startsWith(Routes.search)) currentIndex = 1;
    if (location.startsWith(Routes.rosary)) currentIndex = 2;
    if (location.startsWith(Routes.workspace)) currentIndex = 3;
    // index 4 = More (drawer)

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Home',
                isActive: currentIndex == 0,
                onTap: () => context.go(Routes.home),
              ),
              _NavItem(
                icon: Icons.search,
                activeIcon: Icons.search_rounded,
                label: 'Search',
                isActive: currentIndex == 1,
                onTap: () => context.go(Routes.search),
              ),
              _NavItem(
                icon: Icons.circle_outlined,
                activeIcon: Icons.circle,
                label: 'Devotions',
                isActive: currentIndex == 2,
                onTap: () => context.go(Routes.rosary),
              ),
              _NavItem(
                icon: Icons.bookmark_outline,
                activeIcon: Icons.bookmark_rounded,
                label: 'Bookmarks',
                isActive: currentIndex == 3,
                onTap: () => context.go(Routes.workspace),
              ),
              _NavItem(
                icon: Icons.more_horiz_rounded,
                activeIcon: Icons.more_horiz_rounded,
                label: 'More',
                isActive: currentIndex == 4,
                onTap: () {
                  final scaffold = Scaffold.of(context);
                  if (scaffold.isDrawerOpen) {
                    Navigator.pop(context);
                  } else {
                    scaffold.openDrawer();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withValues(alpha: 0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isActive ? activeIcon : icon,
                key: ValueKey(isActive),
                size: 24,
                color: isActive ? AppColors.primary : AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? AppColors.primary : AppColors.textTertiary,
              ),
            ),
            if (isActive) ...[
              const SizedBox(height: 3),
              Container(
                width: 16,
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

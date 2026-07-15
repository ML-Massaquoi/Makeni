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
import '../config/routes.dart';

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
      bottomNavigationBar: _MainBottomNav(),
    );
  }
}

class _MainBottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    int currentIndex = 0;
    if (location.startsWith(Routes.library)) currentIndex = 1;
    if (location.startsWith(Routes.search)) currentIndex = 2;
    if (location.startsWith(Routes.workspace)) currentIndex = 3;

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            context.go(Routes.home);
          case 1:
            context.go(Routes.library);
          case 2:
            context.go(Routes.search);
          case 3:
            context.go(Routes.workspace);
        }
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.search), selectedIcon: Icon(Icons.search), label: 'Search'),
        NavigationDestination(icon: Icon(Icons.book_outlined), selectedIcon: Icon(Icons.book), label: 'Prayer Book'),
        NavigationDestination(icon: Icon(Icons.bookmark_outline), selectedIcon: Icon(Icons.bookmark), label: 'Bookmarks'),
      ],
    );
  }
}
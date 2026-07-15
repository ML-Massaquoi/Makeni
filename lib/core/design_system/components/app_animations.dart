import 'package:flutter/material.dart';

class AppAnimations {
  AppAnimations._();

  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);

  static Widget fadeIn({
    required Widget child,
    bool animate = true,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    if (!animate) return child;
    return AnimatedOpacity(
      opacity: 1,
      duration: duration,
      child: child,
    );
  }

  static Widget slideUp({
    required Widget child,
    bool animate = true,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    if (!animate) return child;
    return AnimatedSlide(
      offset: Offset.zero,
      duration: duration,
      child: child,
    );
  }
}

class FadeTransitionPage extends Page {
  final Widget child;

  const FadeTransitionPage({required this.child, super.key});

  @override
  Route createRoute(BuildContext context) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 250),
    );
  }
}

class SlideTransitionPage extends Page {
  final Widget child;

  const SlideTransitionPage({required this.child, super.key});

  @override
  Route createRoute(BuildContext context) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.08),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          )),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}

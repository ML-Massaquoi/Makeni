import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/routes.dart';
import '../../../core/di/injection.dart';
import '../../../core/storage/local_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  bool _navigating = false;

  late AnimationController _masterController;
  late Animation<double> _masterFade;

  late AnimationController _bgController;
  late Animation<double> _bgFade;

  late AnimationController _logoController;
  late Animation<double> _logoFade;

  late AnimationController _titleController;
  late Animation<double> _titleFade;

  late AnimationController _subtitleController;
  late Animation<double> _subtitleFade;

  late AnimationController _taglineController;
  late Animation<double> _taglineFade;

  late AnimationController _dotController;

  late AnimationController _lightController;
  late Animation<double> _lightPosition;
  late Animation<double> _lightOpacity;

  late AnimationController _navFadeController;
  late Animation<double> _navFade;

  @override
  void initState() {
    super.initState();

    _masterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _masterFade = CurvedAnimation(
      parent: _masterController,
      curve: Curves.easeOut,
    );

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _bgFade = CurvedAnimation(
      parent: _bgController,
      curve: Curves.easeOut,
    );

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _logoFade = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOut,
    );

    _titleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _titleFade = CurvedAnimation(
      parent: _titleController,
      curve: Curves.easeOut,
    );

    _subtitleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _subtitleFade = CurvedAnimation(
      parent: _subtitleController,
      curve: Curves.easeOut,
    );

    _taglineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _taglineFade = CurvedAnimation(
      parent: _taglineController,
      curve: Curves.easeOut,
    );

    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    _lightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    _lightPosition = Tween<double>(begin: -0.3, end: 1.3).animate(
      CurvedAnimation(
        parent: _lightController,
        curve: Curves.easeInOut,
      ),
    );
    _lightOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.12), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.12, end: 0.12), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 0.12, end: 0.0), weight: 30),
    ]).animate(_lightController);

    _navFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _navFade = CurvedAnimation(
      parent: _navFadeController,
      curve: Curves.easeOut,
    );

    _startAnimationSequence();
  }

  Future<void> _startAnimationSequence() async {
    _masterController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _bgController.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    _titleController.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    _subtitleController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _taglineController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _lightController.forward();

    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted || _navigating) return;
    _navigate();
  }

  Future<void> _navigate() async {
    _navigating = true;
    _navFadeController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    final storage = getIt<LocalStorage>();
    if (storage.isOnboardingComplete()) {
      context.go(Routes.home);
    } else {
      context.go(Routes.onboarding);
    }
  }

  @override
  void dispose() {
    _masterController.dispose();
    _bgController.dispose();
    _logoController.dispose();
    _titleController.dispose();
    _subtitleController.dispose();
    _taglineController.dispose();
    _dotController.dispose();
    _lightController.dispose();
    _navFadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: AnimatedBuilder(
        animation: _masterFade,
        builder: (context, child) {
          return Opacity(
            opacity: _masterFade.value,
            child: FadeTransition(
              opacity: _navFade,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Cathedral background image
                  FadeTransition(
                    opacity: _bgFade,
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
                      child: ColorFiltered(
                        colorFilter: const ColorFilter.matrix([
                          0.75, 0.15, 0.10, 0, 0,
                          0.10, 0.75, 0.10, 0, 0,
                          0.10, 0.10, 0.80, 0, 0,
                          0, 0, 0, 1, 0,
                        ]),
                        child: Image.asset(
                          'assets/images/gpt_crops/cathedral_hero.png',
                          fit: BoxFit.fitWidth,
                          width: double.infinity,
                          height: double.infinity,
                          alignment: const Alignment(0.0, -0.2),
                        ),
                      ),
                    ),
                  ),

                  // Dark gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF0A1628).withValues(alpha: 0.3),
                          const Color(0xFF0A1628).withValues(alpha: 0.1),
                          const Color(0xFF0A1628).withValues(alpha: 0.15),
                          const Color(0xFF0A1628).withValues(alpha: 0.6),
                        ],
                        stops: const [0.0, 0.3, 0.55, 1.0],
                      ),
                    ),
                  ),

                  // Vignette
                  Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 1.0,
                        colors: [
                          Colors.transparent,
                          const Color(0xFF0A1628).withValues(alpha: 0.35),
                        ],
                        stops: const [0.55, 1.0],
                      ),
                    ),
                  ),

                  // Light of Hope beam
                  AnimatedBuilder(
                    animation: _lightController,
                    builder: (context, child) {
                      return Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(
                            painter: _LightBeamPainter(
                              position: _lightPosition.value,
                              opacity: _lightOpacity.value,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  // Centered branding content
                  SafeArea(
                    child: Column(
                      children: [
                        const Spacer(flex: 3),

                        // Diocese crest
                        FadeTransition(
                          opacity: _logoFade,
                          child: _buildDioceseCrest(),
                        ),

                        const SizedBox(height: 28),

                        // App name: "MAKENI PRAYER AND HYMN BOOK"
                        FadeTransition(
                          opacity: _titleFade,
                          child: const Text(
                            'MAKENI\nPRAYER & HYMN BOOK',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Playfair Display',
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1.15,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Subtitle: "CATHOLIC COMPANION"
                        FadeTransition(
                          opacity: _subtitleFade,
                          child: const Text(
                            'CATHOLIC COMPANION',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFD4A84A),
                              letterSpacing: 4.0,
                            ),
                          ),
                        ),

                        const SizedBox(height: 6),

                        // Diocese line
                        FadeTransition(
                          opacity: _subtitleFade,
                          child: Text(
                            'DIOCESE OF MAKENI',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withValues(alpha: 0.7),
                              letterSpacing: 3.0,
                            ),
                          ),
                        ),

                        const Spacer(flex: 2),

                        // Tagline: "Rooted in Faith. Inspired by Makeni."
                        FadeTransition(
                          opacity: _taglineFade,
                          child: Text(
                            'Rooted in Faith. Inspired by Makeni.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Lora',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.italic,
                              color: Colors.white.withValues(alpha: 0.8),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Breathing dots
                        AnimatedBuilder(
                          animation: _dotController,
                          builder: (context, child) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildDot(_getDotOpacity(0)),
                                const SizedBox(width: 12),
                                _buildDot(_getDotOpacity(1)),
                                const SizedBox(width: 12),
                                _buildDot(_getDotOpacity(2)),
                              ],
                            );
                          },
                        ),

                        SizedBox(
                          height: MediaQuery.of(context).padding.bottom + 48,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  double _getDotOpacity(int dotIndex) {
    final t = _dotController.value;
    final phase = (t * 3).floor();
    switch (phase) {
      case 0:
        return dotIndex == 0 ? 1.0 : 0.2;
      case 1:
        return dotIndex < 2 ? 1.0 : 0.2;
      case 2:
        return 1.0;
      default:
        return 0.2;
    }
  }

  Widget _buildDot(double opacity) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFD4A84A).withValues(alpha: opacity),
      ),
    );
  }

  Widget _buildDioceseCrest() {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFD4A84A).withValues(alpha: 0.6),
          width: 2,
        ),
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/gpt_crops/diocese_crest.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF0A3D62),
              ),
              child: const Icon(
                Icons.church,
                size: 40,
                color: Color(0xFFD4A84A),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LightBeamPainter extends CustomPainter {
  final double position;
  final double opacity;

  _LightBeamPainter({required this.position, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;

    final centerX = size.width * position;
    final beamWidth = size.width * 0.35;

    final rect = Rect.fromCenter(
      center: Offset(centerX, size.height * 0.4),
      width: beamWidth,
      height: size.height * 1.2,
    );

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFD4A84A).withValues(alpha: 0.0),
          const Color(0xFFD4A84A).withValues(alpha: opacity),
          const Color(0xFFD4A84A).withValues(alpha: opacity * 0.6),
          const Color(0xFFD4A84A).withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.3, 0.6, 1.0],
      ).createShader(rect);

    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(_LightBeamPainter oldDelegate) {
    return oldDelegate.position != position || oldDelegate.opacity != opacity;
  }
}

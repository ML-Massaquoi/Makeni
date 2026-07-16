import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/routes.dart';
import '../../../core/di/injection.dart';
import '../../../core/storage/local_storage.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  void _onNext() {
    if (_currentPage < 2) {
      _fadeController.reset();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
      _fadeController.forward();
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    getIt<LocalStorage>().setOnboardingComplete(true);
    context.go(Routes.home);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: 3,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
              _fadeController.reset();
              _fadeController.forward();
            },
            itemBuilder: (context, index) {
              switch (index) {
                case 0:
                  return _buildWelcomeScreen();
                case 1:
                  return _buildBishopScreen();
                case 2:
                  return _buildCommunityScreen();
                default:
                  return const SizedBox.shrink();
              }
            },
          ),

          // Skip button
          if (_currentPage < 2)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 24,
              child: TextButton(
                onPressed: _finishOnboarding,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text(
                  'SKIP',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),

          // Bottom dots + button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 32,
                left: 32,
                right: 32,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        width: i == _currentPage ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i == _currentPage
                              ? const Color(0xFFD4A84A)
                              : Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0A3D62),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentPage == 0
                            ? 'BEGIN JOURNEY'
                            : _currentPage == 1
                                ? 'CONTINUE'
                                : 'START PRAYING',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // PAGE ONE — Welcome Home
  Widget _buildWelcomeScreen() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background image with blur
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: ColorFiltered(
            colorFilter: const ColorFilter.matrix([
              0.70, 0.15, 0.10, 0, 0,
              0.10, 0.70, 0.10, 0, 0,
              0.10, 0.10, 0.75, 0, 0,
              0, 0, 0, 1, 0,
            ]),
            child: Image.asset(
              'assets/images/gpt_crops/cathedral_hero.png',
              fit: BoxFit.fitWidth,
              alignment: const Alignment(0.0, -0.15),
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
                const Color(0xFF0A1628).withValues(alpha: 0.7),
                const Color(0xFF0A1628).withValues(alpha: 0.3),
                const Color(0xFF0A1628).withValues(alpha: 0.35),
                const Color(0xFF0A1628).withValues(alpha: 0.85),
              ],
              stops: const [0.0, 0.3, 0.6, 1.0],
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
                const Color(0xFF0A1628).withValues(alpha: 0.5),
              ],
              stops: const [0.5, 1.0],
            ),
          ),
        ),

        // Content
        FadeTransition(
          opacity: _fadeAnimation,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: Column(
                children: [
                  const Spacer(flex: 3),

                  Text(
                    'Welcome to',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Lora',
                      fontSize: 18,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 12),

                  const Text(
                    'Makeni\nPrayer & Hymn Book',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Playfair Display',
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Text(
                    'Catholic Companion',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFD4A84A),
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 32),

                  Text(
                    'Bringing the treasured prayers, hymns\nand traditions of the Diocese of Makeni\ninto a beautiful digital experience.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Lora',
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.65),
                      height: 1.7,
                    ),
                  ),

                  const Spacer(flex: 4),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // PAGE TWO — A Message From Our Bishop
  Widget _buildBishopScreen() {
    return Container(
      color: const Color(0xFF0A1628),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Bishop portrait
                Container(
                  width: 180,
                  height: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4A84A).withValues(alpha: 0.15),
                        blurRadius: 32,
                        offset: const Offset(0, 12),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      'assets/images/gpt_crops/bishop_portrait.png',
                      fit: BoxFit.cover,
                      alignment: const Alignment(0.0, -0.1),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                const Text(
                  'A Message of Welcome',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Playfair Display',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  '"May this application accompany\nyou in prayer, deepen your faith,\nand help you grow closer to\nChrist wherever you are."',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Lora',
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    color: Colors.white.withValues(alpha: 0.7),
                    height: 1.7,
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  'May God bless you.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Lora',
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  '+ Bishop of Makeni',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: const Color(0xFFD4A84A).withValues(alpha: 0.8),
                    letterSpacing: 1.5,
                  ),
                ),

                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // PAGE THREE — Key Features
  Widget _buildCommunityScreen() {
    final features = [
      ('Offline Access', 'Pray anywhere, anytime', Icons.cloud_off_outlined),
      ('Powerful Search', 'Find any prayer in seconds', Icons.search),
      ('Quick Jump', 'Go to any hymn or prayer', Icons.flash_on_outlined),
      ('Daily Inspiration', 'Grow in faith every day', Icons.wb_sunny_outlined),
      ('Bookmarks & Notes', 'Save and reflect', Icons.bookmark_outline),
    ];

    return Container(
      color: const Color(0xFF0A1628),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Diocese crest
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFD4A84A).withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/gpt_crops/diocese_crest.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Rooted in Heritage\nBuilt for You',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Playfair Display',
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'The Makeni Prayer and Hymn Book has been a\ncompanion of faith for generations.\nThis digital edition preserves our\ntradition while making it accessible\nto all, everywhere.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Lora',
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.65),
                    height: 1.7,
                  ),
                ),

                const SizedBox(height: 32),

                // Feature list
                ...features.map((f) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0A3D62).withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              f.$3,
                              size: 20,
                              color: const Color(0xFFD4A84A),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  f.$1,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                                Text(
                                  f.$2,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

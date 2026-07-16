import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_config.dart';
import '../../../core/config/routes.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.06,
              child: Image.asset(
                'assets/images/gpt_crops/cathedral_hero.png',
                fit: BoxFit.cover,
                alignment: const Alignment(0.0, -0.2),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF0A1628).withValues(alpha: 0.4),
                    const Color(0xFF0A1628).withValues(alpha: 0.1),
                    const Color(0xFF0A1628).withValues(alpha: 0.15),
                    const Color(0xFF0A1628).withValues(alpha: 0.8),
                  ],
                  stops: const [0.0, 0.3, 0.55, 1.0],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, size: 24),
                        color: Colors.white,
                        onPressed: () => context.go(Routes.home),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'About',
                          style: TextStyle(
                            fontFamily: 'Playfair Display',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        // Diocese crest
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFD4A84A).withValues(alpha: 0.5),
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/gpt_crops/diocese_crest.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: const Color(0xFF0A3D62),
                                  child: const Icon(Icons.church, size: 40, color: Color(0xFFD4A84A)),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'MAKENI PRAYER BOOK',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Playfair Display',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'CATHOLIC COMPANION',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFD4A84A),
                            letterSpacing: 4.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'DIOCESE OF MAKENI',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 9,
                            fontWeight: FontWeight.w400,
                            color: Colors.white54,
                            letterSpacing: 3.0,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Version ${AppConfig.appVersion}',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Thank you section
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFD4A84A).withValues(alpha: 0.15),
                              width: 0.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.favorite_rounded, size: 24, color: const Color(0xFFD4A84A).withValues(alpha: 0.8)),
                              const SizedBox(height: 12),
                              const Text(
                                'With Gratitude',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Playfair Display',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'This digital prayer book is made possible through the vision, support, and blessings of many individuals dedicated to serving the Catholic faithful of Makeni.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Lora',
                                  fontSize: 12,
                                  height: 1.6,
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Acknowledgments header
                        Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: const Color(0xFFD4A84A).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(Icons.emoji_people_rounded, size: 14, color: Color(0xFFD4A84A)),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Acknowledgments',
                              style: TextStyle(
                                fontFamily: 'Playfair Display',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Bishop card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFD4A84A).withValues(alpha: 0.2),
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color(0xFFD4A84A).withValues(alpha: 0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(13),
                                  child: Image.asset(
                                    'assets/images/gpt_crops/bishop_portrait.png',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: const Color(0xFF0A3D62),
                                        child: const Icon(Icons.person, size: 32, color: Color(0xFFD4A84A)),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Rev. Dr. Bob John Hassan Koroma',
                                      style: TextStyle(
                                        fontFamily: 'Playfair Display',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      'Bishop of the Catholic Diocese of Makeni',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFFD4A84A).withValues(alpha: 0.9),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'For his visionary leadership, pastoral guidance, and unwavering support in bringing this digital prayer book to life for the faithful of Makeni.',
                                      style: TextStyle(
                                        fontFamily: 'Lora',
                                        fontSize: 11,
                                        height: 1.5,
                                        color: Colors.white.withValues(alpha: 0.65),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: Text(
                            'More acknowledgments coming soon',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.4),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Container(width: 40, height: 1, color: Colors.white.withValues(alpha: 0.1)),
                        const SizedBox(height: 16),
                        Text(
                          'DIOCESE OF MAKENI',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.4),
                            letterSpacing: 3.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rooted in Faith. Inspired by Makeni.',
                          style: TextStyle(
                            fontFamily: 'Lora',
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                      ],
                    ),
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

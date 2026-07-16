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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, size: 22),
                        color: Colors.white,
                        onPressed: () => context.go(Routes.home),
                      ),
                      const SizedBox(width: 4),
                      const Expanded(
                        child: Text(
                          'About',
                          style: TextStyle(
                            fontFamily: 'Playfair Display',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                    children: [
                      // Crest
                      Center(
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFD4A84A).withValues(alpha: 0.5),
                              width: 1.5,
                            ),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/gpt_crops/diocese_crest.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: const Color(0xFF0A3D62),
                                  child: const Icon(Icons.church, size: 32, color: Color(0xFFD4A84A)),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Center(
                        child: Text(
                          'MAKENI\nPRAYER & HYMN BOOK',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Playfair Display',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Center(
                        child: Text(
                          'CATHOLIC COMPANION',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFD4A84A),
                            letterSpacing: 4.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Center(
                        child: Text(
                          'Version ${AppConfig.appVersion}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Gratitude
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFFD4A84A).withValues(alpha: 0.15),
                            width: 0.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.favorite_rounded, size: 20, color: const Color(0xFFD4A84A).withValues(alpha: 0.8)),
                            const SizedBox(height: 10),
                            const Text(
                              'With Gratitude',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Playfair Display',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'This digital prayer book is made possible through the vision, support, and blessings of many dedicated to serving the Catholic faithful of Makeni.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Lora',
                                fontSize: 11,
                                height: 1.5,
                                color: Colors.white.withValues(alpha: 0.7),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Acknowledgments
                      Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4A84A).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Icon(Icons.emoji_people_rounded, size: 12, color: Color(0xFFD4A84A)),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Acknowledgments',
                            style: TextStyle(
                              fontFamily: 'Playfair Display',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Bishop card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFFD4A84A).withValues(alpha: 0.2),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                'assets/images/gpt_crops/bishop_portrait.png',
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 56,
                                    height: 56,
                                    color: const Color(0xFF0A3D62),
                                    child: const Icon(Icons.person, size: 28, color: Color(0xFFD4A84A)),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Rev. Dr. Bob John Hassan Koroma',
                                    style: TextStyle(
                                      fontFamily: 'Playfair Display',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Bishop of the Catholic Diocese of Makeni',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 9,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFFD4A84A).withValues(alpha: 0.9),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'For his visionary leadership and unwavering support in bringing this digital prayer book to life.',
                                    style: TextStyle(
                                      fontFamily: 'Lora',
                                      fontSize: 10,
                                      height: 1.4,
                                      color: Colors.white.withValues(alpha: 0.65),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          'More acknowledgments coming soon',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            color: Colors.white.withValues(alpha: 0.4),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: Text(
                          'DIOCESE OF MAKENI',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 8,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.4),
                            letterSpacing: 3.0,
                          ),
                        ),
                      ),
                    ],
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

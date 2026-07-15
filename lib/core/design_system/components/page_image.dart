import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../spacing.dart';

class PageImageProvider {
  PageImageProvider._();

  static final Map<int, String> _imageMap = {
    6: 'assets/images/6_6.jpeg',
    20: 'assets/images/20_20.jpeg',
    68: 'assets/images/sacred_heart_68.jpeg',
    75: 'assets/images/75_75.jpeg',
    77: 'assets/images/blessed_virgin_77.jpeg',
    78: 'assets/images/78_78.jpeg',
    79: 'assets/images/blessed_virgin_79.jpeg',
    80: 'assets/images/80_80.jpeg',
    84: 'assets/images/84_84.jpeg',
    86: 'assets/images/86_86.jpeg',
    88: 'assets/images/88_88.jpeg',
    90: 'assets/images/90_90.jpeg',
    92: 'assets/images/92_92.jpeg',
    94: 'assets/images/94_94.jpeg',
    96: 'assets/images/96_96.jpeg',
    98: 'assets/images/98_98.jpeg',
    100: 'assets/images/100_100.jpeg',
    102: 'assets/images/102_102.jpeg',
    104: 'assets/images/104_104.jpeg',
    106: 'assets/images/106_106.jpeg',
    108: 'assets/images/108_108.jpeg',
    110: 'assets/images/110_110.jpeg',
    115: 'assets/images/115_115.jpeg',
  };

  static bool hasImageForPage(int page) =>
      _imageMap.containsKey(page) || _imageMap.containsKey(page - 1);

  static String? getImagePath(int page) {
    if (_imageMap.containsKey(page)) return _imageMap[page];
    if (_imageMap.containsKey(page - 1)) return _imageMap[page - 1];
    return null;
  }

  static Widget buildImage(int page, {BoxFit fit = BoxFit.contain}) {
    final path = getImagePath(page);
    if (path == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.md),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: Stack(
              children: [
                // Outer decorative frame
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(Spacing.lg),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4ECD8),
                    borderRadius: BorderRadius.circular(Spacing.radiusLg),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Top decorative bar
                      Row(
                        children: [
                          _ornament(),
                          Expanded(
                            child: Container(
                              height: 1,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    AppColors.accent.withValues(alpha: 0.4),
                                    AppColors.accent.withValues(alpha: 0.6),
                                    AppColors.accent.withValues(alpha: 0.4),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                          _ornament(),
                        ],
                      ),
                      const SizedBox(height: Spacing.lg),
                      // Image with gold border
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.accent.withValues(alpha: 0.5),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(Spacing.radiusSm),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withValues(alpha: 0.1),
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(Spacing.radiusSm - 1),
                          child: Image.asset(
                            path,
                            fit: fit,
                            errorBuilder: (_, _, _) =>
                                const SizedBox.shrink(),
                          ),
                        ),
                      ),
                      const SizedBox(height: Spacing.lg),
                      // Bottom decorative bar
                      Row(
                        children: [
                          _ornament(),
                          Expanded(
                            child: Container(
                              height: 1,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    AppColors.accent.withValues(alpha: 0.4),
                                    AppColors.accent.withValues(alpha: 0.6),
                                    AppColors.accent.withValues(alpha: 0.4),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                          _ornament(),
                        ],
                      ),
                    ],
                  ),
                ),
                // Page number badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.md,
                      vertical: Spacing.xxs + 1,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius:
                          BorderRadius.circular(Spacing.radiusFull),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'p. $page',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
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

  static Widget _ornament() {
    return Container(
      width: 6,
      height: 6,
      margin: const EdgeInsets.symmetric(horizontal: Spacing.sm),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.5),
        shape: BoxShape.circle,
      ),
    );
  }

  static List<int> getStationPages() {
    return [84, 86, 88, 90, 92, 94, 96, 98, 100, 102, 104, 106, 108, 110];
  }
}

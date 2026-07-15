import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  // Font families from design spec
  static String get headingFont => GoogleFonts.playfairDisplay().fontFamily!;
  static String get bodyFont => GoogleFonts.lora().fontFamily!;
  static String get uiFont => GoogleFonts.poppins().fontFamily!;

  // -- Headings (Playfair Display) --
  static TextStyle heading1 = GoogleFonts.playfairDisplay(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.3,
  );

  static TextStyle heading2 = GoogleFonts.playfairDisplay(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.2,
  );

  static TextStyle heading3 = GoogleFonts.playfairDisplay(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static TextStyle heading4 = GoogleFonts.playfairDisplay(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  static TextStyle heading5 = GoogleFonts.playfairDisplay(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // -- Body (Lora) --
  static TextStyle bodyLarge = GoogleFonts.lora(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.6,
  );

  static TextStyle bodyMedium = GoogleFonts.lora(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static TextStyle bodySmall = GoogleFonts.lora(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.4,
  );

  // -- Reader (Lora) --
  static TextStyle readerText = GoogleFonts.lora(
    fontSize: 18,
    fontWeight: FontWeight.normal,
    height: 1.7,
    letterSpacing: 0.2,
  );

  static TextStyle readerHeading = GoogleFonts.playfairDisplay(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.2,
  );

  // -- UI Labels (Poppins) --
  static TextStyle labelLarge = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  static TextStyle labelSmall = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.5,
  );

  // -- Caption (Poppins) --
  static TextStyle caption = GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.normal,
    height: 1.3,
    letterSpacing: 0.3,
  );

  // -- Subtitle (Lora) --
  static TextStyle subtitle = GoogleFonts.lora(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.4,
  );
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// AutiCare Typography
///
/// Web app uses: font-family: 'Inter', system-ui, sans-serif
/// Weights used: 300, 400, 500, 600, 700, 800, 900
///
/// Mapped to Flutter TextTheme using google_fonts package.
/// Font sizes follow the web's Tailwind scale:
///   text-xs  = 12px
///   text-sm  = 14px
///   text-base= 16px
///   text-lg  = 18px
///   text-xl  = 20px
///   text-2xl = 24px
///   text-3xl = 30px
///   text-4xl = 36px
abstract class AppTypography {
  static TextTheme get textTheme => GoogleFonts.interTextTheme().copyWith(
        // Display (large headings)
        displayLarge: GoogleFonts.inter(
          fontSize: 36,
          fontWeight: FontWeight.w800, // font-extrabold
          letterSpacing: -0.5,
          height: 1.1,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
          height: 1.15,
        ),
        displaySmall: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          height: 1.2,
        ),

        // Headline (section titles, card headers)
        headlineLarge: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
          height: 1.25,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600, // font-semibold
          letterSpacing: -0.1,
          height: 1.3,
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          height: 1.35,
        ),

        // Title (list items, labels)
        titleLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w500, // font-medium
          height: 1.45,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.45,
        ),

        // Body
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400, // font-normal
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),

        // Label (buttons, badges, chips)
        labelLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600, // font-semibold – used on buttons
          letterSpacing: 0,
          height: 1.25,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.25,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 1.25,
        ),
      );
}

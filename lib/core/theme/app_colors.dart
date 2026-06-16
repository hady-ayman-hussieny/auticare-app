import 'package:flutter/material.dart';

/// AutiCare Design System – Colors
///
/// Extracted 1-to-1 from the web app's CSS variables (index.css)
/// and Tailwind config (tailwind.config.ts).
///
/// Light mode uses the warm amber/orange palette.
/// Dark mode switches to the cool sky-blue palette.
abstract class AppColors {
  // ── CSS Variable tokens (Light Mode) ─────────────────────────────────────
  static const Color bgLight = Color(0xFFFDF8F3); // --bg
  static const Color bgSecondaryLight = Color(0xFFF5EDE2); // --bg-secondary
  static const Color surfaceLight = Color(0xFFFFFAF5); // --surface (opaque)
  static const Color surfaceStrongLight = Color(0xFFFFFFFF); // --surface-strong
  static const Color borderLight = Color(0x33B48C64); // --border (~20% opacity)
  static const Color textLight = Color(0xFF1A1410); // --text
  static const Color mutedLight = Color(0xFF7A6A5A); // --muted
  static const Color accentLight = Color(0xFFE07C2E); // --accent
  static const Color accentStrongLight = Color(0xFFC4621A); // --accent-strong

  // ── CSS Variable tokens (Dark Mode) ──────────────────────────────────────
  static const Color bgDark = Color(0xFF020617); // --bg
  static const Color bgSecondaryDark = Color(0xFF0F172A); // --bg-secondary
  static const Color surfaceDark = Color(0xFF0F172A); // --surface (opaque)
  static const Color surfaceStrongDark = Color(0xFF0F172A); // --surface-strong
  static const Color borderDark = Color(0x2E94A3B8); // --border (~18% opacity)
  static const Color textDark = Color(0xFFE2E8F0); // --text
  static const Color mutedDark = Color(0xFF94A3B8); // --muted
  static const Color accentDark = Color(0xFF38BDF8); // --accent (sky-400)
  static const Color accentStrongDark = Color(0xFF0EA5E9); // --accent-strong (sky-500)

  // ── Custom Slate palette (Tailwind override – warm tones) ─────────────────
  static const Color slate50 = Color(0xFFFFF8F0);
  static const Color slate100 = Color(0xFFF6F1E8);
  static const Color slate200 = Color(0xFFEADBC8);
  static const Color slate300 = Color(0xFFD9C7B0);
  static const Color slate400 = Color(0xFFBFA68E);
  static const Color slate500 = Color(0xFF9E8670);
  static const Color slate600 = Color(0xFF7E6855);
  static const Color slate700 = Color(0xFF5F4B3C);
  static const Color slate800 = Color(0xFF453327);
  static const Color slate900 = Color(0xFF2C1E14);
  static const Color slate950 = Color(0xFF1A1008);

  // ── Orange palette ────────────────────────────────────────────────────────
  static const Color orange50 = Color(0xFFFEF5F0);
  static const Color orange100 = Color(0xFFFCE8DF);
  static const Color orange200 = Color(0xFFFAD1BE);
  static const Color orange300 = Color(0xFFF6B39A);
  static const Color orange400 = Color(0xFFF08968);
  static const Color orange500 = Color(0xFFD97706); // amber-600 ≈ primary accent
  static const Color orange600 = Color(0xFFC05805);
  static const Color orange700 = Color(0xFF9D3D04);

  // ── Amber (used in primary button gradient) ───────────────────────────────
  static const Color amber400 = Color(0xFFFBBF24);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber600 = Color(0xFFD97706);

  // ── Primary palette (sky-blue, used as primary in dark mode + scale) ──────
  static const Color primary50 = Color(0xFFF0F9FF);
  static const Color primary100 = Color(0xFFE0F2FE);
  static const Color primary200 = Color(0xFFBAE6FD);
  static const Color primary300 = Color(0xFF7DD3FC);
  static const Color primary400 = Color(0xFF38BDF8);
  static const Color primary500 = Color(0xFF0EA5E9);
  static const Color primary600 = Color(0xFF0284C7);
  static const Color primary700 = Color(0xFF0369A1);
  static const Color primary800 = Color(0xFF075985);
  static const Color primary900 = Color(0xFF0C3D66);

  // ── Secondary palette (purple) ────────────────────────────────────────────
  static const Color secondary50 = Color(0xFFFAF5FF);
  static const Color secondary400 = Color(0xFFC084FC);
  static const Color secondary500 = Color(0xFFA855F7);
  static const Color secondary600 = Color(0xFF9333EA);
  static const Color secondary700 = Color(0xFF7E22CE);

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color success500 = Color(0xFF22C55E);
  static const Color success600 = Color(0xFF16A34A);
  static const Color warning500 = Color(0xFFEAB308);
  static const Color warning600 = Color(0xFFCA8A04);
  static const Color danger500 = Color(0xFFEF4444);
  static const Color danger600 = Color(0xFFDC2626);

  // ── Neutral (standard gray for fallbacks) ────────────────────────────────
  static const Color neutral100 = Color(0xFFF3F4F6);
  static const Color neutral200 = Color(0xFFE5E7EB);
  static const Color neutral300 = Color(0xFFD1D5DB);
  static const Color neutral400 = Color(0xFF9CA3AF);
  static const Color neutral500 = Color(0xFF6B7280);
  static const Color neutral600 = Color(0xFF4B5563);
  static const Color neutral700 = Color(0xFF374151);
  static const Color neutral800 = Color(0xFF1F2937);
  static const Color neutral900 = Color(0xFF111827);

  // ── Gradients (matching Button primary variant) ───────────────────────────
  /// Light mode primary button: amber-500 → orange-500 → orange-600
  static const LinearGradient primaryGradientLight = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFF97316), Color(0xFFEA580C)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Dark mode primary button: blue-600 → blue-500 → indigo-600
  static const LinearGradient primaryGradientDark = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF3B82F6), Color(0xFF4F46E5)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}

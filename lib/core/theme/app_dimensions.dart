import 'package:flutter/material.dart';

/// AutiCare Spacing & Dimension constants
///
/// Derived from the web app's Tailwind spacing + borderRadius config.
/// All values in logical pixels.
abstract class AppDimensions {
  // ── Spacing (Tailwind p-N scale, 1 unit = 4px) ────────────────────────────
  static const double sp0 = 0;
  static const double sp1 = 4;
  static const double sp2 = 8;
  static const double sp3 = 12;
  static const double sp4 = 16;
  static const double sp5 = 20;
  static const double sp6 = 24;
  static const double sp8 = 32;
  static const double sp10 = 40;
  static const double sp12 = 48;
  static const double sp16 = 64;

  // ── Screen padding ────────────────────────────────────────────────────────
  // Web: main content padding — p-5 md:p-8 lg:p-10
  static const double screenPaddingH = sp5; // 20px (mobile)
  static const double screenPaddingV = sp5; // 20px (mobile)

  // ── Border radii (matches tailwind borderRadius config) ───────────────────
  static const double radiusSm = 8.0; // rounded-lg  = 0.5rem
  static const double radiusMd = 12.0; // rounded-xl  = 0.75rem
  static const double radiusLg = 16.0; // rounded-2xl = 1rem
  static const double radiusXl = 24.0; // rounded-3xl = 1.5rem
  static const double radiusFull = 9999; // rounded-full (pill/circle)

  // ── Component-specific ────────────────────────────────────────────────────
  static const double cardRadius = radiusXl; // 24 — web Card uses rounded-3xl
  static const double inputRadius = radiusLg; // 16 — web Input uses rounded-2xl
  static const double buttonRadius = radiusFull; // pill — web Button uses rounded-full
  static const double badgeRadius = radiusFull;
  static const double navItemRadius = radiusLg; // sidebar nav links: rounded-2xl
  static const double avatarRadius = radiusFull;

  // ── AppBar / TopNav ───────────────────────────────────────────────────────
  static const double appBarHeight = 64.0; // web TopNav h-16 = 64px

  // ── Button min heights ────────────────────────────────────────────────────
  // Web: all button sizes have min-h-[44px]
  static const double buttonMinHeight = 48.0;
  static const double inputMinHeight = 48.0;

  // ── Card padding ──────────────────────────────────────────────────────────
  // Web Card: p-6 = 24px
  static const EdgeInsets cardPadding = EdgeInsets.all(sp6);

  // ── Section gap ───────────────────────────────────────────────────────────
  static const double sectionGap = sp6; // 24px between sections

  // ── Drawer width ──────────────────────────────────────────────────────────
  // Web Sidebar: max-w-xs sm:max-w-sm md:w-72
  static const double drawerWidth = 288.0; // 72 * 4 = 288px (md:w-72)

  // ── Avatar sizes ──────────────────────────────────────────────────────────
  static const double avatarSm = 32.0;
  static const double avatarMd = 40.0;
  static const double avatarLg = 48.0;
  static const double avatarXl = 64.0;

  // ── Bottom Navigation height ──────────────────────────────────────────────
  static const double bottomNavHeight = 64.0;
}

/// Reusable BoxDecoration presets matching web components
class AppDecorations {
  AppDecorations._();

  // ── Card (Light) ──────────────────────────────────────────────────────────
  static BoxDecoration cardLight = BoxDecoration(
    color: const Color(0xFFFFFFFF),
    borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
    border: Border.all(color: const Color(0xFFEADBC8), width: 1), // slate-200
    boxShadow: [
      BoxShadow(
        color: const Color(0xFFEADBC8).withValues(alpha: 0.4),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ],
  );

  // ── Card (Dark) ───────────────────────────────────────────────────────────
  static BoxDecoration cardDark = BoxDecoration(
    color: const Color(0xD90F172A), // slate-950/85
    borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
    border: Border.all(
      color: Colors.white.withValues(alpha: 0.10),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF020617).withValues(alpha: 0.4),
        blurRadius: 40,
        offset: const Offset(0, 8),
      ),
    ],
  );

  // ── Primary Button Shadow (Light) ─────────────────────────────────────────
  // Web: shadow-[0_8px_20px_-6px_rgba(217,119,6,0.5)]
  static List<BoxShadow> primaryButtonShadowLight = [
    BoxShadow(
      color: const Color(0xFFD97706).withValues(alpha: 0.5),
      blurRadius: 20,
      spreadRadius: -6,
      offset: const Offset(0, 8),
    ),
  ];

  // ── Primary Button Shadow (Dark) ──────────────────────────────────────────
  // Web: shadow-[0_0_15px_rgba(59,130,246,0.4)]
  static List<BoxShadow> primaryButtonShadowDark = [
    BoxShadow(
      color: const Color(0xFF3B82F6).withValues(alpha: 0.4),
      blurRadius: 15,
      spreadRadius: 0,
      offset: Offset.zero,
    ),
  ];

  // ── Glassmorphism card (sidebar user card) ────────────────────────────────
  // Web: rounded-3xl border border-white/10 bg-white/5 backdrop-blur-xl
  static BoxDecoration glassCard = BoxDecoration(
    color: Colors.white.withValues(alpha: 0.05),
    borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
    border: Border.all(
      color: Colors.white.withValues(alpha: 0.10),
      width: 1,
    ),
  );

  // ── Auth hero overlay gradient ────────────────────────────────────────────
  static const BoxDecoration authHeroOverlay = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xCC020617), // slate-950/80
        Color(0x800F172A), // slate-900/50
        Color(0x991E3A5F), // blue-950/60
      ],
    ),
  );
}

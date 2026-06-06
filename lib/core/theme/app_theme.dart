import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auticare/core/theme/app_colors.dart';
import 'package:auticare/core/theme/app_typography.dart';

/// AutiCare global ThemeData
///
/// Provides [lightTheme] and [darkTheme] built strictly from the web app's
/// design tokens. Every component style (buttons, inputs, cards, chips,
/// navigation, dialogs) is mapped from the web's Tailwind + CSS variables.
class AppTheme {
  AppTheme._();

  // ── Shared shape constants (from borderRadius in tailwind.config) ─────────
  static const double _radiusCard = 24.0; // rounded-3xl  = 1.5rem
  static const double _radiusInput = 16.0; // rounded-2xl  = 1rem
  static const double _radiusTile = 16.0; // rounded-2xl

  // ── Light Theme ──────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);
    final tt = AppTypography.textTheme.apply(
      bodyColor: AppColors.textLight,
      displayColor: AppColors.textLight,
    );

    return base.copyWith(
      brightness: Brightness.light,

      // ── Scaffold / Background ──────────────────────────────────────────
      scaffoldBackgroundColor: AppColors.bgLight,

      // ── Color Scheme ───────────────────────────────────────────────────
      colorScheme: const ColorScheme.light(
        // Primary = orange accent (light mode)
        primary: AppColors.accentLight, // #E07C2E
        onPrimary: Colors.white,
        primaryContainer: AppColors.orange100,
        onPrimaryContainer: AppColors.orange700,

        // Secondary = sky-blue (used in info/status contexts)
        secondary: AppColors.primary500,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.primary100,
        onSecondaryContainer: AppColors.primary800,

        // Tertiary = purple
        tertiary: AppColors.secondary500,
        onTertiary: Colors.white,

        // Surface
        surface: AppColors.surfaceStrongLight,
        onSurface: AppColors.textLight,
        surfaceContainerHighest: AppColors.bgSecondaryLight,

        // Error
        error: AppColors.danger500,
        onError: Colors.white,

        // Outline
        outline: AppColors.borderLight,
        outlineVariant: AppColors.slate200,
      ),

      // ── Typography ────────────────────────────────────────────────────
      textTheme: tt,
      primaryTextTheme: tt,

      // ── AppBar ────────────────────────────────────────────────────────
      // Web TopNav: bg-white/80 backdrop-blur border-b border-slate-200 h-16
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceStrongLight.withValues(alpha: 0.92),
        foregroundColor: AppColors.textLight,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        shadowColor: AppColors.borderLight,
        centerTitle: false,
        titleTextStyle: AppTypography.textTheme.titleLarge?.copyWith(
          color: AppColors.textLight,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: AppColors.textLight, size: 24),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),

      // ── Drawer / Sidebar ──────────────────────────────────────────────
      // Web Sidebar: bg-white border-r border-slate-200
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.surfaceStrongLight,
        scrimColor: Color(0x33000000), // bg-black/20
        elevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(0),
            bottomRight: Radius.circular(0),
          ),
        ),
      ),

      // ── Card ──────────────────────────────────────────────────────────
      // Web Card: rounded-3xl border border-slate-200 bg-white shadow-lg p-6
      cardTheme: CardThemeData(
        color: AppColors.surfaceStrongLight,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: AppColors.slate200,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radiusCard),
          side: const BorderSide(color: AppColors.slate200, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── Elevated Button (primary) ─────────────────────────────────────
      // Web primary Button: gradient amber→orange, rounded-full, font-semibold
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColors.orange300;
            }
            return AppColors.accentLight; // fallback; gradient applied in widget
          }),
          foregroundColor: WidgetStateProperty.all(Colors.white),
          overlayColor: WidgetStateProperty.all(Colors.white.withValues(alpha: 0.1)),
          elevation: WidgetStateProperty.all(0),
          shadowColor: WidgetStateProperty.all(Colors.transparent),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
          minimumSize: WidgetStateProperty.all(const Size(0, 48)),
          shape: WidgetStateProperty.all(
            const StadiumBorder(), // rounded-full
          ),
          textStyle: WidgetStateProperty.all(
            AppTypography.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          animationDuration: const Duration(milliseconds: 200),
        ),
      ),

      // ── Outlined Button (outline variant) ────────────────────────────
      // Web outline: border-2 border-slate-300 text-slate-800 hover:bg-slate-100
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(AppColors.slate700),
          backgroundColor: WidgetStateProperty.all(Colors.transparent),
          overlayColor: WidgetStateProperty.all(AppColors.slate100.withValues(alpha: 0.6)),
          side: WidgetStateProperty.resolveWith((states) {
            return const BorderSide(color: AppColors.slate300, width: 2);
          }),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
          minimumSize: WidgetStateProperty.all(const Size(0, 48)),
          shape: WidgetStateProperty.all(const StadiumBorder()),
          textStyle: WidgetStateProperty.all(
            AppTypography.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),

      // ── Text Button (ghost variant) ───────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(AppColors.slate700),
          overlayColor: WidgetStateProperty.all(AppColors.slate100.withValues(alpha: 0.6)),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          minimumSize: WidgetStateProperty.all(const Size(0, 44)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(_radiusTile)),
          ),
          textStyle: WidgetStateProperty.all(
            AppTypography.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
      ),

      // ── Input / TextField ─────────────────────────────────────────────
      // Web Input: rounded-2xl border border-slate-300 bg-white px-4 py-3
      //            focus:ring-orange-500 focus:border-orange-500 text-slate-900
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceStrongLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        constraints: const BoxConstraints(minHeight: 48),

        // Label
        labelStyle: AppTypography.textTheme.bodyMedium?.copyWith(
          color: AppColors.slate600,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: AppTypography.textTheme.bodySmall?.copyWith(
          color: AppColors.accentLight,
          fontWeight: FontWeight.w500,
        ),

        // Hint
        hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
          color: AppColors.slate400,
        ),

        // Borders
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radiusInput),
          borderSide: const BorderSide(color: AppColors.slate300, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radiusInput),
          borderSide: const BorderSide(color: AppColors.slate300, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radiusInput),
          borderSide: const BorderSide(color: AppColors.accentLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radiusInput),
          borderSide: const BorderSide(color: AppColors.danger500, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radiusInput),
          borderSide: const BorderSide(color: AppColors.danger500, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radiusInput),
          borderSide: const BorderSide(color: AppColors.slate200, width: 1.5),
        ),

        errorStyle: AppTypography.textTheme.bodySmall?.copyWith(
          color: AppColors.danger500,
        ),
        helperStyle: AppTypography.textTheme.bodySmall?.copyWith(
          color: AppColors.slate600,
        ),

        prefixIconColor: AppColors.slate500,
        suffixIconColor: AppColors.slate500,
      ),

      // ── Chip / Badge ──────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.neutral100,
        selectedColor: AppColors.orange100,
        labelStyle: AppTypography.textTheme.labelSmall?.copyWith(
          color: AppColors.neutral700,
          fontWeight: FontWeight.w500,
        ),
        shape: const StadiumBorder(
          side: BorderSide(color: AppColors.neutral200),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),

      // ── Divider ───────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.slate200,
        thickness: 1,
        space: 1,
      ),

      // ── List Tile ─────────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radiusTile),
        ),
        tileColor: Colors.transparent,
        selectedTileColor: AppColors.orange100,
        selectedColor: AppColors.orange700,
        iconColor: AppColors.slate500,
        textColor: AppColors.textLight,
        titleTextStyle: AppTypography.textTheme.titleMedium?.copyWith(
          color: AppColors.textLight,
        ),
        subtitleTextStyle: AppTypography.textTheme.bodySmall?.copyWith(
          color: AppColors.mutedLight,
        ),
      ),

      // ── Bottom Navigation ─────────────────────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceStrongLight,
        selectedItemColor: AppColors.accentLight,
        unselectedItemColor: AppColors.slate500,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
      ),

      // ── Navigation Bar (Material 3) ───────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceStrongLight,
        indicatorColor: AppColors.orange100,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.accentLight, size: 24);
          }
          return const IconThemeData(color: AppColors.slate500, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.accentLight,
            );
          }
          return const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: AppColors.slate500,
          );
        }),
        elevation: 8,
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),

      // ── Dialog ────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceStrongLight,
        elevation: 24,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radiusCard),
        ),
        titleTextStyle: AppTypography.textTheme.headlineSmall?.copyWith(
          color: AppColors.textLight,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: AppTypography.textTheme.bodyMedium?.copyWith(
          color: AppColors.mutedLight,
        ),
      ),

      // ── Snack Bar ─────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.slate900,
        contentTextStyle: AppTypography.textTheme.bodyMedium?.copyWith(
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // ── Progress Indicator ────────────────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.accentLight,
        linearTrackColor: AppColors.orange100,
      ),

      // ── Switch ────────────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.accentLight
              : AppColors.slate300;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.orange200
              : AppColors.slate200;
        }),
      ),

      // ── Checkbox ─────────────────────────────────────────────────────
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.accentLight
              : Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: AppColors.slate300, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      // ── Tab Bar ───────────────────────────────────────────────────────
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.accentLight,
        unselectedLabelColor: AppColors.slate500,
        indicatorColor: AppColors.accentLight,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: AppTypography.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTypography.textTheme.labelMedium,
        dividerColor: AppColors.slate200,
      ),
    );
  }

  // ── Dark Theme ───────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    final tt = AppTypography.textTheme.apply(
      bodyColor: AppColors.textDark,
      displayColor: AppColors.textDark,
    );

    return base.copyWith(
      brightness: Brightness.dark,

      scaffoldBackgroundColor: AppColors.bgDark,

      colorScheme: const ColorScheme.dark(
        primary: AppColors.accentDark, // sky-400
        onPrimary: Colors.white,
        primaryContainer: AppColors.primary800,
        onPrimaryContainer: AppColors.primary200,

        secondary: AppColors.secondary500,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.secondary700,
        onSecondaryContainer: AppColors.secondary50,

        surface: AppColors.surfaceDark,
        onSurface: AppColors.textDark,
        surfaceContainerHighest: AppColors.bgSecondaryDark,

        error: AppColors.danger500,
        onError: Colors.white,

        outline: AppColors.borderDark,
        outlineVariant: Color(0xFF1E293B), // slate-800 equivalent
      ),

      textTheme: tt,
      primaryTextTheme: tt,

      // ── AppBar (dark) ─────────────────────────────────────────────────
      // Web: bg-slate-950/80 border-slate-800/50 backdrop-blur text-slate-100
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF020617).withValues(alpha: 0.88), // slate-950/88
        foregroundColor: AppColors.textDark,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        shadowColor: AppColors.borderDark,
        centerTitle: false,
        titleTextStyle: AppTypography.textTheme.titleLarge?.copyWith(
          color: AppColors.textDark,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: AppColors.textDark, size: 24),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
        ),
      ),

      // ── Drawer (dark) ─────────────────────────────────────────────────
      drawerTheme: const DrawerThemeData(
        backgroundColor: Color(0xFF0F172A), // slate-950/95 ≈ bg-secondary-dark
        scrimColor: Color(0xB3020617), // bg-slate-950/70
        elevation: 16,
      ),

      // ── Card (dark) ───────────────────────────────────────────────────
      // Web: border-white/10 bg-slate-950/85 shadow-2xl text-slate-100
      cardTheme: CardThemeData(
        color: const Color(0xD90F172A), // slate-950/85
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: const Color(0xFF020617),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radiusCard),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.10), width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── Elevated Button (dark – blue gradient) ────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColors.primary800;
            }
            return AppColors.accentDark;
          }),
          foregroundColor: WidgetStateProperty.all(Colors.white),
          overlayColor: WidgetStateProperty.all(Colors.white.withValues(alpha: 0.1)),
          elevation: WidgetStateProperty.all(0),
          shadowColor: WidgetStateProperty.all(Colors.transparent),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
          minimumSize: WidgetStateProperty.all(const Size(0, 48)),
          shape: WidgetStateProperty.all(const StadiumBorder()),
          textStyle: WidgetStateProperty.all(
            AppTypography.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ),

      // ── Outlined Button (dark) ────────────────────────────────────────
      // Web: border-slate-600 text-white hover:bg-white/10
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(AppColors.textDark),
          backgroundColor: WidgetStateProperty.all(Colors.transparent),
          overlayColor: WidgetStateProperty.all(Colors.white.withValues(alpha: 0.08)),
          side: WidgetStateProperty.all(
            const BorderSide(color: AppColors.slate600, width: 2),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
          minimumSize: WidgetStateProperty.all(const Size(0, 48)),
          shape: WidgetStateProperty.all(const StadiumBorder()),
          textStyle: WidgetStateProperty.all(
            AppTypography.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ),

      // ── Text Button (dark ghost) ──────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(AppColors.textDark),
          overlayColor: WidgetStateProperty.all(Colors.white.withValues(alpha: 0.08)),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          minimumSize: WidgetStateProperty.all(const Size(0, 44)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(_radiusTile)),
          ),
          textStyle: WidgetStateProperty.all(
            AppTypography.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
      ),

      // ── Input (dark) ──────────────────────────────────────────────────
      // Web: bg-slate-950/90 text-slate-100 border-slate-700 focus:ring-blue-500
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xE6020617), // slate-950/90
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        constraints: const BoxConstraints(minHeight: 48),

        labelStyle: AppTypography.textTheme.bodyMedium?.copyWith(
          color: AppColors.slate400,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: AppTypography.textTheme.bodySmall?.copyWith(
          color: AppColors.accentDark,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
          color: AppColors.slate500,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radiusInput),
          borderSide: const BorderSide(color: Color(0xFF334155), width: 1.5), // slate-700
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radiusInput),
          borderSide: const BorderSide(color: Color(0xFF334155), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radiusInput),
          borderSide: const BorderSide(color: AppColors.accentDark, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radiusInput),
          borderSide: const BorderSide(color: AppColors.danger500, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radiusInput),
          borderSide: const BorderSide(color: AppColors.danger500, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radiusInput),
          borderSide: const BorderSide(color: Color(0xFF1E293B), width: 1.5),
        ),

        errorStyle: AppTypography.textTheme.bodySmall?.copyWith(
          color: const Color(0xFFF87171), // red-400
        ),
        helperStyle: AppTypography.textTheme.bodySmall?.copyWith(
          color: AppColors.slate400,
        ),

        prefixIconColor: AppColors.slate400,
        suffixIconColor: AppColors.slate400,
      ),

      // ── Chip (dark) ───────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.08),
        selectedColor: AppColors.primary700,
        labelStyle: AppTypography.textTheme.labelSmall?.copyWith(
          color: AppColors.textDark,
          fontWeight: FontWeight.w500,
        ),
        shape: StadiumBorder(
          side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),

      // ── Divider (dark) ────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: Colors.white.withValues(alpha: 0.10),
        thickness: 1,
        space: 1,
      ),

      // ── List Tile (dark) ──────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radiusTile),
        ),
        tileColor: Colors.transparent,
        selectedTileColor: Colors.white.withValues(alpha: 0.08),
        selectedColor: AppColors.textDark,
        iconColor: AppColors.slate400,
        textColor: AppColors.textDark,
        titleTextStyle: AppTypography.textTheme.titleMedium?.copyWith(
          color: AppColors.textDark,
        ),
        subtitleTextStyle: AppTypography.textTheme.bodySmall?.copyWith(
          color: AppColors.mutedDark,
        ),
      ),

      // ── Bottom Navigation (dark) ──────────────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.bgSecondaryDark,
        selectedItemColor: AppColors.accentDark,
        unselectedItemColor: AppColors.mutedDark,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
      ),

      // ── Navigation Bar M3 (dark) ──────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.bgSecondaryDark,
        indicatorColor: Colors.white.withValues(alpha: 0.08),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.accentDark, size: 24);
          }
          return const IconThemeData(color: AppColors.mutedDark, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.accentDark,
            );
          }
          return const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: AppColors.mutedDark,
          );
        }),
        elevation: 8,
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),

      // ── Dialog (dark) ─────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 24,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radiusCard),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
        ),
        titleTextStyle: AppTypography.textTheme.headlineSmall?.copyWith(
          color: AppColors.textDark,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: AppTypography.textTheme.bodyMedium?.copyWith(
          color: AppColors.mutedDark,
        ),
      ),

      // ── Snack Bar (dark) ──────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.bgSecondaryDark,
        contentTextStyle: AppTypography.textTheme.bodyMedium?.copyWith(
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // ── Progress Indicator (dark) ─────────────────────────────────────
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.accentDark,
        linearTrackColor: Colors.white.withValues(alpha: 0.10),
      ),

      // ── Switch (dark) ─────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.accentDark
              : AppColors.slate500;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.primary800
              : const Color(0xFF1E293B);
        }),
      ),

      // ── Checkbox (dark) ───────────────────────────────────────────────
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.accentDark
              : Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: Color(0xFF334155), width: 2), // slate-700
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      // ── Tab Bar (dark) ────────────────────────────────────────────────
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.accentDark,
        unselectedLabelColor: AppColors.mutedDark,
        indicatorColor: AppColors.accentDark,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: AppTypography.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTypography.textTheme.labelMedium,
        dividerColor: Colors.white.withValues(alpha: 0.10),
      ),
    );
  }
}

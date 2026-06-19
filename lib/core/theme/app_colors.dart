import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Brand
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF8B83FF);
  static const Color primaryDark = Color(0xFF4A42E8);
  static const Color primaryGlow = Color(0x336C63FF);

  // Secondary
  static const Color secondary = Color(0xFF00D4FF);
  static const Color secondaryLight = Color(0xFF40E0FF);
  static const Color secondaryDark = Color(0xFF00A8CC);

  // Accent
  static const Color accent = Color(0xFFFF6B6B);
  static const Color accentGold = Color(0xFFFFB347);
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color accentTeal = Color(0xFF00BFA5);

  // Background Hierarchy
  static const Color background = Color(0xFF0A0A0F);
  static const Color backgroundSecondary = Color(0xFF12121A);
  static const Color backgroundTertiary = Color(0xFF1A1A26);
  static const Color backgroundCard = Color(0xFF1E1E2E);
  static const Color backgroundElevated = Color(0xFF252535);

  // Surface Colors (Glassmorphism)
  static const Color surfaceGlass = Color(0x1AFFFFFF);
  static const Color surfaceGlassLight = Color(0x26FFFFFF);
  static const Color surfaceGlassDark = Color(0x0DFFFFFF);
  static const Color surfaceBorder = Color(0x33FFFFFF);
  static const Color surfaceBorderLight = Color(0x1AFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0C8);
  static const Color textTertiary = Color(0xFF6B6B85);
  static const Color textDisabled = Color(0xFF3A3A50);
  static const Color textHint = Color(0xFF505068);

  // Status
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);
  static const Color successBackground = Color(0x1A4CAF50);
  static const Color warning = Color(0xFFFFB347);
  static const Color warningLight = Color(0xFFFFCC80);
  static const Color warningBackground = Color(0x1AFFB347);
  static const Color error = Color(0xFFFF6B6B);
  static const Color errorLight = Color(0xFFFF8A80);
  static const Color errorBackground = Color(0x1AFF6B6B);
  static const Color info = Color(0xFF00D4FF);
  static const Color infoBackground = Color(0x1A00D4FF);

  // ATS Score Colors
  static const Color atsExcellent = Color(0xFF4CAF50);
  static const Color atsGood = Color(0xFF8BC34A);
  static const Color atsAverage = Color(0xFFFFB347);
  static const Color atsPoor = Color(0xFFFF7043);
  static const Color atsCritical = Color(0xFFFF6B6B);

  // Gradient Collections
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF9C88FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF00D4FF), Color(0xFF0099CC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFFFFB347), Color(0xFFFF6B6B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF0A0A0F), Color(0xFF12121A), Color(0xFF1A1A26)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1E1E2E), Color(0xFF252535)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [Color(0x26FFFFFF), Color(0x0DFFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF00D4FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF4CAF50), Color(0xFF00BFA5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const RadialGradient glowGradient = RadialGradient(
    colors: [Color(0x336C63FF), Color(0x006C63FF)],
    radius: 1.0,
  );

  // Shadows
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.4),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: primary.withValues(alpha: 0.1),
      blurRadius: 40,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get primaryGlowShadow => [
    BoxShadow(
      color: primary.withValues(alpha: 0.4),
      blurRadius: 30,
      spreadRadius: -5,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> get glassShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.3),
      blurRadius: 15,
      offset: const Offset(0, 5),
    ),
    BoxShadow(
      color: Colors.white.withValues(alpha: 0.05),
      blurRadius: 1,
      offset: const Offset(0, 1),
      spreadRadius: -1,
    ),
  ];

  static Color atsScoreColor(int score) {
    if (score >= 85) return atsExcellent;
    if (score >= 70) return atsGood;
    if (score >= 55) return atsAverage;
    if (score >= 40) return atsPoor;
    return atsCritical;
  }
}

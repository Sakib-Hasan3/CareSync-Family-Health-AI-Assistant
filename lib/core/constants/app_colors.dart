import 'package:flutter/material.dart';

/// App-wide color constants following Material 3 design
class AppColors {
  AppColors._();

  // Primary colors
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color primaryVariant = Color(0xFF1976D2);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Secondary colors
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color onSecondary = Color(0xFF000000);

  // Background colors
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF000000);

  // Error colors
  static const Color errorColor = Color(0xFFB00020);
  static const Color onError = Color(0xFFFFFFFF);

  // Health-specific colors
  static const Color healthGreen = Color(0xFF4CAF50);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color criticalRed = Color(0xFFF44336);
  static const Color medicationBlue = Color(0xFF2196F3);
  static const Color vitalsGreen = Color(0xFF4CAF50);

  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);

  // Card and border colors
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color borderColor = Color(0xFFE0E0E0);
  static const Color dividerColor = Color(0xFFBDBDBD);

  // Emergency colors
  static const Color emergencyRed = Color(0xFFD32F2F);
  static const Color emergencyBackground = Color(0xFFFFEBEE);
}

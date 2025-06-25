// lib/utils/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryMaroon = Color(0xFF800000); // Dark maroon (replaces spotifyBlack)
  static const Color accentPink = Color(0xFFFFC1CC); // Light pink (replaces spotifyGreen accent)
  static const Color backgroundLight = Color(0xFFFFFFFF); // White background
  static const Color error = Color(0xFFD32F2F); // Red for errors
  static const Color textDark = Color(0xFF333333); // Dark text
  static const Color textLight = Color(0xFFB3B3B3); // Light grey text (replaces spotifyOffWhite)
  static const Color surfaceDark = Color(0xFF282828); // Dark surface (replaces spotifyDarkGrey)
  static const Color surfaceLight = Color(0xFF535353); // Light grey (replaces spotifyLightGrey)

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryMaroon, accentPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color primary = primaryMaroon; // Primary color
  static const Color surface = backgroundLight; // Surface color
  static const Color inputFill = Color(0xFFF5F5F5); // Light grey for inputs
}
import 'package:flutter/material.dart';

class AppColors {
  static const Color primary   = Color(0xFF7B2FF7);
  static const Color secondary = Color(0xFFF107A3);
  static const Color bg        = Color(0xFFF5F0FF);
  static const Color bgDark    = Color(0xFF1A1A2E);
  static const Color card      = Colors.white;
  static const Color cardDark  = Color(0xFF16213E);

  static const LinearGradient mainGradient = LinearGradient(
    colors: [Color(0xFF7B2FF7), Color(0xFFF107A3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Color groupColor(String groupe) {
    switch (groupe) {
      case 'G1': return const Color(0xFF7B2FF7);
      case 'G2': return const Color(0xFFF107A3);
      case 'G3': return const Color(0xFF00BCD4);
      default:   return const Color(0xFFFF6B35);
    }
  }
}
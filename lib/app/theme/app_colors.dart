import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF6C4DFF);
  static const Color primaryDark = Color(0xFF4F3AD7);
  static const Color accentPink = Color(0xFFEF6FFF);
  static const Color softBackground = Color(0xFFF6F7FB);
  static const Color cardStroke = Color(0xFFE6E8F0);

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF6C4DFF), Color(0xFF7B63FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

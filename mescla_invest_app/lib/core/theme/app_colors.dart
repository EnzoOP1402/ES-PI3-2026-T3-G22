// HISTÓRICO: 02/11/2026 — Gabriela Sichiroli Ferrari: harmonização visual e segurança de navegação.
import 'package:flutter/material.dart';

/// Tokens do MesclaInvest: hierarquia de cores inspirada na organização HorseLife,
/// preservando a identidade roxa e rosa original do produto.
abstract final class AppColors {
  static const Color primary = Color(0xFF353988);
  static const Color primaryDark = Color(0xFF252960);
  static const Color accent = Color(0xFFDB0065);
  static const Color background = Color(0xFFF5F6FA);
  static const Color homeBackground = background;
  static const Color surface = Colors.white;
  static const Color surfaceAlt = Color(0xFFEBEDF7);
  static const Color border = Color(0xFFDDE1EE);
  static const Color textPrimary = Color(0xFF1C2540);
  static const Color textSecondary = Color(0xFF5B647A);
  static const Color success = Color(0xFF17845C);
  static const Color error = Color(0xFFC23B52);
  static const Color legacyPrimary = Color(0xFF2F3192);
  static const Color legacyAccent = Color(0xFFE4007C);
}

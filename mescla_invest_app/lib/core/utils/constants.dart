/* Autor: Enzo Olivato Pazian - 25001654 */

// HISTÓRICO DE ALTERAÇÕES
// 02/11/2026 — Gabriela Sichiroli Ferrari (RA 25013763): refatoração estrutural e correções de manutenção.
import 'package:flutter/material.dart';
import 'package:mescla_invest_app/core/theme/app_colors.dart';

// Cores
const Color primaryColor = AppColors.legacyPrimary;
const Color accentColor = AppColors.legacyAccent;
const Color backgroundColor = AppColors.background;

// Sombra padrão para cards, inputs, botões, etc
const BoxShadow fieldShadow = BoxShadow(
  color: Color(0x22000000),
  spreadRadius: 0,
  blurRadius: 2,
  offset: Offset(0, 0),
);

// Espaçamento horizontal entre os filtros
const SizedBox filterSpacing = SizedBox(width: 8,);


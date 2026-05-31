/* Autor: Livia Lucizano */

// Classe do Token refatorada para receber as coordenadas da biblioteca fl_chart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TokenDashboard {
  final String nome;
  final String variacao;
  final bool isPositive;
  final Color corGrafico;
  final List<FlSpot> valores;

  TokenDashboard({
    required this.nome,
    required this.variacao,
    required this.isPositive,
    required this.corGrafico,
    required this.valores,
  });
}
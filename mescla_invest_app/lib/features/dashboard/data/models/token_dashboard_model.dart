/* Autor: Livia Lucizano RA:25017514*/

// Classe do Token refatorada para receber as coordenadas da biblioteca fl_chart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

// Classe modelo usada para representar um token no dashboard
class TokenDashboard {
  // Nome do token/startup exibido no dashboard
  final String nome;

  // Texto da variação do token, por exemplo: "+2,5%" ou "-1,0%"
  final String variacao;

  // Indica se a variação do token é positiva ou negativa
  final bool isPositive;

  // Cor usada para desenhar o gráfico do token
  final Color corGrafico;

  // Lista de pontos do gráfico, usando coordenadas da biblioteca fl_chart
  final List<FlSpot> valores;

  // Construtor que exige todos os dados necessários do token
  TokenDashboard({
    required this.nome,
    required this.variacao,
    required this.isPositive,
    required this.corGrafico,
    required this.valores,
  });
}
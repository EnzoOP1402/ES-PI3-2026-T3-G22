/* Autor: Livia Lucizano */

// Widget componentizado do fl_chart com toda a estilização e exibição dos eixos
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Widget responsável por exibir um gráfico de linha no dashboard
class AppLineChart extends StatelessWidget {
  // Lista de pontos que serão desenhados no gráfico
  final List<FlSpot> spots;

  // Cor principal usada na linha do gráfico
  final Color corGrafico;

  // Indica se o gráfico está mostrando dados por hora ou por data
  final bool isHourly;

  const AppLineChart({
    super.key,
    required this.spots,
    required this.corGrafico,
    required this.isHourly,
  });

  @override
  Widget build(BuildContext context) {
    // Se não houver pontos, não exibe nada
    if (spots.isEmpty) return const SizedBox();

    return LineChart(
      LineChartData(
        // Configuração das linhas de grade do gráfico
        gridData: const FlGridData(
          show: true,
          drawVerticalLine: false,
        ),

        // Configuração dos títulos e valores dos eixos
        titlesData: FlTitlesData(
          show: true,

          // Remove os títulos do lado direito
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),

          // Remove os títulos do topo
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),

          // Eixo Y, responsável por exibir os preços
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,

              // Define como os valores do eixo Y serão exibidos
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(2),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),

          // Eixo X, responsável por exibir datas ou horas
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,

              // Define o intervalo entre os textos do eixo X
              interval: _getInterval(spots),

              // Define como os valores do eixo X serão exibidos
              getTitlesWidget: (value, meta) {
                final date =
                    DateTime.fromMillisecondsSinceEpoch(value.toInt());

                // Mostra hora ou data conforme o período selecionado
                final text = isHourly
                    ? DateFormat('HH:mm').format(date)
                    : DateFormat('dd/MM').format(date);

                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    text,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Remove as bordas externas do gráfico
        borderData: FlBorderData(show: false),

        // Configuração da linha exibida no gráfico
        lineBarsData: [
          LineChartBarData(
            // Pontos usados para desenhar a linha
            spots: spots,

            // Deixa a linha suavizada
            isCurved: true,

            // Cor da linha
            color: corGrafico,

            // Espessura da linha
            barWidth: 2,

            // Deixa as pontas da linha arredondadas
            isStrokeCapRound: true,

            // Oculta os pontos individuais do gráfico
            dotData: const FlDotData(show: false),

            // Área preenchida abaixo da linha
            belowBarData: BarAreaData(
              show: true,

              // Gradiente sutil abaixo do gráfico
              gradient: LinearGradient(
                colors: [
                  corGrafico.withOpacity(0.3),
                  corGrafico.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Calcula um intervalo para evitar sobreposição dos textos no eixo X
  double _getInterval(List<FlSpot> spots) {
    // Caso exista apenas um ponto, usa intervalo padrão
    if (spots.length <= 1) return 1;

    final minX = spots.first.x;
    final maxX = spots.last.x;

    // Divide o eixo X em aproximadamente quatro partes
    return (maxX - minX) / 4;
  }
}
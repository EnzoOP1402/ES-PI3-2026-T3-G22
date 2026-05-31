/* Autor: Livia Lucizano */

// Widget componentizado do fl_chart com toda a estilização e exibição dos eixos
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppLineChart extends StatelessWidget {
  final List<FlSpot> spots;
  final Color corGrafico;
  final bool isHourly;

  const AppLineChart({
    super.key,
    required this.spots,
    required this.corGrafico,
    required this.isHourly,
  });

  @override
  Widget build(BuildContext context) {
    if (spots.isEmpty) return const SizedBox();

    return LineChart(
      LineChartData(
        // Remove as linhas de grade para ficar um visual limpo como no seu protótipo
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          
          // Eixo Y (Preços)
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(2),
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                );
              },
            ),
          ),
          
          // Eixo X (Datas/Horas)
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: _getInterval(spots), // Helper para espaçar os textos de data
              getTitlesWidget: (value, meta) {
                final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                // Formata como "14:00" ou "25/04" dependendo do filtro selecionado
                final text = isHourly ? DateFormat('HH:mm').format(date) : DateFormat('dd/MM').format(date);
                
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(text, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                );
              },
            ),
          ),
        ),
        // Remove as bordas que o pacote coloca por padrão
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: corGrafico,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            // Cria o preenchimento gradiente sutil abaixo da linha
            belowBarData: BarAreaData(
              show: true,
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

  // Função matemática simples para evitar que os textos do eixo X se sobreponham
  double _getInterval(List<FlSpot> spots) {
    if (spots.length <= 1) return 1;
    final minX = spots.first.x;
    final maxX = spots.last.x;
    // Divide o eixo X em no máximo 5 espaços de exibição
    return (maxX - minX) / 4; 
  }
}
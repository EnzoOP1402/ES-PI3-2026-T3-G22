import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'package:mescla_invest_app/core/widgets/app_bottom_navigation.dart';
import 'package:mescla_invest_app/core/widgets/custom_app_bar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final Color roxoPrincipal = const Color(0xFF38358C);
  final Color rosaPrincipal = const Color(0xFFE6006D);
  final Color fundoTela = const Color(0xFFF1F1F4);

  String periodoSelecionado = 'Últimas 24hrs';
  String busca = '';

  final List<String> periodos = [
    'Últimas 24hrs',
    'Último mês',
    'Últimos 6 meses',
    'Último ano',
  ];

  final List<TokenDashboard> tokens = [
    TokenDashboard(
      nome: 'Tokens NotaCerta',
      variacao: '+45,9%',
      corGrafico: const Color(0xFFFF4F9A),
      valores: [1.0, 1.4, 1.2, 1.8, 2.1, 1.7, 1.9, 1.5, 1.8, 2.2, 2.4],
    ),
    TokenDashboard(
      nome: 'Tokens HealthVibe',
      variacao: '+45,9%',
      corGrafico: const Color(0xFF4D8DFF),
      valores: [1.6, 1.2, 1.7, 1.4, 2.0, 2.3, 1.9, 2.1, 2.4, 1.8, 2.0],
    ),
    TokenDashboard(
      nome: 'Tokens Metalive',
      variacao: '+45,9%',
      corGrafico: const Color(0xFF9B4DFF),
      valores: [2.2, 1.9, 1.2, 1.4, 1.3, 1.6, 1.9, 2.1, 1.8, 1.7, 1.9],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final tokensFiltrados = tokens.where((token) {
      return token.nome.toLowerCase().contains(busca.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: fundoTela,

      appBar: const CustomAppBar(
        title: 'Dashboards',
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
        children: [
          _buildSearchBar(),
          const SizedBox(height: 10),
          _buildFiltros(),
          const SizedBox(height: 16),

          if (tokensFiltrados.isEmpty)
            _buildMensagemVazia()
          else
            ...tokensFiltrados.map(
              (token) => _buildTokenCard(token),
            ),
        ],
      ),

      bottomNavigationBar: const AppBottomNavigation(
        selectedIndex: 3,
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      onChanged: (valor) {
        setState(() {
          busca = valor;
        });
      },
      decoration: InputDecoration(
        hintText: 'Pesquisar Startup',
        hintStyle: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 13,
        ),
        prefixIcon: Icon(
          Icons.search,
          size: 20,
          color: Colors.grey.shade700,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: rosaPrincipal,
            width: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildFiltros() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: periodos.map((periodo) {
          final bool selecionado = periodo == periodoSelecionado;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  periodoSelecionado = periodo;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: selecionado ? rosaPrincipal : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selecionado
                        ? rosaPrincipal
                        : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  periodo,
                  style: TextStyle(
                    color: selecionado ? Colors.white : Colors.black87,
                    fontSize: 12,
                    fontWeight:
                        selecionado ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTokenCard(TokenDashboard token) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: token.corGrafico.withOpacity(0.12),
                child: Icon(
                  Icons.auto_graph_rounded,
                  color: token.corGrafico,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  token.nome,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              const Text(
                'Variação do período:',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                '${token.variacao} ↑',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF159947),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Container(
            height: 135,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.grey.shade200,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: LineChartFake(
                valores: token.valores,
                cor: token.corGrafico,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMensagemVazia() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        'Nenhuma startup encontrada.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class TokenDashboard {
  final String nome;
  final String variacao;
  final Color corGrafico;
  final List<double> valores;

  TokenDashboard({
    required this.nome,
    required this.variacao,
    required this.corGrafico,
    required this.valores,
  });
}

class LineChartFake extends StatelessWidget {
  final List<double> valores;
  final Color cor;

  const LineChartFake({
    super.key,
    required this.valores,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: LineChartFakePainter(
        valores: valores,
        cor: cor,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class LineChartFakePainter extends CustomPainter {
  final List<double> valores;
  final Color cor;

  LineChartFakePainter({
    required this.valores,
    required this.cor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    for (int i = 0; i <= 4; i++) {
      final x = size.width * i / 4;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }

    if (valores.isEmpty) return;

    final minValue = valores.reduce(math.min);
    final maxValue = valores.reduce(math.max);
    final difference = maxValue - minValue == 0 ? 1 : maxValue - minValue;

    Offset ponto(int index) {
      final x = size.width * index / (valores.length - 1);
      final normalized = (valores[index] - minValue) / difference;
      final y = size.height - normalized * size.height;
      return Offset(x, y);
    }

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < valores.length; i++) {
      final p = ponto(i);

      if (i == 0) {
        path.moveTo(p.dx, p.dy);
        fillPath.moveTo(p.dx, size.height);
        fillPath.lineTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
        fillPath.lineTo(p.dx, p.dy);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          cor.withOpacity(0.22),
          cor.withOpacity(0.02),
        ],
      ).createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );

    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = cor
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, linePaint);

    final ultimoPonto = ponto(valores.length - 1);

    final dotPaint = Paint()
      ..color = cor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(ultimoPonto, 4, dotPaint);

    final badgeRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(
          math.min(ultimoPonto.dx + 10, size.width - 12),
          ultimoPonto.dy,
        ),
        width: 26,
        height: 16,
      ),
      const Radius.circular(6),
    );

    canvas.drawRRect(badgeRect, dotPaint);

    final textPainter = TextPainter(
      text: const TextSpan(
        text: '10,0',
        style: TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    textPainter.paint(
      canvas,
      Offset(
        badgeRect.outerRect.center.dx - textPainter.width / 2,
        badgeRect.outerRect.center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
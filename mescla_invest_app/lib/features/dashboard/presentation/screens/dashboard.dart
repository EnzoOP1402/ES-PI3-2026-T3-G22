import 'dart:math' as math;
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

import 'package:mescla_invest_app/core/widgets/app_bottom_navigation.dart';
import 'package:mescla_invest_app/core/widgets/custom_app_bar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final Color rosaPrincipal = const Color(0xFFE6006D);
  final Color fundoTela = const Color(0xFFF1F1F4);

  String periodoSelecionado = 'Últimas 24hrs';
  String busca = '';

  bool carregando = true;
  String? erro;
  List<TokenDashboard> tokens = [];

  final List<String> periodos = [
    'Últimas 24hrs',
    'Últimos 7 dias',
    'Último mês',
    'Últimos 6 meses',
    'Último ano',
  ];

  @override
  void initState() {
    super.initState();
    _carregarDashboard();
  }

  String _periodoParaFunction(String periodo) {
    switch (periodo) {
      case 'Últimas 24hrs':
        return '24h';
      case 'Últimos 7 dias':
        return '7d';
      case 'Último mês':
        return '1m';
      case 'Últimos 6 meses':
        return '6m';
      case 'Último ano':
        return '1y';
      default:
        return '24h';
    }
  }

  Future<void> _carregarDashboard() async {
    setState(() {
      carregando = true;
      erro = null;
    });

    try {
      final callable = FirebaseFunctions.instanceFor(
        region: 'southamerica-east1',
      ).httpsCallable('getUserDashboardData');

      final result = await callable.call({
        'period': _periodoParaFunction(periodoSelecionado),
        'searchQuery': busca.trim(),
      });

      final dynamic response = result.data;

      List<dynamic> dados = [];

      if (response is List) {
        dados = response;
      } else if (response is Map && response['data'] is List) {
        dados = response['data'] as List<dynamic>;
      } else if (response is Map && response['tokens'] is List) {
        dados = response['tokens'] as List<dynamic>;
      }

      if (!mounted) return;

      setState(() {
        tokens = dados.map((item) {
          final map = Map<String, dynamic>.from(item as Map);

          final List<dynamic> chartData =
              (map['chartData'] as List?) ?? [];

          final bool isPositive = map['isPositive'] == true;

          final dynamic variationValue =
              map['variationPercentage'] ?? map['variation'] ?? 0;

          return TokenDashboard(
            nome: map['startupName'] ??
                map['tokenName'] ??
                map['name'] ??
                'Startup sem nome',
            variacao:
                '${isPositive ? '+' : '-'}${variationValue.toString()}%',
            isPositive: isPositive,
            corGrafico: rosaPrincipal,
            valores: chartData.map((ponto) {
              if (ponto is num) {
                return ponto.toDouble();
              }

              if (ponto is Map) {
                final pontoMap = Map<String, dynamic>.from(ponto);
                final value = pontoMap['y'] ??
                    pontoMap['value'] ??
                    pontoMap['price'] ??
                    0;
                return (value as num).toDouble();
              }

              return 0.0;
            }).toList(),
          );
        }).toList();

        carregando = false;
      });
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;

      setState(() {
        carregando = false;
        erro = e.message ?? e.code;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        carregando = false;
        erro = 'Erro inesperado ao carregar dashboard: $e';
      });
    }
  }

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
          if (carregando)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 40),
                child: CircularProgressIndicator(),
              ),
            )
          else if (erro != null)
            _buildMensagemErro()
          else if (tokensFiltrados.isEmpty)
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
        busca = valor;
      },
      onSubmitted: (_) {
        _carregarDashboard();
      },
      decoration: InputDecoration(
        hintText: 'Pesquisar Startup',
        prefixIcon: Icon(
          Icons.search,
          size: 20,
          color: Colors.grey.shade700,
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: _carregarDashboard,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
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
                _carregarDashboard();
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
    final Color corVariacao =
        token.isPositive ? const Color(0xFF159947) : Colors.red;

    final String seta = token.isPositive ? '↑' : '↓';

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
                '${token.variacao} $seta',
                style: TextStyle(
                  fontSize: 13,
                  color: corVariacao,
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
        'Nenhum token encontrado na sua carteira.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMensagemErro() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        erro!,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.red,
        ),
      ),
    );
  }
}

class TokenDashboard {
  final String nome;
  final String variacao;
  final bool isPositive;
  final Color corGrafico;
  final List<double> valores;

  TokenDashboard({
    required this.nome,
    required this.variacao,
    required this.isPositive,
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
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    for (int i = 0; i <= 4; i++) {
      final x = size.width * i / 4;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    if (valores.isEmpty) return;

    final valoresGrafico =
        valores.length == 1 ? [valores.first, valores.first] : valores;

    final minValue = valoresGrafico.reduce(math.min);
    final maxValue = valoresGrafico.reduce(math.max);
    final difference = maxValue - minValue == 0 ? 1 : maxValue - minValue;

    Offset ponto(int index) {
      final x = size.width * index / (valoresGrafico.length - 1);
      final normalized = (valoresGrafico[index] - minValue) / difference;
      final y = size.height - normalized * size.height;
      return Offset(x, y);
    }

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < valoresGrafico.length; i++) {
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
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = cor
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, linePaint);

    final ultimoPonto = ponto(valoresGrafico.length - 1);

    final dotPaint = Paint()
      ..color = cor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(ultimoPonto, 4, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
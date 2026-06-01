/* Autor: Livia Lucizano */

// Imports necessários para chamadas de backend, gráficos e interface
import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mescla_invest_app/core/widgets/app_bottom_navigation.dart';
import 'package:mescla_invest_app/core/widgets/custom_app_bar.dart';
import 'package:mescla_invest_app/core/utils/snackbar_utils.dart';
import 'package:mescla_invest_app/features/dashboard/data/models/token_dashboard_model.dart';
import 'package:mescla_invest_app/features/dashboard/presentation/widgets/app_line_chart.dart';
import 'package:mescla_invest_app/features/catalog/presentation/widgets/startup_catalog/stage_chip.dart';
import 'package:mescla_invest_app/features/catalog/presentation/widgets/startup_catalog/pesquisar_menu.dart';

// Tela responsável por exibir os dashboards dos tokens das startups
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Cores utilizadas na tela
  final Color rosaPrincipal = const Color(0xFFE6006D);
  final Color fundoTela = const Color(0xFFE2E2E2);

  // Período atualmente selecionado para os gráficos
  String periodoSelecionado = 'Últimas 24hrs';

  // Controller do campo de pesquisa
  final TextEditingController _searchController =
      TextEditingController();

  // Timer utilizado para debounce da pesquisa
  Timer? _searchDebounce;

  // Estados da tela
  bool carregando = true;
  bool carregandoSeed = false;
  String? erro;

  // Lista de tokens exibidos no dashboard
  List<TokenDashboard> tokens = [];

  // Opções de período disponíveis para filtragem
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

    // Carrega os dados ao abrir a tela
    _carregarDashboard();
  }

  @override
  void dispose() {
    // Libera recursos utilizados pela pesquisa
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // Converte o texto exibido para o formato esperado pelo backend
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

  // Executa a busca com debounce
  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();

    _searchDebounce = Timer(
      const Duration(milliseconds: 350),
      () {
        _carregarDashboard();
      },
    );
  }

  // Busca os dados do dashboard no backend
  Future<void> _carregarDashboard() async {
    setState(() {
      carregando = true;
      erro = null;
    });

    try {
      // Chama a Cloud Function responsável pelos dados do dashboard
      final callable = FirebaseFunctions.instanceFor(
        region: 'southamerica-east1',
      ).httpsCallable('getUserDashboardData');

      final result = await callable.call({
        'period': _periodoParaFunction(periodoSelecionado),
        'searchQuery': _searchController.text.trim(),
      });

      final dynamic response = result.data;

      List<dynamic> dados =
          response is List ? response : [];

      if (!mounted) return;

      setState(() {
        // Converte os dados recebidos em objetos TokenDashboard
        tokens = dados.map((item) {
          final map =
              Map<String, dynamic>.from(item as Map);

          final List<dynamic> chartData =
              (map['chartData'] as List?) ?? [];

          final bool isPositive =
              map['isPositive'] == true;

          final dynamic variationValue =
              map['variationPercentage'] ?? 0;

          return TokenDashboard(
            nome: map['startupName'] ??
                'Startup sem nome',

            variacao:
                '${isPositive ? '+' : '-'}${variationValue.toString()}%',

            isPositive: isPositive,

            corGrafico: rosaPrincipal,

            // Converte os pontos recebidos para FlSpot
            valores: chartData.map<FlSpot>((ponto) {
              if (ponto is Map) {
                final x = ponto['x'] ?? 0;
                final y = ponto['y'] ?? 0.0;

                return FlSpot(
                  (x as num).toDouble(),
                  (y as num).toDouble(),
                );
              }

              return const FlSpot(0, 0);
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
        erro = 'Erro inesperado ao carregar dashboard.';
      });
    }
  }

  // Executa a geração de dados históricos para testes
  Future<void> _rodarSeedDeDados() async {
    setState(() => carregandoSeed = true);

    try {
      final callable = FirebaseFunctions.instanceFor(
        region: 'southamerica-east1',
      ).httpsCallable('seedHistoricalData');

      await callable.call();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Dados históricos gerados com sucesso!',
            ),
            backgroundColor: Colors.green,
          ),
        );

        _carregarDashboard();
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(
          context,
          'Erro ao gerar dados: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() => carregandoSeed = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filtragem local dos resultados exibidos
    final tokensFiltrados = tokens.where((token) {
      return token.nome
          .toLowerCase()
          .contains(
            _searchController.text.toLowerCase(),
          );
    }).toList();

    return Scaffold(
      backgroundColor: fundoTela,

      appBar: const CustomAppBar(
        title: 'Dashboards',
      ),

      body: Column(
        children: [
          // Área de pesquisa e filtros
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              18,
              16,
              10,
            ),
            child: Column(
              children: [
                // Campo de busca
                BuscaStartup(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                ),

                const SizedBox(height: 10),

                // Filtros de período
                _buildFiltros(),
              ],
            ),
          ),

          // Área principal da tela
          Expanded(
            child: _buildBodyContent(
              tokensFiltrados,
            ),
          ),
        ],
      ),

      // Botão para gerar dados históricos de teste
      floatingActionButton: FloatingActionButton(
        onPressed:
            carregandoSeed ? null : _rodarSeedDeDados,

        backgroundColor: const Color(0xFF353988),

        child: carregandoSeed
            ? const CircularProgressIndicator(
                color: Colors.white,
              )
            : const Icon(
                Icons.watch_later_outlined,
                color: Colors.white,
              ),
      ),

      // Barra de navegação inferior
      bottomNavigationBar:
          const AppBottomNavigation(
        selectedIndex: 3,
      ),
    );
  }

  // Constrói o conteúdo principal da tela
  Widget _buildBodyContent(
    List<TokenDashboard> tokensFiltrados,
  ) {
    // Estado de carregamento
    if (carregando) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF353988),
        ),
      );
    }

    // Estado de erro
    if (erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),

          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [
              const Icon(
                Icons.error_outline,
                size: 56,
                color: Colors.redAccent,
              ),

              const SizedBox(height: 16),

              const Text(
                'Erro ao carregar gráficos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                erro!,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Caso não existam resultados
    if (tokensFiltrados.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Icon(
              Icons.search_off_rounded,
              size: 60,
              color: Colors.grey,
            ),

            SizedBox(height: 16),

            Text(
              'Nenhum token encontrado.',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    // Lista de dashboards
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        16,
        4,
        16,
        24,
      ),

      physics:
          const AlwaysScrollableScrollPhysics(),

      itemCount: tokensFiltrados.length,

      itemBuilder: (context, index) {
        return _buildTokenCard(
          tokensFiltrados[index],
        );
      },
    );
  }

  // Cria os filtros de período
  Widget _buildFiltros() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,

      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,

        children: periodos.map((periodo) {
          return Padding(
            padding: const EdgeInsets.only(
              right: 8,
            ),

            child: StageChip(
              label: periodo,
              value: periodo,
              selectedValue: periodoSelecionado,

              onSelected: (value) {
                setState(
                  () => periodoSelecionado = value,
                );

                _carregarDashboard();
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  // Cria o card individual de cada token
  Widget _buildTokenCard(TokenDashboard token) {
    final Color corVariacao = token.isPositive
        ? const Color(0xFF159947)
        : Colors.red;

    final String seta =
        token.isPositive ? '↑' : '↓';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),

      padding: const EdgeInsets.all(16),

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
          // Cabeçalho do card
          Row(
            children: [
              CircleAvatar(
                radius: 18,

                backgroundColor:
                    token.corGrafico.withOpacity(0.12),

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

          // Variação do período selecionado
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

          const SizedBox(height: 20),

          // Gráfico do token
          SizedBox(
            height: 140,

            child: AppLineChart(
              spots: token.valores,
              corGrafico: token.corGrafico,

              isHourly:
                  periodoSelecionado ==
                  'Últimas 24hrs',
            ),
          ),
        ],
      ),
    );
  }
}
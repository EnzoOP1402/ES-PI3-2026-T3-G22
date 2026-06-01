/* Autor: Livia Lucizano - RA: 25017514 */

// Importa os pacotes e arquivos necessários para a tela
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mescla_invest_app/core/utils/snackbar_utils.dart';
import 'package:mescla_invest_app/core/widgets/custom_app_bar.dart';
import 'package:mescla_invest_app/core/widgets/app_bottom_navigation.dart';
import 'package:mescla_invest_app/features/catalog/data/models/startup_model.dart';
import 'package:mescla_invest_app/features/catalog/presentation/screens/startup_detail_screen.dart';
import 'package:mescla_invest_app/features/catalog/presentation/widgets/startup_catalog/card_startup.dart';
import 'package:mescla_invest_app/features/catalog/presentation/widgets/startup_catalog/catalog_filters.dart';

// Tela principal do Catálogo, onde são listadas as startups disponíveis
class Catalogo extends StatefulWidget {
  const Catalogo({super.key});
  @override
  State<Catalogo> createState() => _CatalogoState();
}

class _CatalogoState extends State<Catalogo> {

  // Controller responsável por capturar o texto digitado no campo de busca
  final TextEditingController _searchController =
      TextEditingController();

  // Future que armazena a busca das startups vinda do backend
  Future<List<StartupModel>>? _startupsFuture;

  // Guarda o estágio selecionado no filtro. "todos" significa sem filtro
  String _selectedStage = 'todos';

  // Timer usado para evitar buscar a cada letra digitada imediatamente
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();

    // Assim que a tela abre, busca todas as startups
    _startupsFuture = _getStartups();
  }

  @override
  void dispose() {

    // Cancela o debounce para evitar execução depois que a tela for fechada
    _searchDebounce?.cancel();

    // Libera o controller da memória
    _searchController.dispose();

    super.dispose();
  }

  // Converte o filtro visual para o valor enviado ao backend
  String? _stageForRequest() {

    if (_selectedStage == 'todos') {
      return null;
    }

    return _selectedStage;
  }

  // Busca as startups no backend usando a Cloud Function listStartups
  Future<List<StartupModel>> _getStartups({
    String? search,
    String? stage,
  }) async {

    try {

      // Define a região onde a função Firebase está publicada
      final functions =
          FirebaseFunctions.instanceFor(region: 'southamerica-east1');

      // Prepara a chamada da função listStartups
      final callable =
          functions.httpsCallable(
        'listStartups',
      );

      // Chama a função enviando filtros somente se eles existirem
      final result =
          await callable.call(
        <String, dynamic>{

          if (search != null &&
              search.trim().isNotEmpty)
            'search': search.trim(),

          if (stage != null &&
              stage.trim().isNotEmpty)
            'state': stage.trim(),
        },
      );

      // Converte a resposta da função para Map
      final resultData =
          Map<String, dynamic>.from(
        result.data,
      );

      // Pega a lista de startups dentro da chave "data"
      final rawStartups =
          resultData['data'];

      // Se o retorno não for uma lista, devolve lista vazia
      if (rawStartups is! List) {
        return <StartupModel>[];
      }

      // Converte cada item retornado em um objeto StartupModel
      return rawStartups.map((item) {

        final data =
            Map<String, dynamic>.from(item);

        return StartupModel.fromMap(data);

      }).toList();

    } on FirebaseFunctionsException catch (e) {

      // Trata erros vindos diretamente da Cloud Function
      if (mounted) {
        showErrorSnackBar(
          context,
          e.message ??
          'Erro ao comunicar com o servidor.',
        );
      }
      // Repassa o erro para o FutureBuilder conseguir exibir estado de erro
      rethrow;
    } catch (e) {
      // Trata qualquer outro erro inesperado
      if (mounted) {
        showErrorSnackBar(
          context,
          'Erro inesperado ao buscar startups.',
        );
      }
      rethrow;
    }
  }

  // Aplica os filtros atuais de busca e estágio
  void _applyFilters() {

    setState(() {

      _startupsFuture = _getStartups(
        search: _searchController.text,

        stage: _stageForRequest(),
      );
    });
  }

  // Chamado sempre que o texto da busca muda
  void _onSearchChanged(String value) {

    _searchDebounce?.cancel();

    _searchDebounce = Timer(
      const Duration(milliseconds: 350),

      () {
        _applyFilters();
      },
    );
  }

// Limpa todos os filtros e recarrega a lista completa  
  void _clearFilters() {

    _searchDebounce?.cancel();
    _searchController.clear();
    setState(() {
      _selectedStage = 'todos';
      _startupsFuture = _getStartups();
    });
  }

  // Abre a tela de detalhes da startup selecionada
  void _openStartupDetail(
    StartupModel startup,
  ) {

    // Valida se a startup possui ID antes de navegar
    if (startup.id.isEmpty) {

      showErrorSnackBar(
        context,
        "ID da startup não encontrado",
      );

      return;
    }

    // Navega para a tela de detalhes enviando o ID da startup
    Navigator.push(
      context,

      MaterialPageRoute(
        builder: (_) => StartupDetailScreen(startupId: startup.id),
      ),
    );
  }

  // Atualiza a lista de startups, usado no gesto de puxar para atualizar
  Future<void> _refreshStartups() async {

    setState(() {

      _startupsFuture = _getStartups(
        search: _searchController.text,

        stage: _stageForRequest(),
      );
    });

    // Aguarda a busca terminar
    await _startupsFuture;
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      // Define a cor de fundo da tela
      backgroundColor:
          const Color(0xFFE8E9EB),
      // AppBar personalizada do projeto
      appBar: CustomAppBar(
        title: 'Catálogo',
      ),
      body: Column(
        children: [
          // Área superior com campo de busca e filtros
          Padding(
            padding:
                const EdgeInsets.fromLTRB(
              16,
              18,
              16,
              10,
            ),

            child: CatalogFilters(
              searchController:
                  _searchController,

              selectedStage:
                  _selectedStage,

              // Busca quando o usuário aciona o botão de pesquisa
              onSearch:
                  _applyFilters,

              // Busca automática com debounce enquanto o usuário digita
              onSearchChanged:
                  _onSearchChanged,

              // Limpa os filtros
              onClear:
                  _clearFilters,

              // Atualiza o filtro de estágio
              onStageChanged: (value) {

                setState(() {

                  _selectedStage = value;

                  _startupsFuture =
                      _getStartups(
                    search:
                        _searchController.text,

                    stage:
                        _stageForRequest(),
                  );
                });
              },
            ),
          ),

          // Área principal da tela, onde a lista ocupa o espaço restante
          Expanded(
            child:
                FutureBuilder<
                    List<StartupModel>>(
              future: _startupsFuture,

              builder: (
                context,
                snapshot,
              ) {

                if (snapshot.connectionState ==
                    ConnectionState.waiting) {

                  return const Center(
                    child:
                        CircularProgressIndicator(
                      color:
                          Color(0xFF353988),
                    ),
                  );
                }

                // Caso aconteça erro na busca, mostra mensagem e botão para tentar novamente
                if (snapshot.hasError) {

                  return Center(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(
                        24,
                      ),

                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,

                        children: [

                          const Icon(
                            Icons.error_outline,
                            size: 56,
                            color:
                                Colors.redAccent,
                          ),

                          const SizedBox(
                            height: 16,
                          ),

                          Text(
                            'Erro ao carregar startups',

                            textAlign:
                                TextAlign.center,

                            style:
                                GoogleFonts
                                    .montserrat(
                              fontSize: 16,

                              fontWeight:
                                  FontWeight
                                      .w700,
                            ),
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          Text(
                            snapshot.error
                                .toString(),

                            textAlign:
                                TextAlign.center,

                            style:
                                GoogleFonts
                                    .montserrat(
                              fontSize: 13,

                              color:
                                  Colors.black87,
                            ),
                          ),

                          const SizedBox(
                            height: 20,
                          ),

                          // Botão para refazer a busca
                          FilledButton.icon(
                            onPressed:
                                _refreshStartups,

                            icon:
                                const Icon(
                              Icons.refresh,
                            ),

                            label:
                                const Text(
                              'Tentar novamente',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Pega os dados retornados ou usa lista vazia
                final startups =
                    snapshot.data ??
                        <StartupModel>[];

                // Caso nenhuma startup seja encontrada
                if (startups.isEmpty) {

                  return Center(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(
                        24,
                      ),

                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,

                        children: [

                          const Icon(
                            Icons.search_off_rounded,
                            size: 60,
                            color: Colors.grey,
                          ),

                          const SizedBox(
                            height: 16,
                          ),

                          Text(
                            'Nenhuma startup encontrada.',

                            textAlign:
                                TextAlign.center,

                            style:
                                GoogleFonts
                                    .montserrat(
                              fontSize: 15,

                              fontWeight:
                                  FontWeight
                                      .w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Lista com atualização por gesto de puxar para baixo
                return RefreshIndicator(
                  onRefresh:
                      _refreshStartups,
                  child: ListView.builder(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    padding:
                        const EdgeInsets.fromLTRB(
                      16,
                      4,
                      16,
                      24,
                    ),

                    // Quantidade de startups na lista
                    itemCount:
                        startups.length,

                    // Monta um card para cada startup
                    itemBuilder:
                        (context, index) {

                      final startup =
                          startups[index];

                      return CardStartup(
                        startup: startup,

                        // Ao clicar no card, abre a tela de detalhes
                        onOpenDetails: () {

                          _openStartupDetail(
                            startup,
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // Barra de navegação inferior, com o Catálogo selecionado
      bottomNavigationBar:
          const AppBottomNavigation(
        selectedIndex: 1,
      ),
    );
  }
}
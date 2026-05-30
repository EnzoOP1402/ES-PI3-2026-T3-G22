/* Autor: Livia Lucizano */

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

class Catalogo extends StatefulWidget {
  const Catalogo({super.key});
  @override
  State<Catalogo> createState() => _CatalogoState();
}

class _CatalogoState extends State<Catalogo> {

  final TextEditingController _searchController =
      TextEditingController();

  Future<List<StartupModel>>? _startupsFuture;

  String _selectedStage = 'todos';

  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();

    _startupsFuture = _getStartups();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();

    _searchController.dispose();

    super.dispose();
  }

  String? _stageForRequest() {

    if (_selectedStage == 'todos') {
      return null;
    }

    return _selectedStage;
  }

  Future<List<StartupModel>> _getStartups({
    String? search,
    String? stage,
  }) async {

    try {

      final functions =
          FirebaseFunctions.instanceFor(region: 'southamerica-east1');

      final callable =
          functions.httpsCallable(
        'listStartups',
      );

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

      final resultData =
          Map<String, dynamic>.from(
        result.data,
      );

      final rawStartups =
          resultData['data'];

      if (rawStartups is! List) {
        return <StartupModel>[];
      }

      return rawStartups.map((item) {

        final data =
            Map<String, dynamic>.from(item);

        return StartupModel.fromMap(data);

      }).toList();

    } on FirebaseFunctionsException catch (e) {

      if (mounted) {
        showErrorSnackBar(
          context,
          e.message ??
          'Erro ao comunicar com o servidor.',
        );
      }
      rethrow;
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(
          context,
          'Erro inesperado ao buscar startups.',
        );
      }
      rethrow;
    }
  }

  void _applyFilters() {

    setState(() {

      _startupsFuture = _getStartups(
        search: _searchController.text,

        stage: _stageForRequest(),
      );
    });
  }

  void _onSearchChanged(String value) {

    _searchDebounce?.cancel();

    _searchDebounce = Timer(
      const Duration(milliseconds: 350),

      () {
        _applyFilters();
      },
    );
  }

  void _clearFilters() {

    _searchDebounce?.cancel();
    _searchController.clear();
    setState(() {
      _selectedStage = 'todos';
      _startupsFuture = _getStartups();
    });
  }

  void _openStartupDetail(
    StartupModel startup,
  ) {

    if (startup.id.isEmpty) {

      showErrorSnackBar(
        context,
        "ID da startup não encontrado",
      );

      return;
    }

    Navigator.push(
      context,

      MaterialPageRoute(
        builder: (_) => StartupDetailScreen(startupId: startup.id),
      ),
    );
  }

  Future<void> _refreshStartups() async {

    setState(() {

      _startupsFuture = _getStartups(
        search: _searchController.text,

        stage: _stageForRequest(),
      );
    });

    await _startupsFuture;
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
          const Color(0xFFE2E2E2),
      appBar: CustomAppBar(
        title: 'Catálogo',
      ),
      body: Column(
        children: [
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

              onSearch:
                  _applyFilters,

              onSearchChanged:
                  _onSearchChanged,

              onClear:
                  _clearFilters,

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

                final startups =
                    snapshot.data ??
                        <StartupModel>[];

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

                    itemCount:
                        startups.length,

                    itemBuilder:
                        (context, index) {

                      final startup =
                          startups[index];

                      return CardStartup(
                        startup: startup,

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
      bottomNavigationBar:
          const AppBottomNavigation(
        selectedIndex: 1,
      ),
    );
  }
}
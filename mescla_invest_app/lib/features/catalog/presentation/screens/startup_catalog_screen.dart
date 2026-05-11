/* Autor: Livia Lucizano */

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mescla_invest_app/core/utils/snackbar_utils.dart';
import 'package:mescla_invest_app/core/widgets/custom_app_bar.dart';
import 'package:mescla_invest_app/features/catalog/data/models/startup_model.dart';
import 'package:mescla_invest_app/features/catalog/presentation/screens/startup_detail_screen.dart';
import 'package:mescla_invest_app/features/catalog/presentation/widgets/startup_catalog/bottom_catalog_navigation.dart';
import 'package:mescla_invest_app/features/catalog/presentation/widgets/startup_catalog/card_startup.dart';
import 'package:mescla_invest_app/features/catalog/presentation/widgets/startup_catalog/catalog_filters.dart';
import 'package:mescla_invest_app/features/wallet/screens/wallet_user.dart';

class Catalogo extends StatefulWidget {
  const Catalogo({super.key});

  @override
  State<Catalogo> createState() => _CatalogoState();
}

class _CatalogoState extends State<Catalogo> {
  final TextEditingController _searchController = TextEditingController();

  Future<List<StartupModel>>? _startupsFuture;

  String _selectedStage = 'todos';
  Timer? _searchDebounce;
  int _selectedBottomIndex = 1;

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
      final functions = FirebaseFunctions.instance;
      final callable = functions.httpsCallable('listStartups');

      final result = await callable.call(<String, dynamic>{
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (stage != null && stage.trim().isNotEmpty) 'state': stage.trim(),
      });

      final resultData = Map<String, dynamic>.from(result.data);
      final rawStartups = resultData['data'];

      if (rawStartups is! List) {
        return <StartupModel>[];
      }

      return rawStartups.map((item) {
        final data = Map<String, dynamic>.from(item);
        return StartupModel.fromMap(data);
      }).toList();
    } on FirebaseFunctionsException catch (e) {
      // O backend lança HttpsError específicos (ex: 'invalid-argument', 'not-found')
      // O FirebaseFunctionsException captura esses erros do onCall para podermos tratá-los no app
      if (mounted)
        showErrorSnackBar(
          context,
          e.message ?? "Erro ao comunicar com o servidor.",
        );
      rethrow;
    } catch (e) {
      if (mounted)
        showErrorSnackBar(
          context,
          "Erro inesperado ao buscar startups: ${e.toString()}.",
        );
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

    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      _applyFilters();
    });
  }

  void _clearFilters() {
    _searchDebounce?.cancel();
    _searchController.clear();

    setState(() {
      _selectedStage = 'todos';
      _startupsFuture = _getStartups();
    });
  }

  void _openStartupDetail(StartupModel startup) {
    if (startup.id.isEmpty) {
      showErrorSnackBar(context, "ID da startup não encontrado");
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StartupDetailScreen(startupId: startup.id),
      ),
    );
  }

  void _onBottomMenuTap(int index) {
    setState(() {
      _selectedBottomIndex = index;
    });

    if (index == 1) {
      return;
    }

    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const WalletUser()),
      );
      return;
    }

    showErrorSnackBar(context, "Página não implementada");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE2E2E2),
      appBar: CustomAppBar(title: 'Catálogo'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
            child: CatalogFilters(
              searchController: _searchController,
              selectedStage: _selectedStage,
              onSearch: _applyFilters,
              onSearchChanged: _onSearchChanged,
              onClear: _clearFilters,
              onStageChanged: (value) {
                setState(() {
                  _selectedStage = value;
                  _startupsFuture = _getStartups(
                    search: _searchController.text,
                    stage: _stageForRequest(),
                  );
                });
              },
            ),
          ),

          Expanded(
            child: FutureBuilder<List<StartupModel>>(
              future: _startupsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF353988)),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Erro ao carregar startups.\n\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  );
                }

                final startups = snapshot.data ?? <StartupModel>[];

                if (startups.isEmpty) {
                  return Center(
                    child: Text(
                      'Nenhuma startup encontrada.',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: startups.length,
                  itemBuilder: (context, index) {
                    return CardStartup(
                      startup: startups[index],
                      onOpenDetails: () {
                        _openStartupDetail(startups[index]);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomCatalogNavigation(
        selectedIndex: _selectedBottomIndex,
        onTap: _onBottomMenuTap,
      ),
    );
  }
}

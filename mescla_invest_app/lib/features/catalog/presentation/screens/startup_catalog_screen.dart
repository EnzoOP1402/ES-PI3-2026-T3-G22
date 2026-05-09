/* Autor: Livia Lucizano */

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mescla_invest_app/features/auth/data/repositories/auth_repository.dart';
import 'package:mescla_invest_app/features/catalog/presentation/screens/startup_detail_screen.dart';

class MesclaInvest extends StatelessWidget {
  const MesclaInvest({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Catalogo(),
      theme: ThemeData(
        textTheme: GoogleFonts.montserratTextTheme(),
      ),
    );
  }
}

class StartupCatalogItem {
  final String id;
  final String name;
  final String shortDescription;
  final String stage;
  final List<String> tags;
  final int totalTokensIssued;
  final num capitalRaisedCents;

  const StartupCatalogItem({
    required this.id,
    required this.name,
    required this.shortDescription,
    required this.stage,
    required this.tags,
    required this.totalTokensIssued,
    required this.capitalRaisedCents,
  });

  factory StartupCatalogItem.fromMap(Map<String, dynamic> data) {
    return StartupCatalogItem(
      id: data['id']?.toString() ?? '',
      name: data['name']?.toString() ??
          data['nome']?.toString() ??
          'Startup sem nome',
      shortDescription: data['shortDescription']?.toString() ??
          data['description']?.toString() ??
          data['descricao']?.toString() ??
          'Descrição não informada.',
      stage: data['stage']?.toString() ??
          data['estagio']?.toString() ??
          'Status não informado',
      tags: _parseTags(data['tags']),
      totalTokensIssued: _parseInt(
        data['totalTokensIssued'] ??
            data['tokensEmitidos'] ??
            data['totalTokensEmitidos'],
      ),
      capitalRaisedCents: _parseNum(
        data['capitalRaisedCents'] ?? data['capitalAportado'],
      ),
    );
  }

  static List<String> _parseTags(dynamic value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }

    return <String>[];
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value) ?? 0;
    }

    return 0;
  }

  static num _parseNum(dynamic value) {
    if (value is num) {
      return value;
    }

    if (value is String) {
      return num.tryParse(value) ?? 0;
    }

    return 0;
  }
}

class Catalogo extends StatefulWidget {
  const Catalogo({super.key});

  @override
  State<Catalogo> createState() => _CatalogoState();
}

class _CatalogoState extends State<Catalogo> {
  final TextEditingController _searchController = TextEditingController();

  Future<List<StartupCatalogItem>>? _startupsFuture;

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

  Future<List<StartupCatalogItem>> _getStartups({
    String? search,
    String? stage,
  }) async {
    try {
      final functions = FirebaseFunctions.instance;
      final callable = functions.httpsCallable('listStartups');

      final result = await callable.call(<String, dynamic>{
        if (search != null && search.trim().isNotEmpty)
          'search': search.trim(),
        if (stage != null && stage.trim().isNotEmpty)
          'state': stage.trim(),
      });

      debugPrint('RETORNO LIST STARTUPS: ${result.data}');

      final resultData = Map<String, dynamic>.from(result.data);
      final rawStartups = resultData['data'];

      if (rawStartups is! List) {
        return <StartupCatalogItem>[];
      }

      return rawStartups.map((item) {
        final data = Map<String, dynamic>.from(item);
        return StartupCatalogItem.fromMap(data);
      }).toList();
    } on FirebaseFunctionsException catch (e) {
      debugPrint('Erro Firebase Functions: ${e.code}');
      debugPrint('Mensagem: ${e.message}');
      debugPrint('Detalhes: ${e.details}');
      rethrow;
    } catch (e) {
      debugPrint('Erro inesperado ao buscar startups: $e');
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

  void _openStartupDetail(StartupCatalogItem startup) {
    if (startup.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID da startup não encontrado.'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StartupDetailScreen(
          startupId: startup.id,
        ),
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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tela ainda não implementada.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE2E2E2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF353988),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Catálogo',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Menu lateral ainda não implementado.'),
              ),
            );
          },
          icon: const Icon(
            Icons.menu_rounded,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: AuthRepository.instance.logout,
            icon: const Icon(
              Icons.logout_rounded,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
            child: _CatalogFilters(
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
            child: FutureBuilder<List<StartupCatalogItem>>(
              future: _startupsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF353988),
                    ),
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

                final startups = snapshot.data ?? <StartupCatalogItem>[];

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
      bottomNavigationBar: _BottomCatalogNavigation(
        selectedIndex: _selectedBottomIndex,
        onTap: _onBottomMenuTap,
      ),
    );
  }
}

class _CatalogFilters extends StatelessWidget {
  final TextEditingController searchController;
  final String selectedStage;
  final VoidCallback onSearch;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClear;
  final ValueChanged<String> onStageChanged;

  const _CatalogFilters({
    required this.searchController,
    required this.selectedStage,
    required this.onSearch,
    required this.onSearchChanged,
    required this.onClear,
    required this.onStageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: searchController,
          textInputAction: TextInputAction.search,
          onChanged: onSearchChanged,
          onSubmitted: (_) => onSearch(),
          decoration: InputDecoration(
            hintText: 'Pesquisar Startup',
            hintStyle: GoogleFonts.montserrat(
              color: Colors.black54,
              fontSize: 13,
            ),
            prefixIcon: const Icon(
              Icons.search,
              color: Color(0xFF353988),
            ),
            suffixIcon: searchController.text.isEmpty
                ? null
                : IconButton(
                    onPressed: onClear,
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF353988),
                    ),
                  ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),

        const SizedBox(height: 10),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _StageChip(
                label: 'Todas',
                value: 'todos',
                selectedValue: selectedStage,
                onSelected: onStageChanged,
              ),
              const SizedBox(width: 6),
              _StageChip(
                label: 'Em operação',
                value: 'em_operacao',
                selectedValue: selectedStage,
                onSelected: onStageChanged,
              ),
              const SizedBox(width: 6),
              _StageChip(
                label: 'Em expansão',
                value: 'em_expansao',
                selectedValue: selectedStage,
                onSelected: onStageChanged,
              ),
              const SizedBox(width: 6),
              _StageChip(
                label: 'Nova',
                value: 'nova',
                selectedValue: selectedStage,
                onSelected: onStageChanged,
              ),
              const SizedBox(width: 6),
              IconButton(
                tooltip: 'Limpar filtros',
                onPressed: onClear,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF353988),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StageChip extends StatelessWidget {
  final String label;
  final String value;
  final String selectedValue;
  final ValueChanged<String> onSelected;

  const _StageChip({
    required this.label,
    required this.value,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selectedValue;

    return GestureDetector(
      onTap: () => onSelected(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFDB0065) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFDB0065)
                : const Color(0xFFDADADA),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.montserrat(
            color: isSelected ? Colors.white : Colors.black87,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class CardStartup extends StatefulWidget {
  final StartupCatalogItem startup;
  final VoidCallback onOpenDetails;

  const CardStartup({
    super.key,
    required this.startup,
    required this.onOpenDetails,
  });

  @override
  State<CardStartup> createState() => _CardStartupState();
}

class _CardStartupState extends State<CardStartup> {
  bool expandido = false;

  String _formatCurrencyFromCents(num cents) {
    final value = cents / 100;
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String _formatStage(String stage) {
    switch (stage) {
      case 'nova':
        return 'Nova';
      case 'em_operacao':
        return 'Em operação';
      case 'em_expansao':
        return 'Em expansão';
      default:
        return stage;
    }
  }

  @override
  Widget build(BuildContext context) {
    final startup = widget.startup;

    return Card(
      color: const Color(0xFFF4F4F4),
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: widget.onOpenDetails,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.business_rounded,
                      color: Color(0xFF353988),
                      size: 24,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          startup.name,
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          startup.shortDescription,
                          maxLines: expandido ? null : 2,
                          overflow: expandido
                              ? TextOverflow.visible
                              : TextOverflow.ellipsis,
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            color: Colors.black87,
                            height: 1.25,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5E5E5),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            _formatStage(startup.stage),
                            style: GoogleFonts.montserrat(
                              fontSize: 10,
                              color: const Color(0xFF353988),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    icon: Icon(
                      expandido
                          ? Icons.close_fullscreen_rounded
                          : Icons.open_in_full_rounded,
                      color: Colors.black87,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        expandido = !expandido;
                      });
                    },
                  ),
                ],
              ),

              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _MiniInfo(
                              label: 'Tokens emitidos',
                              value: '${startup.totalTokensIssued} tokens',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _MiniInfo(
                              label: 'Capital aportado',
                              value: _formatCurrencyFromCents(
                                startup.capitalRaisedCents,
                              ),
                            ),
                          ),
                        ],
                      ),

                      if (startup.tags.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: startup.tags.map((tag) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  tag,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],

                      const SizedBox(height: 10),

                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF353988),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9),
                            ),
                          ),
                          onPressed: widget.onOpenDetails,
                          child: Text(
                            'Ver Mais',
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                crossFadeState: expandido
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 250),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniInfo extends StatelessWidget {
  final String label;
  final String value;

  const _MiniInfo({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 10,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 11,
              color: const Color(0xFF353988),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomCatalogNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _BottomCatalogNavigation({
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      const _BottomNavItem(
        icon: Icons.home_outlined,
        label: 'Início',
      ),
      const _BottomNavItem(
        icon: Icons.lightbulb_outline,
        label: 'Catálogo',
      ),
      const _BottomNavItem(
        icon: Icons.bar_chart_rounded,
        label: 'Dashboards',
      ),
      const _BottomNavItem(
        icon: Icons.account_balance_wallet_outlined,
        label: 'Carteira',
      ),
      const _BottomNavItem(
        icon: Icons.person_outline_rounded,
        label: 'Conta',
      ),
    ];

    return Container(
      height: 72,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isSelected = index == selectedIndex;

          return Expanded(
            child: InkWell(
              onTap: () => onTap(index),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    item.icon,
                    size: 22,
                    color: isSelected
                        ? const Color(0xFFDB0065)
                        : const Color(0xFF353988),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.label,
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected
                          ? const Color(0xFFDB0065)
                          : const Color(0xFF353988),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _BottomNavItem {
  final IconData icon;
  final String label;

  const _BottomNavItem({
    required this.icon,
    required this.label,
  });
}
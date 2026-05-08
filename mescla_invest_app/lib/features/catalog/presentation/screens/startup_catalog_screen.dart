/* Autor:  */

import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mescla_invest_app/features/auth/data/repositories/auth_repository.dart';
import 'package:mescla_invest_app/features/catalog/presentation/screens/startup_detail_screen.dart';

import '../theme/background_app.dart';

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

  @override
  void initState() {
    super.initState();
    _startupsFuture = _getStartups();
  }

  @override
  void dispose() {
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
        if (stage != null && stage.trim().isNotEmpty) 'state': stage.trim(),
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

  void _clearFilters() {
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

  String _selectedStageLabel() {
    switch (_selectedStage) {
      case 'nova':
        return 'Nova';
      case 'em_operacao':
        return 'Em operação';
      case 'em_expansao':
        return 'Em expansão';
      case 'todos':
      default:
        return 'Todos os estágios';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text('Catálogo'),
        foregroundColor: const Color(0xFF353988),
        actions: [
          TextButton.icon(
            onPressed: AuthRepository.instance.logout,
            label: const Icon(Icons.logout),
          ),
        ],
      ),
      body: BackgroundContainer(
        child: Column(
          children: [
            const SizedBox(height: 96),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _CatalogFilters(
                searchController: _searchController,
                selectedStage: _selectedStage,
                selectedStageLabel: _selectedStageLabel(),
                onSearch: _applyFilters,
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

            const SizedBox(height: 12),

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
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
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
      ),
    );
  }
}

class _CatalogFilters extends StatelessWidget {
  final TextEditingController searchController;
  final String selectedStage;
  final String selectedStageLabel;
  final VoidCallback onSearch;
  final VoidCallback onClear;
  final ValueChanged<String> onStageChanged;

  const _CatalogFilters({
    required this.searchController,
    required this.selectedStage,
    required this.selectedStageLabel,
    required this.onSearch,
    required this.onClear,
    required this.onStageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8E9EB),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          TextField(
            controller: searchController,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => onSearch(),
            decoration: InputDecoration(
              hintText: 'Pesquisar startup...',
              prefixIcon: const Icon(
                Icons.search,
                color: Color(0xFF353988),
              ),
              suffixIcon: IconButton(
                onPressed: onSearch,
                icon: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Color(0xFF353988),
                ),
              ),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.85),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: PopupMenuButton<String>(
                  onSelected: onStageChanged,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  itemBuilder: (context) {
                    return const [
                      PopupMenuItem<String>(
                        value: 'todos',
                        child: Text('Todos os estágios'),
                      ),
                      PopupMenuItem<String>(
                        value: 'nova',
                        child: Text('Nova'),
                      ),
                      PopupMenuItem<String>(
                        value: 'em_operacao',
                        child: Text('Em operação'),
                      ),
                      PopupMenuItem<String>(
                        value: 'em_expansao',
                        child: Text('Em expansão'),
                      ),
                    ];
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.filter_list_rounded,
                          color: Color(0xFF353988),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            selectedStageLabel,
                            style: GoogleFonts.montserrat(
                              color: Colors.black87,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Color(0xFF353988),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              IconButton(
                tooltip: 'Limpar filtros',
                onPressed: onClear,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.85),
                  foregroundColor: const Color(0xFF353988),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
        ],
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
      color: const Color(0xFFE8E9EB),
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: widget.onOpenDetails,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.business_rounded,
                      color: Color(0xFF353988),
                      size: 30,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                startup.name,
                                style: GoogleFonts.montserrat(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                expandido
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                color: const Color(0xFF353988),
                              ),
                              onPressed: () {
                                setState(() {
                                  expandido = !expandido;
                                });
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDADADA),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            _formatStage(startup.stage),
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              color: const Color(0xFF353988),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        startup.shortDescription,
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),

                      if (startup.tags.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: startup.tags.map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                tag,
                                style: GoogleFonts.montserrat(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: _MiniInfo(
                              label: 'Tokens emitidos',
                              value: '${startup.totalTokensIssued}',
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

                      const SizedBox(height: 12),

                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF353988),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: widget.onOpenDetails,
                          child: Text(
                            'Ver mais',
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
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
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 11,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              color: const Color(0xFF353988),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
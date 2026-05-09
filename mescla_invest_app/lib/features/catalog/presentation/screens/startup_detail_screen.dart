/* Autor: Livia Lucizano */

import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mescla_invest_app/features/catalog/presentation/widgets/startup_detail/tag_startup.dart';
import 'package:mescla_invest_app/features/catalog/presentation/widgets/startup_detail/financial_panel_card.dart';
import 'package:mescla_invest_app/features/catalog/presentation/widgets/startup_detail/partners_card.dart';
import 'package:mescla_invest_app/features/catalog/presentation/widgets/startup_detail/external_members_card.dart';
import 'package:mescla_invest_app/features/catalog/presentation/widgets/startup_detail/more_about_card.dart';
import 'package:mescla_invest_app/features/catalog/presentation/widgets/startup_detail/public_questions_card.dart';
import 'package:mescla_invest_app/features/catalog/presentation/widgets/startup_detail/priv_questions_card.dart';

class StartupDetailScreen extends StatefulWidget {
  final String startupId;

  const StartupDetailScreen({
    super.key,
    required this.startupId,
  });

  @override
  State<StartupDetailScreen> createState() => _StartupDetailScreenState();
}

class _StartupDetailScreenState extends State<StartupDetailScreen> {
  late final Future<Map<String, dynamic>> _startupDetailsFuture;

  static const Color _primaryColor = Color(0xFF2F3192);
  static const Color _accentColor = Color(0xFFE4007C);
  static const Color _backgroundColor = Color(0xFFF5F5F5);

  @override
  void initState() {
    super.initState();
    _startupDetailsFuture = getStartupDetails();
  }

  Future<Map<String, dynamic>> getStartupDetails() async {
    try {
      final functions = FirebaseFunctions.instance;

      final HttpsCallable callable = functions.httpsCallable(
        'getStartupDetails',
      );

      final result = await callable.call(<String, dynamic>{
        'startupId': widget.startupId,
      });

      return Map<String, dynamic>.from(result.data);
    } on FirebaseFunctionsException catch (e) {
      debugPrint('Erro Firebase Functions: ${e.code}');
      debugPrint('Mensagem: ${e.message}');
      debugPrint('Detalhes: ${e.details}');
      rethrow;
    } catch (e) {
      debugPrint('Erro inesperado ao buscar dados da startup: $e');
      rethrow;
    }
  }

  List<dynamic> _getListField(
    Map<String, dynamic> data,
    List<String> possibleKeys,
  ) {
    for (final key in possibleKeys) {
      final value = data[key];

      if (value is List) {
        return value;
      }
    }

    return <dynamic>[];
  }

  String _getStringField(
    Map<String, dynamic> data,
    List<String> possibleKeys,
    String fallback,
  ) {
    for (final key in possibleKeys) {
      final value = data[key];

      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }

    return fallback;
  }

  void _goToInvestScreen(Map<String, dynamic> startupData) {
    Navigator.pushNamed(
      context,
      '/balcao',
      arguments: {
        'startupId': widget.startupId,
        'startupData': startupData,
        'openBuyOrder': true,
      },
    );
  }

  void _onBottomMenuTap(int index) {
    switch (index) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          (route) => false,
        );
        break;

      case 1:
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/catalog',
          (route) => false,
        );
        break;

      case 2:
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/dashboard',
          (route) => false,
        );
        break;

      case 3:
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/carteira',
          (route) => false,
        );
        break;

      case 4:
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/conta',
          (route) => false,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,

      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Detalhes da Startup',
          style: GoogleFonts.montserrat(
            color: _primaryColor,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: _primaryColor,
            size: 20,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: FutureBuilder<Map<String, dynamic>>(
        future: _startupDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: _primaryColor,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Erro ao carregar dados da startup.\n\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'Startup não encontrada.',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }

          final startupData = snapshot.data!;

          final nome = _getStringField(
            startupData,
            ['nome', 'name'],
            'Nome da Startup',
          );

          final descricao = _getStringField(
            startupData,
            ['shortDescription', 'description', 'descricao'],
            'Descrição da startup não informada.',
          );

          final estagio = _getStringField(
            startupData,
            ['estagio', 'stage'],
            'Em operação',
          );

          final tags = _getListField(
            startupData,
            ['tags'],
          );

          final setor = tags.isNotEmpty
              ? tags.first.toString()
              : _getStringField(
                  startupData,
                  ['setor', 'sector'],
                  'Setor não informado',
                );

          final logoPath = _getStringField(
            startupData,
            ['logoPath', 'logo', 'imagePath'],
            'assets/images/logo_nota_certa.png',
          );

          final socios = _getListField(
            startupData,
            ['founders', 'socios', 'partners'],
          );

          final membrosExternos = _getListField(
            startupData,
            ['externalMembers', 'mentoresConselho', 'membrosExternos'],
          );

          final perguntasPublicas = _getListField(
            startupData,
            ['perguntasPublicas', 'publicQuestions'],
          );

          final perguntasPrivadas = _getListField(
            startupData,
            ['perguntasPrivadas', 'privateQuestions'],
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Image.asset(
                        logoPath,
                        width: 78,
                        height: 78,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.business_rounded,
                            color: _primaryColor,
                            size: 42,
                          );
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  nome,
                  style: GoogleFonts.montserrat(
                    color: _primaryColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    TagStartup(texto: estagio),
                    TagStartup(texto: setor),
                  ],
                ),

                const SizedBox(height: 12),

                Text(
                  descricao,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    height: 1.45,
                    color: Colors.black87,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 16),

                FinancialPanelCard(
                  startupData: startupData,
                  onInvestPressed: () {
                    _goToInvestScreen(startupData);
                  },
                ),

                PartnersCard(
                  socios: socios,
                ),

                ExternalMembersCard(
                  membrosExternos: membrosExternos,
                ),

                MoreAboutCard(
                  startupData: startupData,
                ),

                PublicQuestionsCard(
                  perguntasPublicas: perguntasPublicas,
                ),

                PrivateQuestionsCard(
                  perguntasPrivadas: perguntasPrivadas,
                ),
              ],
            ),
          );
        },
      ),

      bottomNavigationBar: _DetailBottomMenu(
        selectedIndex: 1,
        onTap: _onBottomMenuTap,
      ),
    );
  }
}

class _DetailBottomMenu extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _DetailBottomMenu({
    required this.selectedIndex,
    required this.onTap,
  });

  static const Color _primaryColor = Color(0xFF2F3192);
  static const Color _accentColor = Color(0xFFE4007C);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _BottomMenuItem(
              icon: Icons.home_outlined,
              label: 'Início',
              isSelected: selectedIndex == 0,
              onTap: () => onTap(0),
            ),
            _BottomMenuItem(
              icon: Icons.lightbulb_outline_rounded,
              label: 'Catálogo',
              isSelected: selectedIndex == 1,
              onTap: () => onTap(1),
            ),
            _BottomMenuItem(
              icon: Icons.bar_chart_rounded,
              label: 'Dashboards',
              isSelected: selectedIndex == 2,
              onTap: () => onTap(2),
            ),
            _BottomMenuItem(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Carteira',
              isSelected: selectedIndex == 3,
              onTap: () => onTap(3),
            ),
            _BottomMenuItem(
              icon: Icons.person_outline_rounded,
              label: 'Conta',
              isSelected: selectedIndex == 4,
              onTap: () => onTap(4),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _BottomMenuItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  static const Color _primaryColor = Color(0xFF2F3192);
  static const Color _accentColor = Color(0xFFE4007C);

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? _accentColor : _primaryColor;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: color,
                size: 23,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.montserrat(
                  color: color,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
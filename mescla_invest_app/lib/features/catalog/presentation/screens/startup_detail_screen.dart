/* Autor: coloque seu nome aqui */

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Detalhes da Startup',
          style: GoogleFonts.montserrat(
            color: const Color(0xFF2F3192),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF2F3192),
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
                color: Color(0xFF2F3192),
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
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
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
                            color: Color(0xFF2F3192),
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
                    color: const Color(0xFF2F3192),
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

                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }
}
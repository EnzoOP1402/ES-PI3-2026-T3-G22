/* Autor: Livia Lucizano */
import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mescla_invest_app/core/utils/constants.dart';
import 'package:mescla_invest_app/core/utils/snackbar_utils.dart';
import 'package:mescla_invest_app/features/catalog/data/models/startup_model.dart';
import 'package:mescla_invest_app/core/widgets/app_bottom_navigation.dart';
import 'package:mescla_invest_app/features/catalog/presentation/widgets/startup_detail/tag_startup.dart';
import 'package:mescla_invest_app/features/catalog/presentation/widgets/startup_detail/financial_panel_card.dart';
import 'package:mescla_invest_app/features/catalog/presentation/widgets/startup_detail/founders_card.dart';
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
        'id': widget.startupId,
      });

      return Map<String, dynamic>.from(result.data);
    } on FirebaseFunctionsException catch (e) {
      // O backend lança HttpsError específicos (ex: 'invalid-argument', 'not-found')
      // O FirebaseFunctionsException captura esses erros do onCall para podermos tratá-los no app
      if (mounted) showErrorSnackBar(context, e.message ?? "Erro ao comunicar com o servidor.");
      rethrow;
    } catch (e) {
      if (mounted) showErrorSnackBar(context, "Erro inesperado ao buscar dados da startup: ${e.toString()}.");
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
 @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: backgroundColor,

    appBar: AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'Detalhes da Startup',
        style: GoogleFonts.montserrat(
          color: primaryColor,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: primaryColor,
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

        if (snapshot.connectionState ==
            ConnectionState.waiting) {

          return const Center(
            child: CircularProgressIndicator(
              color: primaryColor,
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
                  color: Colors.black,
                ),
              ),
            ),
          );
        }

        if (!snapshot.hasData ||
            snapshot.data!.isEmpty) {

          return Center(
            child: Text(
              'Startup não encontrada.',

              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }
        final fullResponse = snapshot.data!;
        final startupData =
            Map<String, dynamic>.from(
          fullResponse['data'] ?? {},
        );

        final nome = _getStringField(
          startupData,
          ['name'],
          'Nome da Startup',
        );

        final descricao = _getStringField(
          startupData,
          ['description'],
          'Descrição da startup não informada.',
        );

        final estagio = _getStringField(
          startupData,
          ['stage'],
          'Em operação',
        );

        final tags = _getListField(
          startupData,
          ['tags'],
        );

        final logoPath = _getStringField(
          startupData,
          ['profilePicture'],
          '',
        );

        final socios = _getListField(
          startupData,
          ['founders'],
        );

        final membrosExternos = _getListField(
          startupData,
          ['externalMembers'],
        );

        final perguntasPublicas = _getListField(
          startupData,
          ['publicQuestions'],
        );

        final perguntasPrivadas = _getListField(
          startupData,
          ['privateQuestions'],
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            110,
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              Center(
                child: CircleAvatar(
                  radius: 55,

                  backgroundColor:
                      Colors.white,

                  child: Padding(
                    padding:
                        const EdgeInsets.all(12),

                    child: Image.network(
                      logoPath,

                      width: 78,
                      height: 78,

                      fit: BoxFit.contain,

                      errorBuilder: (
                        context,
                        error,
                        stackTrace,
                      ) {

                        return const Icon(
                          Icons.business_rounded,
                          color: primaryColor,
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

                style:
                    GoogleFonts.montserrat(
                  color: primaryColor,
                  fontSize: 22,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              SingleChildScrollView(
                scrollDirection:
                    Axis.horizontal,

                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,

                  children: [

                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),

                      decoration: BoxDecoration(
                        color:
                            const Color(0xFFC3C0FF),

                        borderRadius:
                            BorderRadius.circular(
                          7.5,
                        ),
                      ),

                      child: Text(
                        StartupModel.formatStage(
                          estagio,
                        ),

                        style:
                            GoogleFonts.montserrat(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight:
                              FontWeight.w500,
                        ),
                      ),
                    ),

                    ...tags.map(
                      (tag) {

                        return TagStartup(
                          texto: tag.toString(),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Text(
                descricao,

                style:
                    GoogleFonts.montserrat(
                  fontSize: 16,
                  height: 1.45,
                  color: Colors.black,
                  fontWeight:
                      FontWeight.w400,
                ),
              ),

              const SizedBox(height: 16),

              FinancialPanelCard(
                startupData: startupData,

                onInvestPressed: () {
                  _goToInvestScreen(
                    startupData,
                  );
                },
              ),

              FoundersCard(
                socios: socios,
              ),

              ExternalMembersCard(
                membrosExternos:
                    membrosExternos,
              ),

              MoreAboutCard(
                startupData: startupData,
              ),

              PublicQuestionsCard(
                startupId:
                    widget.startupId,

                perguntasPublicas:
                    perguntasPublicas,
              ),

              PrivateQuestionsCard(
                perguntasPrivadas:
                    perguntasPrivadas,
              ),
            ],
          ),
        );
      },
    ),
    bottomNavigationBar:
    const AppBottomNavigation(
    selectedIndex: 1,
    )
  );
}}
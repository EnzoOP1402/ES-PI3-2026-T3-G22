/* Autor: Livia Lucizano - RA: 25017514 */

// Imports necessários para a tela de detalhes da startup
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
import 'package:mescla_invest_app/routes/app_routes.dart';

// Tela responsável por exibir os detalhes completos de uma startup
class StartupDetailScreen extends StatefulWidget {
  // ID da startup recebida pela tela anterior
  final String startupId;

  const StartupDetailScreen({
    super.key,
    required this.startupId,
  });

  @override
  State<StartupDetailScreen> createState() => _StartupDetailScreenState();
}

class _StartupDetailScreenState extends State<StartupDetailScreen> {

// Future que guarda a busca dos dados da startup no backend
  late final Future<Map<String, dynamic>> _startupDetailsFuture;

  @override
  void initState() {
    super.initState();
    // Ao abrir a tela, inicia a busca dos detalhes da startup
    _startupDetailsFuture = getStartupDetails();
  }

 // Busca os dados completos da startup usando uma Cloud Function
  Future<Map<String, dynamic>> getStartupDetails() async {
    try {
      // Define a região onde a função Firebase está publicada
      final functions = FirebaseFunctions.instanceFor(
        region: 'southamerica-east1',
      );

      // Prepara a chamada da função getStartupDetails
      final HttpsCallable callable = functions.httpsCallable(
        'getStartupDetails',
      );
       // Chama a função enviando o ID da startup
      final result = await callable.call(<String, dynamic>{
        'id': widget.startupId,
      });
      // Converte a resposta para Map
      return Map<String, dynamic>.from(result.data);
    } on FirebaseFunctionsException catch (e) {
      // O backend lança HttpsError específicos (ex: 'invalid-argument', 'not-found')
      // O FirebaseFunctionsException captura esses erros do onCall para podermos tratá-los no app
      if (mounted) {
        showErrorSnackBar(
          context,
          e.message ?? "Erro ao comunicar com o servidor.",
        );
      }

      // Repassa o erro para o FutureBuilder tratar visualmente
      rethrow;
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(
          context,
          "Erro inesperado ao buscar dados da startup: ${e.toString()}.",
        );
      }

      rethrow;
    }
  }

 // Busca um campo que deve ser uma lista, testando várias chaves possíveis
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

// Busca um campo de texto, testando várias chaves possíveis
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

  // Leva o usuário para a tela de exchange/balcão para investir na startup
  void _goToInvestScreen(Map<String, dynamic> startupData) {
    // Pega o nome da startup para enviar junto na navegação
    final startupName = _getStringField(
      startupData,
      ['name'],
      'Nome da Startup',
    );

// Navega para a tela de exchange levando os dados necessários
    Navigator.pushNamed(
      context,
      AppRoutes.exchange,
      arguments: {
        'startupId': widget.startupId,
        'startupName': startupName,
        'startupData': startupData,
        'openBuyOrder': true,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Cor de fundo padrão do projeto
      backgroundColor: backgroundColor,
      // Barra superior da tela
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
        // Botão de voltar
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
      // FutureBuilder controla os estados de carregamento, erro e sucesso
      body: FutureBuilder<Map<String, dynamic>>(
        future: _startupDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            );
          }

          // Estado de erro caso a busca falhe    
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
          // Estado vazio caso a startup não seja encontrada
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
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
          // Resposta completa retornada pelo backend
          final fullResponse = snapshot.data!;
          // Dados reais da startup ficam dentro da chave "data"
          final startupData = Map<String, dynamic>.from(
            fullResponse['data'] ?? {},
          );

          // Nome da startup
          final nome = _getStringField(
            startupData,
            ['name'],
            'Nome da Startup',
          );

          // Descrição da startup
          final descricao = _getStringField(
            startupData,
            ['description'],
            'Descrição da startup não informada.',
          );

          // Estágio atual da startup
          final estagio = _getStringField(
            startupData,
            ['stage'],
            'Em operação',
          );

          // Tags relacionadas à startup
          final tags = _getListField(
            startupData,
            ['tags'],
          );

          // Caminho ou URL da imagem/logo da startup

          final logoPath = _getStringField(
            startupData,
            ['profilePicture'],
            '',
          );

          // Lista de sócios/fundadores

          final socios = _getListField(
            startupData,
            ['founders'],
          );

           // Lista de membros externos

          final membrosExternos = _getListField(
            startupData,
            ['externalMembers'],
          );

          // Lista de perguntas públicas

          final perguntasPublicas = _getListField(
            startupData,
            ['publicQuestions'],
          );

          // Lista de perguntas privadas

          final perguntasPrivadas = _getListField(
            startupData,
            ['privateQuestions'],
          );

          // Conteúdo principal com rolagem

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              24,
              12,
              24,
              110,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
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
                // Nome da startup
                Text(
                  nome,
                  style: GoogleFonts.montserrat(
                    color: primaryColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC3C0FF),
                          borderRadius: BorderRadius.circular(
                            7.5,
                          ),
                        ),
                        child: Text(
                          StartupModel.formatStage(
                            estagio,
                          ),
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
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
                 // Texto descritivo da startup
                Text(
                  descricao,
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    height: 1.45,
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 16),
                // Card com informações financeiras e botão de investir
                FinancialPanelCard(
                  startupData: startupData,
                  onInvestPressed: () {
                    _goToInvestScreen(
                      startupData,
                    );
                  },
                ),
                // Card com os sócios/fundadores
                FoundersCard(
                  socios: socios,
                ),
                // Card com membros externos
                ExternalMembersCard(
                  membrosExternos: membrosExternos,
                ),
                // Card com mais informações sobre a startup
                MoreAboutCard(
                  startupData: startupData,
                ),
                 // Card de perguntas públicas
                PublicQuestionsCard(
                  startupId: widget.startupId,
                  perguntasPublicas: perguntasPublicas,
                ),
                if(startupData['access']['isInvestor']) 
                // Mostra perguntas privadas apenas se o usuário for investidor da startup
                PrivateQuestionsCard(
                  startupId: widget.startupId,
                  perguntasPrivadas: perguntasPrivadas,
                ),
              ],
            ),
          );
        },
      ),
      // Barra inferior com a aba de Catálogo selecionada
      bottomNavigationBar: const AppBottomNavigation(
        selectedIndex: 1,
      ),
    );
  }
}
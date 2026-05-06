import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';  // Adicionando o import para usar Firebase Functions

import '../../../frame_cards/startup_detail/tag_startup.dart';
import '../../../frame_cards/startup_detail/financial_panel_card.dart';
import '../../../frame_cards/startup_detail/partners_card.dart';
import '../../../frame_cards/startup_detail/external_members_card.dart';
import '../../../frame_cards/startup_detail/more_about_card.dart';
import '../../../frame_cards/startup_detail/public_questions_card.dart';
import '../../../frame_cards/startup_detail/priv_questions_card.dart';

class StartupDetailScreen extends StatelessWidget {
  final String startupId;

  const StartupDetailScreen({super.key, required this.startupId});

  // Função para chamar a Firebase Function e pegar os dados da startup
  Future<Map<String, dynamic>> getStartupDetails() async {
    try {
      final functions = FirebaseFunctions.instance;
      final HttpsCallable callable = functions.httpsCallable('getStartupDetails');

      final result = await callable.call(<String, dynamic>{
        'startupId': startupId, // Passa o startupId para a função
      });

      // Retorna os dados da startup
      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      print('Erro ao buscar dados da startup: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Detalhes da Startup'),
        leading: IconButton(  // Adicionando a navegação de voltar
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2F3192)),
          onPressed: () {
            Navigator.pop(context);  // Volta para a tela anterior
          },
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: getStartupDetails(),  // Chama a função Firebase para pegar os dados
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar dados: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Startup não encontrada.'));
          }

          // Pegando os dados da startup
          var startupData = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                Center(
                  child: CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.grey.shade100,
                    child: Image.asset(
                      'assets/images/logo_nota_certa.png',
                      width: 80,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  startupData['name'] ?? 'Nome da Startup',
                  style: TextStyle(
                    color: Color(0xFF2F3192),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    TagStartup(texto: 'Em operação'),
                    const SizedBox(width: 8),
                    TagStartup(texto: 'Edtech'),
                  ],
                ),

                const SizedBox(height: 12),

                Text(
                  startupData['description'] ?? 'Descrição da Startup',
                  style: TextStyle(fontSize: 13),
                ),

                const SizedBox(height: 16),

                FinancialPanelCard(), // Exibe os cartões e outras informações
                const SizedBox(height: 16),
                PartnersCard(),
                const SizedBox(height: 16),
                ExternalMembersCard(),
                const SizedBox(height: 16),
                MoreAboutCard(),
                const SizedBox(height: 16),
                PublicQuestionsCard(),
                const SizedBox(height: 16),
                PrivateQuestionsCard(),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }
}
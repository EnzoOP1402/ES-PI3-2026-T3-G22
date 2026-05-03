/* Autor: Livia Lucizano */
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../frame_cards/startup_detail/tag_startup.dart';
import '../../../frame_cards/startup_detail/financial_panel_card.dart';
import '../../../frame_cards/startup_detail/partners_card.dart';
import '../../../frame_cards/startup_detail/external_members_card.dart';
import '../../../frame_cards/startup_detail/more_about_card.dart';
import '../../../frame_cards/startup_detail/public_questions_card.dart';
import '../../../frame_cards/startup_detail/priv_questions_card.dart';

class StartupDetailScreen extends StatelessWidget {
  const StartupDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final doc = FirebaseFirestore.instance
    .collection('Startups')
    .doc('vssvr99NOBWxxeqpFigp');
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.arrow_back_ios, color: Color(0xFF2F3192)),

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

              const Text(
                'NotaCerta LTDA',
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

              const Text(
                'Esta é uma descrição exemplo. Dentro dela, é necessário que contenha informações sobre os ativos da startup, qual é o seu nicho, seus sócios, país, estado e cidade sede.',
                style: TextStyle(fontSize: 13),
              ),

              const SizedBox(height: 16),

              FinancialPanelCard(),

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
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: Colors.pink,
        unselectedItemColor: const Color(0xFF2F3192),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb_outline),
            label: 'Catálogo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.wallet),
            label: 'Carteira',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Conta',
          ),
        ],
      ),
    );
  }
}
/* Autor: Livia Lucizano */
import 'package:flutter/material.dart';

import 'package:mescla_invest_app/core/widgets/startup_detail/base_card.dart';
import 'package:mescla_invest_app/core/widgets/startup_detail/section_title.dart';

class PrivateQuestionsCard extends StatelessWidget {
  const PrivateQuestionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('Perguntas privadas'),

          const SizedBox(height: 8),

          const Text(
            'Quer tirar suas dúvidas diretamente com a gente? Acesse nosso canal exclusivo e fale diretamente com quem está por trás da empresa.',
            style: TextStyle(fontSize: 13),
          ),

          const SizedBox(height: 12),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2F3192),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {},
            child: const Text('Chat privado'),
          ),
        ],
      ),
    );
  }
}
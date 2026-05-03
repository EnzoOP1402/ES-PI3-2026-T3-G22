/* Autor: Livia Lucizano */
import 'package:flutter/material.dart';

import 'package:mescla_invest_app/core/widgets/startup_detail/base_card.dart';
import 'package:mescla_invest_app/core/widgets/startup_detail/section_title.dart';

import 'question_item.dart';

class PublicQuestionsCard extends StatelessWidget {
  const PublicQuestionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SectionTitle('Perguntas públicas'),
              Spacer(),
              Text(
                'Ver tudo',
                style: TextStyle(
                  color: Colors.pink,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const Text('16 perguntas', style: TextStyle(fontSize: 12)),

          const SizedBox(height: 12),

          const QuestionItem(
            initial: 'J',
            name: 'Juliano Cardoso',
            date: '28/04/2026',
          ),

          const Divider(),

          const QuestionItem(
            initial: 'F',
            name: 'Fernanda Costa',
            date: '19/03/2026',
          ),

          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: const [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Faça sua pergunta...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Icon(Icons.send, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
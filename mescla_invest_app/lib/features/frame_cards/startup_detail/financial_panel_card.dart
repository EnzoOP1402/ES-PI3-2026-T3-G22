/* Autor: Livia Lucizano */
import 'package:flutter/material.dart';

import 'package:mescla_invest_app/core/widgets/startup_detail/base_card.dart';
import 'package:mescla_invest_app/core/widgets/startup_detail/section_title.dart';

class FinancialPanelCard extends StatelessWidget {
  const FinancialPanelCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('Painel financeiro'),

          const SizedBox(height: 10),

          const Text('Tokens emitidos:', style: TextStyle(fontWeight: FontWeight.bold)),
          const Text('100.000 tokens', style: TextStyle(fontSize: 18)),

          const SizedBox(height: 8),

          const Text('Capital aportado:', style: TextStyle(fontWeight: FontWeight.bold)),
          const Text('R\$250.000,00', style: TextStyle(fontSize: 18)),

          const SizedBox(height: 8),

          const Text('Valor atual dos tokens:', style: TextStyle(fontWeight: FontWeight.bold)),
          const Text('R\$10,00', style: TextStyle(fontSize: 18)),

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
            child: const Text('Investir'),
          ),
        ],
      ),
    );
  }
}
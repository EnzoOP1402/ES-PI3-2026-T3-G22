/* Autor: Livia Lucizano */
import 'package:flutter/material.dart';

import 'package:mescla_invest_app/core/widgets/startup_detail/base_card.dart';
import 'package:mescla_invest_app/core/widgets/startup_detail/section_title.dart';

import 'person_tile.dart';

class PartnersCard extends StatelessWidget {
  const PartnersCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('Sócios'),
          const SizedBox(height: 10),

          PersonTile(
            name: 'Livia Lucizano',
            role: 'Desenvolvedora',
            description: 'Participação societária: 50%',
          ),

          const SizedBox(height: 8),

          PersonTile(
            name: 'Laura Soares',
            role: 'Gerente de Projetos',
            description: 'Participação societária: 50%',
          ),
        ],
      ),
    );
  }
}
/* Autor: Livia Lucizano */
import 'package:flutter/material.dart';

import 'package:mescla_invest_app/core/widgets/startup_detail/base_card.dart';
import 'package:mescla_invest_app/core/widgets/startup_detail/section_title.dart';

import 'person_tile.dart';

class ExternalMembersCard extends StatelessWidget {
  const ExternalMembersCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle('Membros externos'),
          SizedBox(height: 10),
          PersonTile(
            name: 'José Souza',
            role: 'Investidor anjo',
            description: 'Mescla',
          ),
          SizedBox(height: 8),
          PersonTile(
            name: 'Carla Godoy',
            role: 'Investidora anjo',
            description: 'IBM',
          ),
        ],
      ),
    );
  }
}
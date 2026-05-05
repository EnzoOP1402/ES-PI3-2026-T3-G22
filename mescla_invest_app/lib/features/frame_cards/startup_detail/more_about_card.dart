/* Autor: Livia Lucizano */
import 'package:flutter/material.dart';

import 'package:mescla_invest_app/core/widgets/startup_detail/base_card.dart';
import 'package:mescla_invest_app/core/widgets/startup_detail/section_title.dart';

import 'info_button.dart';

class MoreAboutCard extends StatelessWidget {
  const MoreAboutCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SectionTitle('Mais sobre a startup'),
          SizedBox(height: 10),
          InfoButton(text: 'Sumário executivo'),
          SizedBox(height: 8),
          InfoButton(text: 'Pitch'),
          SizedBox(height: 8),
          InfoButton(text: 'Vídeo demo 1'),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mescla_invest_app/features/catalog/presentation/widgets/detailed_catalog_card_section.dart';

class MoreAboutCard extends StatelessWidget {
  final Map<String, dynamic> startupData;

  const MoreAboutCard({
    super.key,
    required this.startupData,
  });

  @override
  Widget build(BuildContext context) {
    final sumario =
    startupData['executiveSummary'] ??
    startupData['sumarioExecutivo'] ??
    'Sumário executivo não informado.';

    final pitch =
        startupData['pitch'] ??
        startupData['description'] ??
        'Pitch não informado.';

    final demoVideos = startupData['demoVideos'];

    final videoDemo = demoVideos is List && demoVideos.isNotEmpty
        ? demoVideos.first.toString()
        : startupData['videoDemo'] ?? 'Vídeo demo não informado.';

    return DetailedCatalogCardSection(
      title: 'Mais sobre',
      children: [
        _TextBlock(
          title: 'Sumário executivo',
          content: sumario,
        ),
        _TextBlock(
          title: 'Pitch',
          content: pitch,
        ),
        _TextBlock(
          title: 'Vídeo demo',
          content: videoDemo,
        ),
      ],
    );
  }
}

class _TextBlock extends StatelessWidget {
  final String title;
  final String content;

  const _TextBlock({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: const Color(0xFF2F3192),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: GoogleFonts.montserrat(
              fontSize: 13,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
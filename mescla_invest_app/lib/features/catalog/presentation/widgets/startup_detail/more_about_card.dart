/* Autor: Livia Lucizano */

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mescla_invest_app/features/catalog/presentation/widgets/startup_detail/detailed_catalog_card_section.dart';
import 'package:mescla_invest_app/features/catalog/presentation/widgets/startup_detail/detailed_catalog_modal_layout.dart';
import 'startup_video_player.dart';

class MoreAboutCard extends StatelessWidget {
  final Map<String, dynamic> startupData;

  const MoreAboutCard({
    super.key,
    required this.startupData,
  });

  String _getTextField(List<String> keys, String fallback) {
    for (final key in keys) {
      final value = startupData[key];

      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return fallback;
  }

  String _getVideoUrl() {
    final demoVideos = startupData['demoVideos'];

    if (demoVideos is List && demoVideos.isNotEmpty) {
      return demoVideos.first.toString();
    }

    final videoDemo = startupData['videoDemo'];

    if (videoDemo != null && videoDemo.toString().trim().isNotEmpty) {
      return videoDemo.toString();
    }

    return '';
  }

  void _openTextModal({
    required BuildContext context,
    required String title,
    required String content,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return DetailedCatalogModalLayout(
          title: title,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(content),
            ),
          ]
        );
      },
    );
  }

  void _openVideoModal({
    required BuildContext context,
    required String videoUrl,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        // return _MoreAboutBottomSheet(
        //   title: 'Vídeo demo',
        //   child: VideoDemoPlayer(videoUrl: videoUrl),
        // );
        return DetailedCatalogModalLayout(
          title: 'Vídeo demo',
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: VideoDemoPlayer(videoUrl: videoUrl),
            ),
          ]
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final sumario = _getTextField(
      ['executiveSummary'],
      'Sumário executivo não informado.',
    );

    final videoUrl = _getVideoUrl();
    final hasVideo = videoUrl.trim().isNotEmpty;

    return DetailedCatalogCardSection(
      title: 'Mais sobre a startup',
      children: [
        _MoreAboutOption(
          title: 'Sumário executivo',
          icon: Icons.article_outlined,
          onTap: () {
            _openTextModal(
              context: context,
              title: 'Sumário executivo',
              content: sumario,
            );
          },
        ),
        _MoreAboutOption(
          title: 'Vídeo demo',
          icon: Icons.play_circle_outline_rounded,
          onTap: hasVideo
              ? () {
                  _openVideoModal(
                    context: context,
                    videoUrl: videoUrl,
                  );
                }
              : () {
                  _openTextModal(
                    context: context,
                    title: 'Vídeo demo',
                    content: 'Vídeo demo não informado.',
                  );
                },
        ),
      ],
    );
  }
}

class _MoreAboutOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _MoreAboutOption({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  static const Color _primaryColor = Color(0xFF2F3192);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 13,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: _primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: _primaryColor,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
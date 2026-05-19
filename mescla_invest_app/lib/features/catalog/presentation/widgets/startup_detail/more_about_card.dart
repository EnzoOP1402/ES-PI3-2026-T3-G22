/* Autor: Livia Lucizano */

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mescla_invest_app/features/catalog/presentation/widgets/startup_detail/detailed_catalog_card_section.dart';
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
        return _MoreAboutBottomSheet(
          title: title,
          child: Text(
            content,
            style: GoogleFonts.montserrat(
              fontSize: 13,
              height: 1.5,
              color: Colors.black87,
              fontWeight: FontWeight.w400,
            ),
          ),
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
        return _MoreAboutBottomSheet(
          title: 'Vídeo demo',
          child: VideoDemoPlayer(videoUrl: videoUrl),
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

    final pitch = _getTextField(
      ['pitch', 'description', 'descricao'],
      'Pitch não informado.',
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
          title: 'Pitch',
          icon: Icons.campaign_outlined,
          onTap: () {
            _openTextModal(
              context: context,
              title: 'Pitch',
              content: pitch,
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
        color: Colors.white.withValues(alpha: 0.88),
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
                  size: 18,
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

class _MoreAboutBottomSheet extends StatelessWidget {
  final String title;
  final Widget child;

  const _MoreAboutBottomSheet({
    required this.title,
    required this.child,
  });

  static const Color _primaryColor = Color(0xFF2F3192);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.90,
      minChildSize: 0.65,
      maxChildSize: 0.96,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF5F5F5),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          color: _primaryColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.close_rounded,
                        color: _primaryColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: child,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
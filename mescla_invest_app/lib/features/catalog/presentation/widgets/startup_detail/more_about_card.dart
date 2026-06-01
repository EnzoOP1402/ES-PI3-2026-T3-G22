/* Autor: Livia Lucizano RA:25017514*/

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mescla_invest_app/features/catalog/presentation/widgets/startup_detail/detailed_catalog_card_section.dart';
import 'package:mescla_invest_app/features/catalog/presentation/widgets/startup_detail/detailed_catalog_modal_layout.dart';
import 'startup_video_player.dart';

/// Card que exibe opções de conteúdo adicional sobre a startup,
/// como sumário executivo e vídeo demo, cada um abrindo um modal ao ser tocado.
class MoreAboutCard extends StatelessWidget {
  /// Mapa com os dados da startup, incluindo sumário e URLs de vídeo.
  final Map<String, dynamic> startupData;

  const MoreAboutCard({
    super.key,
    required this.startupData,
  });

  /// Busca um campo de texto em [startupData] tentando múltiplas chaves.
  /// Retorna [fallback] se nenhuma chave produzir um valor não vazio.
  String _getTextField(List<String> keys, String fallback) {
    for (final key in keys) {
      final value = startupData[key];

      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return fallback;
  }

  /// Obtém a URL do vídeo demo da startup.
  /// Prioriza a lista [demoVideos] e cai para o campo [videoDemo] como fallback.
  /// Retorna string vazia se nenhum vídeo estiver disponível.
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

  /// Abre um modal de texto genérico com [title] e [content].
  /// Usado para exibir o sumário executivo ou mensagens de conteúdo ausente.
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

  /// Abre um modal com o player de vídeo demo da startup.
  void _openVideoModal({
    required BuildContext context,
    required String videoUrl,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
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
    // Obtém o sumário executivo com fallback para texto padrão.
    final sumario = _getTextField(
      ['executiveSummary'],
      'Sumário executivo não informado.',
    );

    final videoUrl = _getVideoUrl();

    // Verifica se há vídeo disponível para exibir o player ou mensagem de ausência.
    final hasVideo = videoUrl.trim().isNotEmpty;

    return DetailedCatalogCardSection(
      title: 'Mais sobre a startup',
      children: [
        // Opção de sumário executivo: sempre abre modal de texto.
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
        // Opção de vídeo demo: abre player se disponível, texto informativo caso contrário.
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

/// Widget interno que representa uma opção clicável do card "Mais sobre a startup".
/// Exibe um ícone, título e seta de navegação com efeito de toque (InkWell).
class _MoreAboutOption extends StatelessWidget {
  /// Texto descritivo da opção.
  final String title;

  /// Ícone exibido à esquerda da opção.
  final IconData icon;

  /// Callback disparado ao tocar na opção.
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
                // Ícone identificador da opção.
                Icon(
                  icon,
                  color: _primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 10),
                // Título da opção expandido para ocupar o espaço disponível.
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
                // Seta indicando que a opção é navegável.
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
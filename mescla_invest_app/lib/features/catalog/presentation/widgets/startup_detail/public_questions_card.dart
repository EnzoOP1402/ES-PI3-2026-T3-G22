/* Autor: Livia Lucizano */

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mescla_invest_app/features/catalog/presentation/widgets/detailed_catalog_card_section.dart';

class PublicQuestionsCard extends StatelessWidget {
  final List<dynamic> perguntasPublicas;

  const PublicQuestionsCard({
    super.key,
    required this.perguntasPublicas,
  });

  @override
  Widget build(BuildContext context) {
    return DetailedCatalogCardSection(
      title: 'Perguntas públicas',
      children: [
        if (perguntasPublicas.isEmpty)
          Text(
            'Nenhuma pergunta pública cadastrada.',
            style: GoogleFonts.montserrat(
              fontSize: 13,
              color: Colors.black87,
            ),
          )
        else
          ...perguntasPublicas.map((pergunta) {
            final data = Map<String, dynamic>.from(pergunta);

            final textoPergunta = data['pergunta'] ??
                data['question'] ??
                data['texto'] ??
                'Pergunta não informada';

            final resposta = data['resposta'] ??
                data['answer'] ??
                'Ainda não respondida.';

            final autor = data['autor'] ??
                data['author'] ??
                'Usuário';

            return _QuestionItem(
              pergunta: textoPergunta,
              resposta: resposta,
              autor: autor,
              isPrivate: false,
            );
          }).toList(),

        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              // Aqui depois você pode abrir modal ou navegar para tela de perguntas
            },
            icon: const Icon(Icons.add_comment_outlined),
            label: const Text('Fazer pergunta pública'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF353988),
              side: const BorderSide(
                color: Color(0xFF353988),
                width: 1.2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuestionItem extends StatelessWidget {
  final String pergunta;
  final String resposta;
  final String autor;
  final bool isPrivate;

  const _QuestionItem({
    required this.pergunta,
    required this.resposta,
    required this.autor,
    required this.isPrivate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isPrivate
                    ? Icons.lock_outline
                    : Icons.chat_bubble_outline,
                color: const Color(0xFF353988),
                size: 16,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  autor,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF353988),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            pergunta,
            style: GoogleFonts.montserrat(
              fontSize: 13,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            resposta,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              color: Colors.black54,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
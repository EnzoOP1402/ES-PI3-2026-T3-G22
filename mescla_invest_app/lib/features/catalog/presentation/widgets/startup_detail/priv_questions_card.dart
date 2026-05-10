/* Autor: Livia Lucizano */

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mescla_invest_app/features/catalog/presentation/widgets/startup_detail/detailed_catalog_card_section.dart';
class PrivateQuestionsCard extends StatelessWidget {
  final List<dynamic> perguntasPrivadas;

  const PrivateQuestionsCard({
    super.key,
    required this.perguntasPrivadas,
  });

  @override
  Widget build(BuildContext context) {
    return DetailedCatalogCardSection(
      title: 'Perguntas privadas',
      children: [
        Text(
          'Canal exclusivo para investidores que possuem tokens desta startup.',
          style: GoogleFonts.montserrat(
            fontSize: 13,
            color: Colors.black87,
            height: 1.4,
          ),
        ),

        const SizedBox(height: 12),

        if (perguntasPrivadas.isEmpty)
          Text(
            'Nenhuma pergunta privada cadastrada.',
            style: GoogleFonts.montserrat(
              fontSize: 13,
              color: Colors.black87,
            ),
          )
        else
          ...perguntasPrivadas.map((pergunta) {
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
                'Investidor';

            return _PrivateQuestionItem(
              pergunta: textoPergunta,
              resposta: resposta,
              autor: autor,
            );
          }).toList(),

        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              // Aqui depois você pode validar se o usuário é investidor
              // e abrir uma tela/modal de chat privado.
            },
            icon: const Icon(Icons.lock_outline),
            label: const Text('Abrir chat privado'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF353988),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                vertical: 13,
                horizontal: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: GoogleFonts.montserrat(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PrivateQuestionItem extends StatelessWidget {
  final String pergunta;
  final String resposta;
  final String autor;

  const _PrivateQuestionItem({
    required this.pergunta,
    required this.resposta,
    required this.autor,
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
              const Icon(
                Icons.lock_outline,
                color: Color(0xFF353988),
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
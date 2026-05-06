/* Autor: Enzo Olivato Pazian */

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// Widget modularizado para a criação dos conjuntos que representam
// cada pergunta exibida na página detalhada das startups

class QuestionItemTile extends StatefulWidget {
  final Map<String, dynamic> questionData;

  const QuestionItemTile({super.key, required this.questionData});

  @override
  State<QuestionItemTile> createState() => _QuestionItemTileState();
}

class _QuestionItemTileState extends State<QuestionItemTile> {
  bool _isExpanded = false;

  // Função auxiliar para formatar a data ISO que vem do backend
  String _formatDate(String? isoDate) {
    if (isoDate == null) return "";
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final String authorName = widget.questionData['authorName'] ?? 'Usuário';
    final String? photoUrl = widget.questionData['authorPhotoUrl'];
    final String text = widget.questionData['text'] ?? '';
    final String? answer = widget.questionData['answer'];
    final String createdAt = _formatDate(widget.questionData['createdAt']);
    final String answeredAt = _formatDate(widget.questionData['answeredAt']);
    
    // Variável que controla se a pergunta possui ou não resposta
    // para que possa renderizar a funcionalidade corretamente
    final bool hasAnswer = answer != null && answer.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Avatar (Foto ou Inicial)
              CircleAvatar(
                radius: 25,
                backgroundColor: const Color(0xFFA2A2A2),
                backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                child: photoUrl == null
                    ? Text(
                        authorName.isNotEmpty ? authorName[0].toUpperCase() : 'U',
                        style: GoogleFonts.montserrat(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              
              // 2. Conteúdo da Pergunta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authorName,
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      createdAt,
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      text,
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 3. Lógica Condicional da Resposta
                    if (!hasAnswer)
                      Text(
                        "Sem resposta",
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      )
                    else if (!_isExpanded)
                      GestureDetector(
                        onTap: () => setState(() => _isExpanded = true),
                        child: Text(
                          "Ver resposta",
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      )
                    else
                      // 4. Estrutura da Resposta Expandida
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            // Recolhe a resposta caso ela seja clicada novamente
                            onTap: () => setState(() => _isExpanded = false),
                            child: Row(
                              children: [
                                const Icon(Icons.subdirectory_arrow_right_rounded, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  "Resposta",
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            answeredAt,
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            answer,
                            style: GoogleFonts.montserrat(
                              fontSize: 13,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
          
          // Espaçamento
          const SizedBox(height: 12),

          // Linha divisória fina
          Divider(color: const Color(0xFFA2A2A2), thickness: 0.5, height: 1),
        ],
      ),
    );
  }
}
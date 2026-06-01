/* Autor: Livia Lucizano - RA:25017514*/

// Imports usados para criar o widget e aplicar a fonte personalizada
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Widget simples para exibir uma informação curta com título e valor
class MiniInfo extends StatelessWidget {
  // Texto do título da informação
  final String label;

  // Valor ou conteúdo exibido abaixo do título
  final String value;

  // Tamanho da fonte do título
  final int titleSize;

  // Tamanho da fonte do conteúdo
  final int contentSize;

  const MiniInfo({
    super.key,
    required this.label,
    required this.value,
    required this.titleSize,
    required this.contentSize
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Espaçamento interno do bloco de informação
      padding: const EdgeInsets.all(5),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exibe o título da informação
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              color: Colors.black,
              fontWeight: FontWeight.w800,
            ),
          ),

          // Exibe o valor da informação
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
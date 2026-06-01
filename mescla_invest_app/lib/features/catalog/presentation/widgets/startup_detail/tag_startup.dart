/* Autor: Livia Lucizano RA:25017514*/

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget reutilizável que exibe uma tag/etiqueta estilizada para categorizar startups.
/// Apresenta o texto em um container azul claro com bordas arredondadas.
class TagStartup extends StatelessWidget {
  /// Texto exibido dentro da tag.
  final String texto;

  const TagStartup({
    super.key,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Color(0xFF9FCEFF), // Azul claro de fundo da tag.
        borderRadius: BorderRadius.circular(7.5),
      ),
      child: Text(
        texto,
        style: GoogleFonts.montserrat(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
    );
  }
}
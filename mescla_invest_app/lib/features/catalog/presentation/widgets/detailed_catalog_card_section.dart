/* Autor: Enzo Olivato Pazian */

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Widget modularizado para a criação dos cards que representam
// cada sessão da página detalhada das startups

class DetailedCatalogCardSection extends StatelessWidget {
  // Título do card
  final String title;
  // Conteúdo do card
  final List<Widget> children;

  // Construtor do card
  const DetailedCatalogCardSection({
    super.key,
    // O título e o conteúdo são obrigatórios
    required this.title,
    required this.children
  });

  @override
  Widget build(BuildContext context) {
    // Retornando o card que será utilizado para agrupar os conteúdos de cada
    // sessão da página detalhada da startup
    return Card(
      // Definindo uma margem para o card
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      // Zerando a elevação (removendo a sombra)
      elevation: 0,
      // Garantindo que o conteúdo interno e o gradiente não excedam os limites do card
      clipBehavior: Clip.antiAlias,
      // Arredondando os cantos do card
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      // Definindo seu interior
      child: Container(
        // Definindo a largura como infinita (ocupa toda a largura da tela, exceto as margens)
        width: double.infinity,
        decoration: BoxDecoration(
          // Adicionando o gradiente
          gradient: LinearGradient(
            colors: [Color(0xFFDEDEDE), Color(0xFFD4D4D4)],
            // Colocando-o na diagonal
            begin: Alignment.topLeft,
            end: Alignment.bottomRight
          ),
        ),
        // Definindo o conteúdo interno do card
        child: Padding(
          // Definindo o espaçamento interno
          padding: EdgeInsetsGeometry.all(12),
          child: Column(
            // Alinhando os itens à esquerda
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título do Card
              Text(
                // Obtendo o valor trazido de fora
                title,
                // Estilizando o texto
                style: GoogleFonts.montserrat(
                  color: Color(0xFF353988),
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
              // Espaçamento padrão entre o título e o conteúdo
              SizedBox(height: 12,),
              // Conteúdo do card
              ...children
            ],
          ),
        ),
      ),
    );
  }
}
/* Autor: Enzo Olivato Pazian - 25001654 */

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Widget modularizado para a criação dos cards que representam
// cada sessão da página detalhada das startups

class DetailedCatalogModalLayout extends StatelessWidget {
  // Título do modal
  final String title;
  // Subtítulo do modal
  final String? subtitle;
  // Conteúdo do modal
  final List<Widget> children;
  // Altura do modal
  final double? height;
  
  const DetailedCatalogModalLayout({
    required this.title,
    this.subtitle,
    required this.children,
    this.height,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height == null ?
        MediaQuery.of(context).size.height * 0.9 :
        MediaQuery.of(context).size.height * (height!/10),
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20)
        )
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Espaçamento
          SizedBox(
            height: 8,
          ),
          // "Ícone" para arrastar o modal ára baixo
          Container(
            width: 52,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFFA2A2A2),
              borderRadius: BorderRadius.circular(5)
            ),
          ),
          // Espaçamento
          SizedBox(
            height: 12,
          ),
          // Cabeçalho com Stack para alinhamento independente
          SizedBox(
            width: double.infinity,
            child: Stack(
              // Centraliza os filhos por padrão
              alignment: Alignment.center,
              children: [
                // Título e Subtítulo (Sempre no centro)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.montserrat(
                        color: const Color(0xFF353988),
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                    if(subtitle != null)
                    SizedBox(
                      width: 180,
                      child: Text(
                        subtitle ?? '',
                        textAlign: .center,
                        style: GoogleFonts.montserrat(
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                // 2. Ícone de Fechar (Posicionado na esquerda)
                Positioned(
                  left: 12, // Margem da esquerda
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFF353988),
                      size: 48, // Tamanho conforme indicado na sua imagem
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Espaçamento
          SizedBox(
            height: 12,
          ),
          // Linha divisória
          Container(
            height: 1,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFA2A2A2)
            ),
          ),
          // Espaçamento
          SizedBox(
            height: 16,
          ),
          ...children
        ],
      ),
    );
  }
}
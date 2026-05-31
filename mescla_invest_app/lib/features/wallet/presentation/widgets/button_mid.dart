/*Gabriela Sichiroli Ferrari*/

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomOutlinedButton extends StatelessWidget {

  // Texto exibido no botão.
  final String text;

  // Ícone exibido ao lado do texto.
  final IconData icon;

  // Página para a qual o usuário será redirecionado ao clicar.
  final Widget page;

  // Cor utilizada na borda, ícone e texto do botão.
  final Color color;

  // Largura personalizada do botão.
  final double width;

  const CustomOutlinedButton({
    super.key,
    required this.text,
    required this.icon,
    required this.page,
    this.color = const Color(0xFF353988),
    this.width = 250,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: width,
        child: OutlinedButton.icon(

          // Navega para a página informada ao pressionar o botão.
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => page,
              ),
            );
          },

          // Ícone exibido no botão.
          icon: Icon(
            icon,
            color: color,
          ),

          // Texto exibido no botão.
          label: Text(
            text,
            style: GoogleFonts.montserrat(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          // Estilização do botão.
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              vertical: 12,
            ),

            // Configuração da borda.
            side: BorderSide(
              color: color,
              width: 2,
            ),

            // Define o arredondamento dos cantos.
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }
}
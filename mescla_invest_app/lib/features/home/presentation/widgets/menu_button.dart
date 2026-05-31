/*Autor: Gabriela Sichiroli Ferrari - RA: 25013763 */

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Widget reutilizável utilizado para exibir
// opções de menu na interface do aplicativo.
class MenuButton extends StatelessWidget {

  // Ícone exibido no botão.
  final IconData icon;

  // Texto exibido abaixo do ícone.
  final String label;

  // Função executada quando o botão é pressionado.
  final VoidCallback onTap;

  const MenuButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    // Cor principal utilizada nos ícones e textos.
    const Color primaryBlue =
        Color(0xFF34379B);

    return GestureDetector(

      // Executa a ação associada ao botão.
      onTap: onTap,

      child: Container(

        // Dimensões fixas do botão.
        width: 104,
        height: 112,

        decoration: BoxDecoration(

          // Cor de fundo do botão.
          color: const Color(0xFFE8E9EB),

          // Borda externa do botão.
          border: Border.all(
            color: const Color.fromARGB(
              36,
              0,
              0,
              0,
            ),
            width: 3,
          ),

          // Arredondamento dos cantos.
          borderRadius:
              BorderRadius.circular(20),
        ),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [

            // Ícone representativo da ação.
            Icon(
              icon,
              color: primaryBlue,
              size: 28,
            ),

            const SizedBox(height: 6),

            // Texto descritivo da ação.
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                color: primaryBlue,
                fontWeight:
                    FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
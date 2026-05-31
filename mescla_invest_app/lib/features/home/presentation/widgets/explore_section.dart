/*Autor: Gabriela Sichiroli Ferrari - RA: 25013763 */

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'menu_button.dart';

// Classe responsável por armazenar os dados
// necessários para criar um botão da seção de exploração.
class ExploreButtonData {

  // Ícone exibido no botão.
  final IconData icon;

  // Texto exibido no botão.
  final String label;

  // Função executada ao clicar no botão.
  final VoidCallback onTap;

  ExploreButtonData({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

// Widget responsável por exibir uma seção contendo
// um título e uma coleção de botões de navegação.
class ExploreSection extends StatelessWidget {

  // Título exibido no topo da seção.
  final String title;

  // Lista de botões que serão renderizados.
  final List<ExploreButtonData> buttons;

  const ExploreSection({
    super.key,
    required this.title,
    required this.buttons,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        // Título da seção.
        Text(
          title,
          style: GoogleFonts.montserrat(
            color: const Color(0xFF353988),
            fontSize: 24,
            fontWeight: FontWeight.w400,
          ),
        ),

        const SizedBox(height: 40),

        // Organiza os botões automaticamente em linhas,
        // quebrando para a próxima quando necessário.
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,

          children: buttons.map((button) {

            // Cria um MenuButton para cada item da lista.
            return MenuButton(
              icon: button.icon,
              label: button.label,
              onTap: button.onTap,
            );
          }).toList(),
        ),
      ],
    );
  }
}
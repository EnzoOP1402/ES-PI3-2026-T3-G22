/* Autor: Gabriela Sichiroli Ferrari */

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mescla_invest_app/routes/app_routes.dart';

// Widget responsável pela barra de navegação inferior
// utilizada em todas as telas principais do aplicativo.
class AppBottomNavigation extends StatelessWidget {

  // Índice da página atualmente selecionada.
  final int selectedIndex;

  const AppBottomNavigation({
    super.key,
    required this.selectedIndex,
  });

  // Realiza a navegação para a tela correspondente
  // ao item selecionado.
  void _onItemTapped(
    BuildContext context,
    int index,
  ) {

    // Evita recarregar a tela atual.
    if (index == selectedIndex) {
      return;
    }

    switch (index) {

      // Navega para a tela inicial.
      case 0:
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.home,
        );
        break;

      // Navega para o catálogo.
      case 1:
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.catalog,
        );
        break;

      // Navega para o balcão de negociações.
      case 2:
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.exchange,
        );
        break;

      // Navega para o dashboard.
      case 3:
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.dashboard,
        );
        break;

      // Navega para a carteira.
      case 4:
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.wallet,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(

      // Altura da barra de navegação.
      height: 75,

      // Cor de fundo da barra.
      backgroundColor: const Color(0xFFE8E9EB),

      // Cor do indicador do item selecionado.
      indicatorColor: const Color(0xFFDB0065),

      // Define qual item está selecionado.
      selectedIndex: selectedIndex,

      // Estilização dos textos dos itens.
      labelTextStyle:
          WidgetStateProperty.resolveWith<TextStyle>(
        (states) {

          // Estilo aplicado ao item selecionado.
          if (states.contains(
            WidgetState.selected,
          )) {
            return GoogleFonts.montserrat(
              fontSize: 13,
              color: const Color(0xFFDB0065),
              fontWeight: FontWeight.bold,
            );
          }

          // Estilo aplicado aos itens não selecionados.
          return GoogleFonts.montserrat(
            fontSize: 12,
            color: const Color(0xFF353988),
          );
        },
      ),

      // Executa a navegação ao selecionar um item.
      onDestinationSelected: (index) {
        _onItemTapped(
          context,
          index,
        );
      },

      // Lista de destinos disponíveis na navegação.
      destinations: const [

        // Tela Home.
        NavigationDestination(
          selectedIcon: Icon(
            Icons.home_rounded,
            color: Color(0xFFE8E9EB),
          ),
          icon: Icon(
            Icons.home_rounded,
            color: Color(0xFF353988),
          ),
          label: 'Home',
        ),

        // Tela Catálogo.
        NavigationDestination(
          selectedIcon: Icon(
            Icons.lightbulb_outline,
            color: Color(0xFFE8E9EB),
          ),
          icon: Icon(
            Icons.lightbulb_outline,
            color: Color(0xFF353988),
          ),
          label: 'Catálogo',
        ),

        // Tela Balcão.
        NavigationDestination(
          selectedIcon: Icon(
            Icons.attach_money,
            color: Color(0xFFE8E9EB),
          ),
          icon: Icon(
            Icons.attach_money,
            color: Color(0xFF353988),
          ),
          label: 'Balcão',
        ),

        // Tela Dashboard.
        NavigationDestination(
          selectedIcon: Icon(
            Icons.bar_chart_rounded,
            color: Color(0xFFE8E9EB),
          ),
          icon: Icon(
            Icons.bar_chart_rounded,
            color: Color(0xFF353988),
          ),
          label: 'Dashboard',
        ),

        // Tela Carteira.
        NavigationDestination(
          selectedIcon: Icon(
            Icons.wallet_rounded,
            color: Color(0xFFE8E9EB),
          ),
          icon: Icon(
            Icons.wallet_rounded,
            color: Color(0xFF353988),
          ),
          label: 'Carteira',
        ),
      ],
    );
  }
}
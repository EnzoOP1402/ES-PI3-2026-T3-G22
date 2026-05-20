/* Autor: Gabriela Sichiroli Ferrari */

import 'package:flutter/material.dart';
import 'package:mescla_invest_app/routes/app_routes.dart';

class AppBottomNavigation
    extends StatelessWidget {

  final int selectedIndex;

  const AppBottomNavigation({
    super.key,
    required this.selectedIndex,
  });

  void _onItemTapped(
    BuildContext context,
    int index,
  ) {

    if (index == selectedIndex) {
      return;
    }

    switch (index) {

      case 0:
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.home,
        );
        break;

      case 1:
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.catalog,
        );
        break;

      case 2:
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.exchange,
        );
        break;

      case 3:
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.dashboard,
        );
        break;

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
  height: 75,
  backgroundColor: const Color(0xFFE8E9EB),
  indicatorColor: const Color(0xFFDB0065),
  selectedIndex: selectedIndex,

  labelTextStyle:
      WidgetStateProperty.resolveWith<TextStyle>(
    (states) {

      if (states.contains(
        WidgetState.selected,
      )) {

        return const TextStyle(
          fontSize: 13,
          color: Color(0xFFDB0065),
          fontWeight: FontWeight.bold,
        );
      }

      return const TextStyle(
        fontSize: 12,
        color: Color(0xFF353988),
      );
    },
  ),

  onDestinationSelected: (index) {
    _onItemTapped(
      context,
      index,
    );
  },

  destinations: const [

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
    NavigationDestination(
      selectedIcon: Icon(
        Icons.account_balance_wallet_rounded,
        color: Color(0xFFE8E9EB),
      ),
      icon: Icon(
        Icons.account_balance_wallet_rounded,
        color: Color(0xFF353988),
      ),

      label: 'Carteira',
    ),
  ],
);
}}
// HISTÓRICO: 02/11/2026 — Gabriela Sichiroli Ferrari: harmonização visual e segurança de navegação.
import 'package:flutter/material.dart';
import 'package:mescla_invest_app/core/navigation/app_navigation.dart';
import 'package:mescla_invest_app/core/theme/app_colors.dart';
import 'package:mescla_invest_app/routes/app_routes.dart';

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({super.key, required this.selectedIndex});
  final int selectedIndex;
  static const routes = [AppRoutes.home, AppRoutes.catalog, AppRoutes.exchange, AppRoutes.dashboard, AppRoutes.wallet];

  @override
  Widget build(BuildContext context) => NavigationBar(
    selectedIndex: selectedIndex,
    onDestinationSelected: (i) => AppNavigation.openMainSection(context, routes[i]),
    destinations: const [
      NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded, color: AppColors.primary), label: 'Início'),
      NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore, color: AppColors.primary), label: 'Catálogo'),
      NavigationDestination(icon: Icon(Icons.swap_horiz_rounded), selectedIcon: Icon(Icons.swap_horiz_rounded, color: AppColors.primary), label: 'Balcão'),
      NavigationDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights, color: AppColors.primary), label: 'Painel'),
      NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet, color: AppColors.primary), label: 'Carteira'),
    ],
  );
}

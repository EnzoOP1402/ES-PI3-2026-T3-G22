/* Autor: Livia Lucizano */

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mescla_invest_app/features/catalog/presentation/widgets/startup_catalog/bottom_nav_item.dart';

class BottomCatalogNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const BottomCatalogNavigation({
    super.key, 
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      const BottomNavItem(
        icon: Icons.home_outlined,
        label: 'Início',
      ),
      const BottomNavItem(
        icon: Icons.lightbulb_outline,
        label: 'Catálogo',
      ),
      const BottomNavItem(
        icon: Icons.bar_chart_rounded,
        label: 'Dashboards',
      ),
      const BottomNavItem(
        icon: Icons.account_balance_wallet_outlined,
        label: 'Carteira',
      ),
      const BottomNavItem(
        icon: Icons.person_outline_rounded,
        label: 'Conta',
      ),
    ];

    return Container(
      height: 72,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isSelected = index == selectedIndex;

          return Expanded(
            child: InkWell(
              onTap: () => onTap(index),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    item.icon,
                    size: 22,
                    color: isSelected
                        ? const Color(0xFFDB0065)
                        : const Color(0xFF353988),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.label,
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected
                          ? const Color(0xFFDB0065)
                          : const Color(0xFF353988),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
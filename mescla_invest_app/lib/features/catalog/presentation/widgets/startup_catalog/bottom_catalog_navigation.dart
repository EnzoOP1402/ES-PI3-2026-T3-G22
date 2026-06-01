/* Autor: Livia Lucizano - RA:25017514 */

// Imports utilizados para construir a interface e aplicar fontes personalizadas
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mescla_invest_app/features/catalog/presentation/widgets/startup_catalog/bottom_nav_item.dart';

// Widget responsável por criar a barra de navegação inferior do catálogo
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
    // Lista com os itens exibidos na barra inferior
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

    // Estrutura visual da barra inferior
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
      // Organiza os itens lado a lado
      child: Row(
        children: List.generate(items.length, (index) {
          final item = items[index];
          // Verifica se o item atual é o selecionado
          final isSelected = index == selectedIndex;

          // Cada item ocupa o mesmo espaço dentro da barra
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
                  // Texto do item da navegação
                  Text(
                    item.label,
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      // Destaca o item selecionado com peso maior
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w600,
                          // Altera a cor conforme o item esteja selecionado ou não
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
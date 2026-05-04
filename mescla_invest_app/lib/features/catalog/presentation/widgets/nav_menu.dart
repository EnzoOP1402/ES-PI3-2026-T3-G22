// Autor: Murillo Iamarino Caravita

import 'package:flutter/material.dart';

class MenuInferior extends StatelessWidget {
  final int PaginaAtual;
  final ValueChanged<int> onItemSelected;

  const MenuInferior({
    super.key,
    required this.PaginaAtual,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: PaginaAtual,
      onTap: onItemSelected,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Início",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.auto_stories_outlined),
          label: "Catálogo",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.align_horizontal_left_outlined),
          label: "Dashboard",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "Perfil",
        ),
      ],
    );
  }
}
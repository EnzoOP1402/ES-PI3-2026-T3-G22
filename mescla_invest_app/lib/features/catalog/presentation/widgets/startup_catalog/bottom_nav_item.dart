/* Autor: Livia Lucizano - RA: 25017514*/

// Importa o pacote principal do Flutter
import 'package:flutter/material.dart';

// Classe simples usada para representar um item da barra de navegação
class BottomNavItem {
  // Ícone que será exibido no item
  final IconData icon;

  // Texto que identifica o item
  final String label;

  // Construtor que obriga informar o ícone e o texto
  const BottomNavItem({
    required this.icon,
    required this.label,
  });
}
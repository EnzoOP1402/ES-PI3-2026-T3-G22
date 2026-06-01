/* Autor: Livia Lucizano RA:25017514*/

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget reutilizável de chip selecionável para filtro de estágio.
/// Alterna entre estado selecionado (gradiente rosa) e não selecionado (branco)
/// com animação suave de transição.
class StageChip extends StatelessWidget {
  /// Texto exibido no chip.
  final String label;

  /// Valor que este chip representa no grupo de seleção.
  final String value;

  /// Valor atualmente selecionado no grupo, usado para determinar o estado visual.
  final String selectedValue;

  /// Callback disparado quando o usuário toca no chip.
  final ValueChanged<String> onSelected;

  const StageChip({
    super.key, 
    required this.label,
    required this.value,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Verifica se este chip é o atualmente selecionado.
    final isSelected = value == selectedValue;

    return GestureDetector(
      onTap: () => onSelected(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          // Gradiente rosa quando selecionado, branco sólido quando não.
          gradient: isSelected ? LinearGradient(colors: [const Color(0xFFDB0065), const Color(0xFFEF1E7E)]) : LinearGradient(colors: [Colors.white, Colors.white]),
          color: isSelected ? const Color(0xFFDB0065) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          // Borda rosa quando selecionado, cinza claro quando não.
          border: Border.all(
            color: isSelected
                ? const Color(0xFFDB0065)
                : const Color(0xFFDADADA),
          ),
        ),
        // Texto branco e negrito quando selecionado, escuro e regular quando não.
        child: Text(
          label,
          style: GoogleFonts.montserrat(
            color: isSelected ? Colors.white : Colors.black87,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
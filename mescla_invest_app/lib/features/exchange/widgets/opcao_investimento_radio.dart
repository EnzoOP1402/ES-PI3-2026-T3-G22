/* Autor: Livia Lucizano */

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mescla_invest_app/features/exchange/data/models/exchange_model.dart';

/// Widget reutilizável que representa uma opção de seleção de modo de ordem
/// (mercado ou limitada) no formato de radio button com título e descrição.
class OpcaoInvestimentoRadio extends StatelessWidget {
  /// Texto principal da opção exibido em destaque.
  final String titulo;

  /// Texto descritivo secundário que explica a opção ao usuário.
  final String descricao;

  /// Valor do [ModoOrdem] que este widget representa.
  final ModoOrdem value;

  /// Valor atualmente selecionado no grupo de radio buttons.
  final ModoOrdem groupValue;

  /// Callback disparado quando o usuário seleciona esta opção.
  final ValueChanged<ModoOrdem> onChanged;

  const OpcaoInvestimentoRadio({
    required this.titulo,
    required this.descricao,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Verifica se esta opção está atualmente selecionada.
    final bool selecionado = value == groupValue;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      // Permite selecionar a opção tocando em qualquer área do widget.
      onTap: () => onChanged(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Radio button com cor de destaque rosa/vermelho quando ativo.
            Radio<ModoOrdem>(
              value: value,
              groupValue: groupValue,
              activeColor: const Color(0xFFDB0065),
              visualDensity: VisualDensity.compact,
              onChanged: (value) {
                if (value != null) {
                  onChanged(value);
                }
              },
            ),
            const SizedBox(width: 2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título em negrito maior quando selecionado, menor quando não.
                  Text(
                    titulo,
                    style: GoogleFonts.montserrat(
                      color: Colors.black87,
                      fontSize: 13,
                      fontWeight:
                          selecionado ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Descrição sempre com estilo mais suave, independente da seleção.
                  Text(
                    descricao,
                    style: GoogleFonts.montserrat(
                      color: Colors.black54,
                      fontSize: 11,
                      height: 1.15,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
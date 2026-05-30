/* Autor: Livia Lucizano */

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mescla_invest_app/features/exchange/data/models/exchange_model.dart';

class OpcaoInvestimentoRadio extends StatelessWidget {
  final String titulo;
  final String descricao;
  final ModoOrdem value;
  final ModoOrdem groupValue;
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
    final bool selecionado = value == groupValue;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => onChanged(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
/* Autor: Livia Lucizano */

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mescla_invest_app/features/catalog/presentation/widgets/detailed_catalog_card_section.dart';

class FinancialPanelCard extends StatelessWidget {
  final Map<String, dynamic> startupData;
  final VoidCallback? onInvestPressed;

  const FinancialPanelCard({
    super.key,
    required this.startupData,
    this.onInvestPressed,
  });

  num _getNumberField(
    Map<String, dynamic> data,
    List<String> possibleKeys,
  ) {
    for (final key in possibleKeys) {
      final value = data[key];

      if (value is num) {
        return value;
      }

      if (value is String) {
        final parsed = num.tryParse(value.replaceAll(',', '.'));

        if (parsed != null) {
          return parsed;
        }
      }
    }

    return 0;
  }

  String _formatCurrency(num value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  Widget build(BuildContext context) {
    final tokensEmitidos = _getNumberField(
      startupData,
      [
        'totalTokensIssued',
        'tokensEmitidos',
        'totalTokensEmitidos',
      ],
    );

    final tokensDisponiveis = _getNumberField(
      startupData,
      [
        'tokensAvailable',
        'tokensDisponiveis',
      ],
    );

    final capitalAportadoCents = _getNumberField(
      startupData,
      [
        'capitalRaisedCents',
      ],
    );

    final capitalAportado = capitalAportadoCents > 0
        ? capitalAportadoCents / 100
        : _getNumberField(
            startupData,
            [
              'capitalAportado',
            ],
          );

    final valorTokenCents = _getNumberField(
      startupData,
      [
        'currentTokenPriceCents',
      ],
    );

    final valorToken = valorTokenCents > 0
        ? valorTokenCents / 100
        : _getNumberField(
            startupData,
            [
              'valorToken',
              'valorFixoTokens',
            ],
          );

    return DetailedCatalogCardSection(
      title: 'Painel financeiro',
      children: [
        _InfoRow(
          label: 'Tokens emitidos',
          value: tokensEmitidos.toStringAsFixed(0),
        ),
        _InfoRow(
          label: 'Tokens disponíveis',
          value: tokensDisponiveis.toStringAsFixed(0),
        ),
        _InfoRow(
          label: 'Capital aportado',
          value: _formatCurrency(capitalAportado),
        ),
        _InfoRow(
          label: 'Valor do token',
          value: _formatCurrency(valorToken),
        ),

        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: onInvestPressed,
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: const Color(0xFFE4007C),
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade400,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.trending_up_rounded,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Investir na startup',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 13,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 13,
              color: const Color(0xFF2F3192),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
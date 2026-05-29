/* Autor: Livia Lucizano */

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mescla_invest_app/features/catalog/presentation/widgets/startup_catalog/mini_info.dart';
import 'package:mescla_invest_app/features/catalog/presentation/widgets/startup_detail/detailed_catalog_card_section.dart';

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
        : capitalAportadoCents;

    final valorTokenCents = _getNumberField(
      startupData,
      [
        'currentTokenPriceCents',
      ],
    );

    final valorToken = valorTokenCents > 0
        ? valorTokenCents / 100
        : valorTokenCents;

    return DetailedCatalogCardSection(
      title: 'Painel financeiro',
      children: [
        MiniInfo(
          label: 'Tokens emitidos:',
          value: tokensEmitidos.toStringAsFixed(0),
          titleSize: 16,
          contentSize: 24,
        ),
        MiniInfo(
          label: 'Capital aportado:',
          value: _formatCurrency(capitalAportado),
          titleSize: 16,
          contentSize: 24,
        ),
        MiniInfo(
          label: 'Valor atual de um token:',
          value: _formatCurrency(valorToken),
          titleSize: 16,
          contentSize: 24,
        ),

        const SizedBox(height: 16),
        if(startupData['access']['canTradeTokens'])
        SizedBox(
          child: ElevatedButton(
            onPressed: onInvestPressed,
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: const Color(0xFF353988),
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
                  'Investir',
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

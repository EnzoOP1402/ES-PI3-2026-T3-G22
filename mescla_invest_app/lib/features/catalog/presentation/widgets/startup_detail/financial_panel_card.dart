/* Autor: Livia Lucizano RA:25017514*/

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mescla_invest_app/features/catalog/presentation/widgets/startup_catalog/mini_info.dart';
import 'package:mescla_invest_app/features/catalog/presentation/widgets/startup_detail/detailed_catalog_card_section.dart';

/// Card do painel financeiro exibido na tela de detalhes de uma startup.
/// Mostra tokens emitidos, capital aportado e valor atual do token,
/// além de um botão de investimento quando a negociação estiver habilitada.
class FinancialPanelCard extends StatelessWidget {
  /// Mapa com os dados financeiros e de acesso da startup.
  final Map<String, dynamic> startupData;

  /// Callback disparado ao pressionar o botão "Investir". Pode ser nulo.
  final VoidCallback? onInvestPressed;

  const FinancialPanelCard({
    super.key,
    required this.startupData,
    this.onInvestPressed,
  });

  /// Busca um campo numérico no [data] tentando múltiplas chaves possíveis.
  /// Suporta valores do tipo [num] e [String] (com vírgula ou ponto decimal).
  /// Retorna 0 se nenhuma chave produzir um valor válido.
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

  /// Formata um valor numérico para o padrão monetário brasileiro.
  /// Exemplo: 1500.5 → "R$ 1500,50"
  String _formatCurrency(num value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  Widget build(BuildContext context) {
    // Quantidade total de tokens emitidos pela startup.
    final tokensEmitidos = _getNumberField(
      startupData,
      [
        'totalTokensIssued',
      ],
    );

    // Capital aportado em centavos, convertido para reais se positivo.
    final capitalAportadoCents = _getNumberField(
      startupData,
      [
        'capitalRaisedCents',
      ],
    );

    final capitalAportado = capitalAportadoCents > 0
        ? capitalAportadoCents / 100
        : capitalAportadoCents;

    // Preço atual do token em centavos, convertido para reais se positivo.
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
        // Exibe total de tokens emitidos sem casas decimais.
        MiniInfo(
          label: 'Tokens emitidos:',
          value: tokensEmitidos.toStringAsFixed(0),
          titleSize: 16,
          contentSize: 24,
        ),
        // Exibe capital aportado formatado em reais.
        MiniInfo(
          label: 'Capital aportado:',
          value: _formatCurrency(capitalAportado),
          titleSize: 16,
          contentSize: 24,
        ),
        // Exibe valor atual de um token formatado em reais.
        MiniInfo(
          label: 'Valor atual de um token:',
          value: _formatCurrency(valorToken),
          titleSize: 16,
          contentSize: 24,
        ),

        const SizedBox(height: 16),
        // Botão "Investir" exibido apenas quando a negociação de tokens está habilitada.
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
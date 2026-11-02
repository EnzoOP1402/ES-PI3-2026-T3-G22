import 'package:flutter/material.dart';
import 'package:mescla_invest_app/core/theme/app_colors.dart';

/// Resumo obrigatório antes da simulação: fechar, cancelar ou voltar não credita.
Future<bool> confirmDemoDeposit(BuildContext context, String amount, String method) async {
  final answer = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Confirmar simulação'),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Método: $method'),
        const SizedBox(height: 8),
        Text('Valor: R\$ $amount', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
        const SizedBox(height: 12),
        const Text('Ambiente de testes. Confirmar adicionará saldo fictício à carteira. Cancelar não altera o saldo.'),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancelar')),
        FilledButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('Simular pagamento')),
      ],
    ),
  );
  return answer == true;
}

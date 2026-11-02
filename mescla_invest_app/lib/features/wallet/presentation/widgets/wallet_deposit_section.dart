// Autor original: Gabriela Sichiroli Ferrari — RA 25013763.
// HISTÓRICO: 02/11/2026 — Harmonização visual com a organização de componentes do HorseLife.
import 'package:flutter/material.dart';
import 'package:mescla_invest_app/core/theme/app_colors.dart';

class WalletDepositSection extends StatelessWidget {
  const WalletDepositSection({super.key, required this.onDeposit});
  final VoidCallback onDeposit;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Adicionar saldo', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
      const SizedBox(height: 6),
      const Text('Selecione PIX ou TED para iniciar uma simulação de depósito.', style: TextStyle(color: AppColors.textSecondary)),
      const SizedBox(height: 14),
      SizedBox(width: double.infinity, child: FilledButton.icon(
        onPressed: onDeposit,
        icon: const Icon(Icons.add_circle_outline),
        label: const Text('Depositar'),
      )),
    ],
  );
}

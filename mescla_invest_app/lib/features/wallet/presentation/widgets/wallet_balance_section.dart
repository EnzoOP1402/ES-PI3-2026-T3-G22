// Autor original: Gabriela Sichiroli Ferrari — RA 25013763.
// HISTÓRICO: 02/11/2026 — Harmonização visual com a organização de componentes do HorseLife.
import 'package:flutter/material.dart';
import 'package:mescla_invest_app/core/theme/app_colors.dart';
import 'package:mescla_invest_app/core/utils/currency_formatter.dart';

class WalletBalanceSection extends StatelessWidget {
  const WalletBalanceSection({super.key, required this.isObscured, required this.saldo, required this.onToggle});
  final bool isObscured;
  final double saldo;
  final VoidCallback onToggle;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(children: [
        const Icon(Icons.account_balance_wallet_outlined, color: AppColors.primary),
        const SizedBox(width: 9),
        Expanded(child: Text('Meu saldo', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700))),
        IconButton(
          tooltip: isObscured ? 'Mostrar saldo' : 'Ocultar saldo',
          onPressed: onToggle,
          icon: Icon(isObscured ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.primary),
        ),
      ]),
      const SizedBox(height: 8),
      Text(isObscured ? 'R\$ ••••••' : formatCurrency(saldo),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800)),
      const SizedBox(height: 6),
      const Text('Valores atualizados conforme sua carteira.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
    ],
  );
}

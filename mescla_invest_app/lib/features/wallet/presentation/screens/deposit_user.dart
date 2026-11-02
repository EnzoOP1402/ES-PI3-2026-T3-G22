// Autor original: Bernardo Castro Brandão de Oliveira — RA 25014953.
// HISTÓRICO: 02/11/2026 — Gabriela Sichiroli Ferrari: fluxo de depósito e cancelamento seguros; visual consistente.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mescla_invest_app/core/navigation/app_navigation.dart';
import 'package:mescla_invest_app/core/theme/app_colors.dart';
import 'package:mescla_invest_app/core/utils/deposit_amount.dart';
import 'package:mescla_invest_app/core/utils/snackbar_utils.dart';
import 'package:mescla_invest_app/core/widgets/app_section_card.dart';
import 'package:mescla_invest_app/core/widgets/custom_app_bar.dart';
import 'package:mescla_invest_app/features/wallet/presentation/screens/qrcode_pix.dart';
import 'package:mescla_invest_app/features/wallet/presentation/screens/ted_pay.dart';

/// Tela de preparação do depósito: nenhum saldo é alterado nesta etapa.
class WalletUser extends StatefulWidget {
  const WalletUser({super.key, required this.valor});
  final String valor; // Mantido por compatibilidade com a tela antiga.
  @override
  State<WalletUser> createState() => _WalletUserState();
}

class _WalletUserState extends State<WalletUser> {
  int? _selectedPayment;
  bool _cancelDialogOpen = false;

  Future<void> _cancelar() async {
    if (_cancelDialogOpen) return;
    _cancelDialogOpen = true;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancelar depósito?'),
        content: const Text('O valor digitado será descartado. Nenhum saldo foi creditado.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Continuar')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Descartar')),
        ],
      ),
    );
    _cancelDialogOpen = false;
    if (!mounted || confirmed != true) return;
    AppNavigation.cancelDeposit(context);
  }

  Future<void> _showValueModal() async {
    if (_selectedPayment == null) return;
    final payment = _selectedPayment!;
    final cents = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _DepositValueSheet(payment: payment),
    );
    if (!mounted || cents == null) return;
    final amount = DepositAmount.formatCents(cents);
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => payment == 1
        ? Qrcode(valor: amount, amountCents: cents)
        : Tedpay(valor: amount, amountCents: cents),
    ));
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, _) { if (!didPop) _cancelar(); },
    child: Scaffold(
      appBar: CustomAppBar(title: 'Depositar', showProfile: false, onBackPressed: _cancelar),
      body: SafeArea(child: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView(padding: const EdgeInsets.all(20), children: [
          Text('Como deseja depositar?', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text('Escolha o meio de pagamento para continuar.'),
          const SizedBox(height: 20),
          AppSectionCard(child: Column(children: [
            _choice(1, Icons.qr_code_rounded, 'PIX', 'Pagamento instantâneo (simulação)'),
            const Divider(height: 22),
            _choice(2, Icons.account_balance_outlined, 'TED', 'Transferência bancária (simulação)'),
          ])),
          const SizedBox(height: 24),
          FilledButton(onPressed: _selectedPayment == null ? null : _showValueModal, child: const Text('Escolher valor')),
          const SizedBox(height: 12),
          TextButton(onPressed: _cancelar, child: const Text('Cancelar depósito')),
        ]),
      ))),
    ),
  );

  Widget _choice(int value, IconData icon, String title, String subtitle) {
    final selected = _selectedPayment == value;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: () => setState(() => _selectedPayment = value),
      leading: CircleAvatar(
        backgroundColor: selected ? AppColors.surfaceAlt : AppColors.background,
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      trailing: Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, color: selected ? AppColors.accent : AppColors.textSecondary),
    );
  }
}

class _DepositValueSheet extends StatefulWidget {
  const _DepositValueSheet({required this.payment});
  final int payment;
  @override
  State<_DepositValueSheet> createState() => _DepositValueSheetState();
}

class _DepositValueSheetState extends State<_DepositValueSheet> {
  final _controller = TextEditingController();
  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Valor do ${widget.payment == 1 ? 'PIX' : 'TED'}',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary)),
        const SizedBox(height: 8),
        const Text('Digite o valor que deseja adicionar à sua carteira.'),
        const SizedBox(height: 22),
        TextField(
          controller: _controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: false),
          textInputAction: TextInputAction.done,
          inputFormatters: [_MoneyInputFormatter()],
          decoration: const InputDecoration(labelText: 'Valor', prefixText: 'R\$ ', hintText: '0,00'),
        ),
        const SizedBox(height: 12),
        const Text('O saldo não será alterado até a confirmação da simulação.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 24),
        SizedBox(width: double.infinity, child: FilledButton(
          onPressed: () {
            final cents = DepositAmount.parseCents(_controller.text);
            if (cents == null) {
              showErrorSnackBar(context, 'Informe um valor válido maior que zero.');
              return;
            }
            Navigator.pop(context, cents);
          },
          child: const Text('Continuar'),
        )),
        Center(child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar'))),
      ]),
    ),
  );
}

class _MoneyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return const TextEditingValue(text: '', selection: TextSelection.collapsed(offset: 0));
    final cents = int.tryParse(digits);
    if (cents == null || cents > 1000000000) return oldValue;
    final formatted = DepositAmount.formatCents(cents);
    return TextEditingValue(text: formatted, selection: TextSelection.collapsed(offset: formatted.length));
  }
}

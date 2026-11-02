// Autor original: Bernardo Castro Brandão de Oliveira — RA 25014953.
// HISTÓRICO: 02/11/2026 — Gabriela Sichiroli Ferrari: fluxo de depósito e cancelamento seguros; visual consistente.
import 'package:flutter/material.dart';
import 'package:mescla_invest_app/core/navigation/app_navigation.dart';
import 'package:mescla_invest_app/core/theme/app_colors.dart';
import 'package:mescla_invest_app/core/utils/snackbar_utils.dart';
import 'package:mescla_invest_app/core/widgets/app_section_card.dart';
import 'package:mescla_invest_app/core/widgets/custom_app_bar.dart';
import 'package:mescla_invest_app/features/wallet/data/services/deposit_simulation_service.dart';
import 'package:mescla_invest_app/features/wallet/presentation/screens/confirm.dart';
import 'package:mescla_invest_app/features/wallet/presentation/widgets/deposit_confirmation.dart';

class Tedpay extends StatefulWidget {
  const Tedpay({super.key, required this.valor, required this.amountCents, this.service});
  final DepositSimulationService? service;
  final String valor;
  final int amountCents;
  @override
  State<Tedpay> createState() => _TedpayState();
}

class _TedpayState extends State<Tedpay> {
  final _comprovanteController = TextEditingController();
  late final DepositSimulationService _service = widget.service ?? DepositSimulationService();
  bool _processing = false;
  bool _confirmDialogOpen = false;
  bool _cancelDialogOpen = false;

  @override
  void dispose() { _comprovanteController.dispose(); super.dispose(); }

  Future<void> _cancelar() async {
    if (_processing || _confirmDialogOpen || _cancelDialogOpen) return;
    _cancelDialogOpen = true;
    final ok = await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(
      title: const Text('Cancelar TED?'),
      content: const Text('A operação será descartada e não será registrado nenhum crédito.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Continuar')),
        FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Cancelar depósito')),
      ],
    ));
    _cancelDialogOpen = false;
    if (mounted && ok == true) AppNavigation.cancelDeposit(context);
  }

  Future<void> _confirmarTed() async {
    if (_processing || _confirmDialogOpen || _cancelDialogOpen) return;
    _confirmDialogOpen = true;
    final ok = await confirmDemoDeposit(context, widget.valor, 'TED');
    _confirmDialogOpen = false;
    if (!mounted || !ok) return;
    setState(() => _processing = true);
    try {
      await _service.confirmDemoPayment(widget.amountCents);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (_) => SuccessScreen(valor: widget.valor)));
    } catch (_) {
      if (mounted) showErrorSnackBar(context, 'Não foi possível registrar o depósito. Consulte sua carteira antes de tentar novamente.');
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, _) { if (!didPop) _cancelar(); },
    child: Scaffold(
      appBar: CustomAppBar(title: 'TED • demonstração', showProfile: false, onBackPressed: _cancelar),
      body: SafeArea(child: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: ListView(padding: const EdgeInsets.all(20), children: [
          Text('Dados para transferência', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text('Dados fictícios para testes. Não transfira dinheiro real.'),
          const SizedBox(height: 20),
          AppSectionCard(child: Column(children: [
            _line('Banco', '237 — Bradesco (exemplo)'),
            const Divider(height: 20),
            _line('Agência', '1234'),
            const Divider(height: 20),
            _line('Conta', '56789-0'),
            const Divider(height: 20),
            _line('CNPJ', '12.345.678/0001-99 (fictício)'),
            const Divider(height: 20),
            _line('Valor', 'R\$ ${widget.valor}'),
          ])),
          const SizedBox(height: 18),
          TextField(controller: _comprovanteController, decoration: const InputDecoration(labelText: 'Comprovante (opcional para testes)')),
          const SizedBox(height: 20),
          FilledButton(onPressed: _processing ? null : _confirmarTed,
            child: _processing ? const CircularProgressIndicator(color: Colors.white) : const Text('Simular confirmação da TED')),
          const SizedBox(height: 8),
          TextButton(onPressed: _processing ? null : _cancelar, child: const Text('Cancelar')),
        ]),
      ))),
    ),
  );

  Widget _line(String label, String value) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Expanded(child: Text(label, style: const TextStyle(color: AppColors.textSecondary))),
    Expanded(flex: 2, child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w600))),
  ]);
}

// Autor original: Bernardo Castro Brandão de Oliveira — RA 25014953.
// HISTÓRICO: 02/11/2026 — Gabriela Sichiroli Ferrari: fluxo de depósito e cancelamento seguros; visual consistente.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mescla_invest_app/core/navigation/app_navigation.dart';
import 'package:mescla_invest_app/core/theme/app_colors.dart';
import 'package:mescla_invest_app/core/utils/snackbar_utils.dart';
import 'package:mescla_invest_app/core/widgets/app_section_card.dart';
import 'package:mescla_invest_app/core/widgets/custom_app_bar.dart';
import 'package:mescla_invest_app/features/wallet/data/services/deposit_simulation_service.dart';
import 'package:mescla_invest_app/features/wallet/presentation/screens/confirm.dart';
import 'package:mescla_invest_app/features/wallet/presentation/widgets/deposit_confirmation.dart';
import 'package:qr_flutter/qr_flutter.dart';

class Qrcode extends StatefulWidget {
  const Qrcode({super.key, required this.valor, required this.amountCents, this.service});
  final DepositSimulationService? service;
  final String valor;
  final int amountCents;
  @override
  State<Qrcode> createState() => _QrcodeState();
}

class _QrcodeState extends State<Qrcode> {
  Timer? _timer;
  int _seconds = 600;
  int _version = 1;
  bool _processing = false;
  bool _confirmDialogOpen = false;
  bool _cancelDialogOpen = false;
  late final DepositSimulationService _service = widget.service ?? DepositSimulationService();

  String get _qrData => 'PIX-DEMO|VALOR:${widget.valor}|VERSAO:$_version';

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_seconds == 0) { _version++; _seconds = 600; }
        else { _seconds--; }
      });
    });
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  Future<void> _cancelar() async {
    if (_processing || _confirmDialogOpen || _cancelDialogOpen) return;
    _cancelDialogOpen = true;
    final discard = await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(
      title: const Text('Cancelar PIX?'),
      content: const Text('Ao cancelar, o valor não será creditado à sua carteira.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Continuar')),
        FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Cancelar depósito')),
      ],
    ));
    _cancelDialogOpen = false;
    if (mounted && discard == true) AppNavigation.cancelDeposit(context);
  }

  Future<void> _confirmar() async {
    if (_processing || _confirmDialogOpen || _cancelDialogOpen) return;
    _confirmDialogOpen = true;
    final ok = await confirmDemoDeposit(context, widget.valor, 'PIX');
    _confirmDialogOpen = false;
    if (!mounted || !ok) return;
    setState(() => _processing = true);
    try {
      await _service.confirmDemoPayment(widget.amountCents);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
        builder: (_) => SuccessScreen(valor: widget.valor),
      ));
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
      appBar: CustomAppBar(title: 'PIX • demonstração', showProfile: false, onBackPressed: _cancelar),
      body: SafeArea(child: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: ListView(padding: const EdgeInsets.all(20), children: [
          AppSectionCard(child: Column(children: [
            const Icon(Icons.qr_code_2_rounded, size: 36, color: AppColors.primary),
            const SizedBox(height: 10),
            const Text('Valor do depósito', style: TextStyle(color: AppColors.textSecondary)),
            Text('R\$ ${widget.valor}', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            QrImageView(data: _qrData, size: 215),
            const SizedBox(height: 14),
            const Text('QR Code ilustrativo — não é uma cobrança real.', textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text('Expira em ${(_seconds ~/ 60).toString().padLeft(2,'0')}:${(_seconds % 60).toString().padLeft(2,'0')}', style: const TextStyle(color: AppColors.textSecondary)),
          ])),
          const SizedBox(height: 18),
          const Text('Para testar o fluxo, confirme a simulação abaixo. Em produção, o saldo só pode ser creditado após confirmação do banco no servidor.', textAlign: TextAlign.center),
          const SizedBox(height: 24),
          FilledButton(onPressed: _processing ? null : _confirmar,
            child: _processing ? const CircularProgressIndicator(color: Colors.white) : const Text('Simular pagamento PIX')),
          const SizedBox(height: 8),
          TextButton(onPressed: _processing ? null : _cancelar, child: const Text('Cancelar')), 
        ]),
      ))),
    ),
  );
}

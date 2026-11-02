// Autor original: Bernardo Castro Brandão de Oliveira — RA 25014953.
// HISTÓRICO: 02/11/2026 — Gabriela Sichiroli Ferrari: fluxo de depósito e cancelamento seguros; visual consistente.
import 'package:flutter/material.dart';
import 'package:mescla_invest_app/core/navigation/app_navigation.dart';
import 'package:mescla_invest_app/core/theme/app_colors.dart';
import 'package:mescla_invest_app/core/widgets/app_section_card.dart';
import 'package:mescla_invest_app/core/widgets/custom_app_bar.dart';
import 'package:mescla_invest_app/routes/app_routes.dart';

/// Aparece somente depois que a operação de simulação retorna sucesso.
class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key, required this.valor});
  final String valor;
  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) AppNavigation.openMainSection(context, AppRoutes.wallet);
    },
    child: Scaffold(
    appBar: const CustomAppBar(title: 'Depósito registrado', showProfile: false, showBack: false),
    body: SafeArea(child: Center(child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: Padding(padding: const EdgeInsets.all(24), child: AppSectionCard(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.check_circle_rounded, size: 82, color: AppColors.success),
        const SizedBox(height: 16),
        Text('Simulação concluída!', textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary)),
        const SizedBox(height: 10),
        const Text('O crédito de demonstração foi registrado com sucesso.', textAlign: TextAlign.center),
        const SizedBox(height: 20),
        Text('R\$ $valor', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.success, fontWeight: FontWeight.w700)),
        const SizedBox(height: 32),
        SizedBox(width: double.infinity, child: FilledButton(
          onPressed: () => AppNavigation.openMainSection(context, AppRoutes.wallet),
          child: const Text('Voltar para carteira'),
        )),
      ]))),
    ))),
    ),
  );
}

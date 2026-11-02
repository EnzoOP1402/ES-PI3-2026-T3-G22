// HISTÓRICO: 02/11/2026 — Gabriela Sichiroli Ferrari: harmonização visual e segurança de navegação.
import 'package:flutter/material.dart';
import 'package:mescla_invest_app/routes/app_routes.dart';

/// Não usa pop() quando a rota pode ter sido aberta diretamente/deep link.
abstract final class AppNavigation {
  static void backOrHome(BuildContext context) {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    } else if (ModalRoute.of(context)?.settings.name != AppRoutes.home) {
      navigator.pushNamedAndRemoveUntil(AppRoutes.home, (_) => false);
    }
  }

  /// Telas principais substituem o histórico de abas; o botão voltar nunca
  /// termina acidentalmente numa tela de pagamento ou de login.
  static void openMainSection(BuildContext context, String route) {
    if (ModalRoute.of(context)?.settings.name == route) return;
    Navigator.of(context).pushNamedAndRemoveUntil(route, (_) => false);
  }

  /// Cancela o rascunho completo, sem reabrir telas antigas do fluxo.
  static void cancelDeposit(BuildContext context) {
    openMainSection(context, AppRoutes.wallet);
  }
}

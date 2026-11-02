// HISTÓRICO: 02/11/2026 — Gabriela Sichiroli Ferrari: harmonização visual e segurança de navegação.
import 'package:flutter/material.dart';
import 'package:mescla_invest_app/core/theme/app_colors.dart';

/// Modal de decisão; fechar/pressionar Não NUNCA executa [onConfirm].
class ConfirmExitDialog extends StatelessWidget {
  const ConfirmExitDialog({
    super.key,
    required this.title,
    required this.message,
    required this.question,
    required this.onConfirm,
    this.onCancel,
  });
  final String title;
  final String message;
  final String question;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(title, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
    content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(message),
      const SizedBox(height: 10),
      Text(question, style: const TextStyle(fontWeight: FontWeight.w600)),
    ]),
    actionsPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
    actions: [
      TextButton(
        onPressed: onCancel ?? () => Navigator.of(context).pop(),
        child: const Text('Não, manter'),
      ),
      FilledButton(
        onPressed: onConfirm,
        child: const Text('Sim, sair'),
      ),
    ],
  );
}

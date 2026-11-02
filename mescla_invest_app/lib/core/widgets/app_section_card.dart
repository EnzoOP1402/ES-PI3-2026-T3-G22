// HISTÓRICO: 02/11/2026 — Gabriela Sichiroli Ferrari: harmonização visual e segurança de navegação.
import 'package:flutter/material.dart';
import 'package:mescla_invest_app/core/theme/app_colors.dart';

/// Card reutilizável com os mesmos espaçamentos e hierarquia nas features.
class AppSectionCard extends StatelessWidget {
  const AppSectionCard({super.key, required this.child, this.padding = const EdgeInsets.all(20)});
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: padding,
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.border),
      boxShadow: [BoxShadow(
        color: AppColors.primary.withValues(alpha: 0.04),
        blurRadius: 15,
        offset: const Offset(0, 4),
      )],
    ),
    child: child,
  );
}

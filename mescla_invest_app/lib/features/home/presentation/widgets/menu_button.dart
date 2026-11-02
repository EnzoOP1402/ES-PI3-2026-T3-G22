// Autor original: Gabriela Sichiroli Ferrari — RA 25013763.
// HISTÓRICO: 02/11/2026 — Harmonização visual com o padrão de cards do HorseLife.
import 'package:flutter/material.dart';
import 'package:mescla_invest_app/core/theme/app_colors.dart';

class MenuButton extends StatelessWidget {
  const MenuButton({super.key, required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.surfaceAlt,
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: SizedBox(
        width: 135,
        height: 110,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, color: AppColors.primary, size: 30),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center, maxLines: 2,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary)),
          ]),
        ),
      ),
    ),
  );
}

// Autor original: Gabriela Sichiroli Ferrari — RA 25013763.
// HISTÓRICO: 02/11/2026 — Harmonização visual com o padrão de cards do HorseLife.
import 'package:flutter/material.dart';
import 'package:mescla_invest_app/core/theme/app_colors.dart';
import 'menu_button.dart';

class ExploreButtonData {
  const ExploreButtonData({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

class ExploreSection extends StatelessWidget {
  const ExploreSection({super.key, required this.title, required this.buttons});
  final String title;
  final List<ExploreButtonData> buttons;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
      const SizedBox(height: 16),
      Center(child: Wrap(spacing: 12, runSpacing: 12, alignment: WrapAlignment.center,
        children: buttons.map((button) => MenuButton(icon: button.icon, label: button.label, onTap: button.onTap)).toList(),
      )),
    ],
  );
}

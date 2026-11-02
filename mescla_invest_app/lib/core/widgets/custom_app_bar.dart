// HISTÓRICO: 02/11/2026 — Gabriela Sichiroli Ferrari: harmonização visual e segurança de navegação.
import 'package:flutter/material.dart';
import 'package:mescla_invest_app/core/navigation/app_navigation.dart';
import 'package:mescla_invest_app/core/theme/app_colors.dart';
import 'package:mescla_invest_app/routes/app_routes.dart';

/// AppBar consistente, com retorno seguro mesmo sem tela anterior.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key, required this.title, this.onBackPressed, this.showBack = true, this.showProfile = true});
  final String title;
  final VoidCallback? onBackPressed;
  final bool showBack;
  final bool showProfile;

  @override
  Widget build(BuildContext context) {
    final current = ModalRoute.of(context)?.settings.name;
    final canShowBack = showBack && (current != AppRoutes.home || Navigator.of(context).canPop());
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.primary,
      centerTitle: true,
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      leading: canShowBack ? IconButton(
        tooltip: 'Voltar',
        onPressed: onBackPressed ?? () => AppNavigation.backOrHome(context),
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
      ) : null,
      actions: [
        if (showProfile && current != AppRoutes.profile)
          IconButton(
            tooltip: 'Meu perfil',
            icon: const Icon(Icons.account_circle_outlined, size: 27),
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.profile),
          ),
        const SizedBox(width: 8),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, color: AppColors.border),
      ),
    );
  }
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);
}

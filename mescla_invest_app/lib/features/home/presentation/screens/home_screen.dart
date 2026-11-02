// Autor original: Gabriela Sichiroli Ferrari — RA 25013763.
// HISTÓRICO: 02/11/2026 — Harmonização visual com o padrão de cards do HorseLife.
import 'package:flutter/material.dart';
import 'package:mescla_invest_app/core/navigation/app_navigation.dart';
import 'package:mescla_invest_app/core/theme/app_colors.dart';
import 'package:mescla_invest_app/core/utils/currency_formatter.dart';
import 'package:mescla_invest_app/core/utils/snackbar_utils.dart';
import 'package:mescla_invest_app/core/widgets/app_section_card.dart';
import 'package:mescla_invest_app/core/widgets/app_bottom_navigation.dart';
import 'package:mescla_invest_app/core/widgets/custom_app_bar.dart';
import 'package:mescla_invest_app/features/auth/data/repositories/auth_repository.dart';
import 'package:mescla_invest_app/features/home/presentation/widgets/explore_section.dart';
import 'package:mescla_invest_app/features/wallet/data/repositories/wallet_repository.dart';
import 'package:mescla_invest_app/routes/app_routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  bool mostrarSaldo = false;
  bool isLoadingBalance = true;
  bool hasBalanceError = false;
  double saldo = 0;
  bool _loggingOut = false;

  @override
  void initState() { super.initState(); _loadBalance(); }

  Future<void> _loadBalance() async {
    if (mounted) setState(() { isLoadingBalance = true; hasBalanceError = false; });
    try {
      final wallet = await WalletRepository.instance.getWalletData();
      if (!mounted) return;
      setState(() { saldo = wallet.balance; isLoadingBalance = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() { hasBalanceError = true; isLoadingBalance = false; });
    }
  }

  Future<void> _handleLogout() async {
    if (_loggingOut) return;
    setState(() => _loggingOut = true);
    try {
      await AuthRepository.instance.logout();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
    } catch (_) {
      if (mounted) showErrorSnackBar(context, 'Não foi possível encerrar a sessão.');
    } finally {
      if (mounted) setState(() => _loggingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const CustomAppBar(title: 'MesclaInvest', showBack: false),
    body: SafeArea(child: Center(child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 740),
      child: RefreshIndicator(
        onRefresh: _loadBalance,
        child: ListView(padding: const EdgeInsets.fromLTRB(20, 24, 20, 40), children: [
          Text('Olá, seja bem-vindo!', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800)),
          const SizedBox(height: 5),
          const Text('Acompanhe seus investimentos e descubra oportunidades.', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          AppSectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.account_balance_wallet_outlined, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(child: Text('Saldo disponível', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700))),
              IconButton(tooltip: mostrarSaldo ? 'Ocultar saldo' : 'Mostrar saldo', onPressed: () => setState(() => mostrarSaldo = !mostrarSaldo),
                icon: Icon(mostrarSaldo ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.primary)),
            ]),
            const SizedBox(height: 8),
            if (isLoadingBalance) const LinearProgressIndicator()
            else if (hasBalanceError) ...[
              const Text('Saldo indisponível no momento.', style: TextStyle(color: AppColors.error)),
              TextButton.icon(onPressed: _loadBalance, icon: const Icon(Icons.refresh), label: const Text('Tentar novamente')),
            ] else Text(mostrarSaldo ? formatCurrency(saldo) : 'R\$ ••••••',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800)),
            const SizedBox(height: 15),
            SizedBox(width: double.infinity, child: OutlinedButton.icon(
              onPressed: () => AppNavigation.openMainSection(context, AppRoutes.wallet),
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Acessar carteira'),
            )),
          ])),
          const SizedBox(height: 22),
          AppSectionCard(child: ExploreSection(title: 'Explore o aplicativo', buttons: [
            ExploreButtonData(icon: Icons.explore_outlined, label: 'Catálogo', onTap: () => AppNavigation.openMainSection(context, AppRoutes.catalog)),
            ExploreButtonData(icon: Icons.swap_horiz_rounded, label: 'Balcão', onTap: () => AppNavigation.openMainSection(context, AppRoutes.exchange)),
            ExploreButtonData(icon: Icons.wallet_outlined, label: 'Carteira', onTap: () => AppNavigation.openMainSection(context, AppRoutes.wallet)),
            ExploreButtonData(icon: Icons.insights_rounded, label: 'Dashboard', onTap: () => AppNavigation.openMainSection(context, AppRoutes.dashboard)),
            ExploreButtonData(icon: Icons.person_outline_rounded, label: 'Perfil', onTap: () => Navigator.of(context).pushNamed(AppRoutes.profile)),
          ])),
          const SizedBox(height: 22),
          TextButton.icon(
            onPressed: _loggingOut ? null : _handleLogout,
            icon: const Icon(Icons.logout_rounded),
            label: Text(_loggingOut ? 'Saindo…' : 'Sair da conta'),
          ),
        ]),
      ),
    ))),
    bottomNavigationBar: const AppBottomNavigation(selectedIndex: 0),
  );
}

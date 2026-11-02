/* Autor original da composição de MaterialApp: Enzo Olivato Pazian - 25001654 */
// HISTÓRICO DE ALTERAÇÕES
// 02/11/2026 — Gabriela Sichiroli Ferrari (RA 25013763): extração da configuração de aplicação antes embutida em main.dart.

import 'package:flutter/material.dart';
import 'package:mescla_invest_app/app/theme/app_theme.dart';
import 'package:mescla_invest_app/core/widgets/auth_wrapper.dart';
import 'package:mescla_invest_app/features/auth/presentation/screens/login_screen.dart';
import 'package:mescla_invest_app/features/auth/presentation/screens/password_recovery_screen.dart';
import 'package:mescla_invest_app/features/auth/presentation/screens/register_screen.dart';
import 'package:mescla_invest_app/features/dashboard/presentation/screens/dashboard.dart';
import 'package:mescla_invest_app/features/exchange/presentation/screens/exchange.dart';
import 'package:mescla_invest_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:mescla_invest_app/features/home/presentation/screens/home_screen.dart';
import 'package:mescla_invest_app/features/catalog/presentation/screens/startup_catalog_screen.dart';
import 'package:mescla_invest_app/features/wallet/presentation/screens/wallet_screen.dart';
import 'package:mescla_invest_app/features/exchange/presentation/screens/ordem_form_screen.dart';
import 'package:mescla_invest_app/features/exchange/presentation/screens/ordem_sucesso_screen.dart';
import 'package:mescla_invest_app/routes/app_routes.dart';

/// Composição central das rotas e do tema do MesclaInvest.
class MesclaInvest extends StatelessWidget {
  const MesclaInvest({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MesclaInvest',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: '/',
      routes: {
        '/': (_) => const AuthWrapper(),
        AppRoutes.login: (_) => LoginScreen(),
        AppRoutes.register: (_) => RegisterScreen(),
        AppRoutes.recover: (_) => PasswordRecoveryScreen(),
        AppRoutes.catalog: (_) => const Catalogo(),
        AppRoutes.home: (_) => const HomeScreen(),
        AppRoutes.profile: (_) => const ProfileScreen(),
        AppRoutes.dashboard:(_) => const DashboardScreen(),
        AppRoutes.wallet:(_) => const WalletScreen(),
        AppRoutes.exchange:(_) => const ExchangeScreen(),
        AppRoutes.ordemForm: (_) => const OrdemFormScreen(),
        AppRoutes.ordemSucesso: (_) => const OrdemSucessoScreen()
      },
    );
  }
}

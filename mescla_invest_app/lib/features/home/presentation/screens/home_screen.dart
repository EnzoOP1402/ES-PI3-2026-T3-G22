/* Autor: Bernardo Castro Brandão de Oliveira */
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mescla_invest_app/core/utils/snackbar_utils.dart';
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
  double saldo = 0;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    try {
      final wallet =
          await WalletRepository.instance.getWalletData();

      if (mounted) {
        setState(() {
          saldo = wallet.balance;
          isLoadingBalance = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingBalance = false;
        });

        showErrorSnackBar(
          context,
          'Erro ao carregar saldo',
        );
      }
    }
  }

Future<void> _handleLogout() async {
    try {
      // Efetua o sign out no Firebase Auth
      await AuthRepository.instance.logout();

      if (mounted) {
        // Voltando para o início da pilha (tela inicial)
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        // Voltando para o início da pilha (tela inicial)
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(context, 'Erro ao sair: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9D9D9),
      appBar: const CustomAppBar(
        title: 'MesclaInvest',
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 14),

              Text(
                'Saldo do Usuário:',
                style: GoogleFonts.montserrat(
                  fontSize: 25,
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                   mostrarSaldo
                        ? 'R\$ ${saldo.toStringAsFixed(2)}'
                        : '— —',
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 7),

              GestureDetector(
                onTap: () {
                  setState(() {
                    mostrarSaldo = !mostrarSaldo;
                  });
                },
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Icon(
                      mostrarSaldo
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 18,
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      mostrarSaldo
                          ? 'Ocultar'
                          : 'Mostrar',
                      style: GoogleFonts.montserrat(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              const Divider(
                height: 1,
                thickness: 1,
                color: Colors.black,
              ),

              const SizedBox(height: 28),

              ExploreSection(
                title: 'Explore Mais',
                buttons: [
                  ExploreButtonData(
                    icon: Icons.lightbulb_outline,
                    label: 'Catálogo',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.catalog,
                      );
                    },
                  ),

                  ExploreButtonData(
                    icon: Icons.attach_money,
                    label: 'Balcão',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.exchange,
                      );
                    },
                  ),

                  ExploreButtonData(
                    icon:
                    Icons.wallet_rounded,
                    label: 'Carteira',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.wallet,
                      );
                    },
                  ),

                  ExploreButtonData(
                    icon: Icons.bar_chart_rounded,
                    label: 'Dashboard',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.dashboard,
                      );
                    },
                  ),

                  ExploreButtonData(
                    icon: Icons.person,
                    label: 'Perfil',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.profile,
                      );
                    },
                  ),

                  ExploreButtonData(
                    icon: Icons.logout,
                    label: 'Sair',
                    onTap: () async {
                      await _handleLogout();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
        bottomNavigationBar: const AppBottomNavigation(
        selectedIndex: 0,
      ),
    );
  }
}
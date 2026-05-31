/* Autor: Rafael Henrique dos Santos Inácio */

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mescla_invest_app/core/utils/snackbar_utils.dart';
import 'package:mescla_invest_app/core/widgets/app_bottom_navigation.dart';
import 'package:mescla_invest_app/core/widgets/custom_app_bar.dart';
import 'package:mescla_invest_app/features/wallet/data/models/token_model.dart';
import 'package:mescla_invest_app/features/wallet/data/models/wallet_model.dart';
import 'package:mescla_invest_app/features/wallet/data/repositories/wallet_repository.dart';
import 'package:mescla_invest_app/features/wallet/presentation/screens/my_offers_screen.dart';
import 'package:mescla_invest_app/features/wallet/presentation/screens/transaction_history_screen.dart';
import 'package:mescla_invest_app/features/wallet/presentation/widgets/button_mid.dart';
import 'package:mescla_invest_app/features/wallet/presentation/widgets/wallet_balance_section.dart';
import 'package:mescla_invest_app/features/wallet/presentation/widgets/wallet_deposit_section.dart';
import 'package:mescla_invest_app/features/wallet/presentation/widgets/wallet_tokens_list.dart';
import 'deposit_user.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});
  @override
  State<WalletScreen> createState() => _WalletScreenState();
}
class _WalletScreenState extends State<WalletScreen> {
  bool _isObscured = false;
  Future<WalletDetails>? _walletFuture;
  final Color _backgroundColor = const Color(0xFFE6E6E6);
  List<TokenModel> _tokens = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _walletFuture = WalletRepository.instance.getWalletData();
    _loadTokens();
  }

  void _toggleVisibility() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }
  Future<void> _loadTokens() async {
  try {
    final tokens = await WalletRepository.instance.getTokensListByUser();

    setState(() {
      _tokens = tokens;
      _isLoading = false;
    });
  } catch (e) {
    setState(() {
      _isLoading = false;
    });

    showErrorSnackBar(
      context,
      'Erro ao carregar tokens.',
    );
  }
}

  void _goToDeposit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WalletUser(
          valor: '0,00',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: CustomAppBar(
        title: 'Carteira',
      ),
      body: SafeArea(
        child: FutureBuilder<WalletDetails>(
          future: _walletFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF353988),
                ),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Erro ao carregar carteira: ${snapshot.error}',
                ),
              );
            }
            final wallet = snapshot.data;
            return SingleChildScrollView(
              child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
              child: Column(
                children: [
                  WalletBalanceSection(
                    isObscured: _isObscured,
                    saldo: wallet?.balance ?? 0,
                    onToggle: _toggleVisibility,
                  ),
                  const SizedBox(height: 16),
                  Divider(color: Colors.grey,thickness: 1,),
                  const SizedBox(height: 16),
                  Center(
                    child: WalletDepositSection(
                      onDeposit: _goToDeposit,
                    ),
                  ),

                  const SizedBox(height: 16),
                  Divider(color: Colors.grey,thickness: 1,height: 20),
                  Divider(color: Colors.transparent,thickness: 40,),
                  Center(
                    child: CustomOutlinedButton(
                      text: 'Minhas ofertas',
                      icon: Icons.currency_exchange,
                      page: const MyOffersScreen(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: CustomOutlinedButton(
                      text: 'Histórico de compras',
                      icon: Icons.history,
                      page: const TransactionHistoryScreen(),
                    ),
                  ),
                  Divider(color: Colors.transparent,thickness: 40,),
                  Divider(color: Colors.grey,thickness: 1,height: 20),
                  const SizedBox(height: 16),
                  /// TOKENS
                  Center(
                    child: Text(
                      'Lista de Tokens adquiridos',
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  WalletTokensList(
                    tokens: _tokens,
                    isObscured: _isObscured,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
             )
            );
          },
        ),
      ),
      bottomNavigationBar:
        const AppBottomNavigation(
        selectedIndex: 4,
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Certifique-se de ter o intl no pubspec.yaml para formatar moedas
import 'package:mescla_invest_app/core/utils/snackbar_utils.dart';
import '../data/repositories/wallet_repository.dart';
import '../data/models/wallet_model.dart';
import 'wallet_user.dart'; // Import da tela de depósito (Pix/Ted)

class WalletMainScreen extends StatefulWidget {
  const WalletMainScreen({Key? key}) : super(key: key);

  @override
  State<WalletMainScreen> createState() => _WalletMainScreenState();
}

class _WalletMainScreenState extends State<WalletMainScreen> {
  bool _isObscured = false;
  Future<WalletDetails>? _walletFuture;

  final Color _primaryBlue = const Color(0xFF3B428B);
  final Color _backgroundColor = const Color(0xFFEAEAEA);
  final Color _cardColor = const Color(0xFFDFDFDF);
  final Color _activeNavColor = const Color(0xFFE5006D);
  final Color _inactiveNavColor = const Color(0xFF6B7280);

  @override
  void initState() {
    super.initState();
    // Dispara a busca dos dados do Firebase assim que a tela inicia
    _walletFuture = WalletRepository.instance.getWalletData();
  }

  // Função auxiliar para formatar em formato de moeda Real (R$)
  String _formatCurrency(double value) {
    return NumberFormat.simpleCurrency(locale: 'pt_BR').format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        bottom: false,
        child: FutureBuilder<WalletDetails>(
          future: _walletFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF353988)),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Erro ao carregar carteira: ${snapshot.error}'),
              );
            }

            final wallet = snapshot.data;
            final double saldoReal = wallet?.balance ?? 0.0;
            final List<UserTokenModel> tokensAdquiridos = wallet?.tokens ?? [];

            return Column(
              children: [
                // 1. App Bar Customizado
                Container(
                  padding: const EdgeInsets.only(
                    top: 20,
                    bottom: 30,
                    left: 16,
                    right: 16,
                  ),
                  decoration: BoxDecoration(
                    color: _primaryBlue,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Text(
                          'Carteira',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 2. Seção de Saldo (Dinâmico)
                        const Text(
                          'Saldo do Usuário:',
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isObscured ? '-- --' : _formatCurrency(saldoReal),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () =>
                              setState(() => _isObscured = !_isObscured),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isObscured
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                size: 18,
                                color: Colors.black87,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _isObscured ? 'Mostrar' : 'Ocultar',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        // 3. Seção de Depósito (Ação Real)
                        const Text(
                          'Clique abaixo para depositar um\nvalor para seu saldo:',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: 160,
                          height: 45,
                          child: ElevatedButton(
                            onPressed: () {
                              // Redireciona para a tela de escolha Pix/Ted (WalletUser)
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const WalletUser(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Depositar',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // 4. Seção de Lista de Tokens (Dinâmica)
                        const Text(
                          'Lista de Tokens adquiridos',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(minHeight: 220),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _cardColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: _isObscured
                              ? Column(
                                  children: List.generate(
                                    4,
                                    (index) => Container(
                                      height: 40,
                                      margin: const EdgeInsets.only(bottom: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        border: Border.all(
                                          color: Colors.black26,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                )
                              : tokensAdquiridos.isEmpty
                              ? const Center(
                                  child: Text(
                                    'Você ainda não possui tokens.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: tokensAdquiridos.length,
                                  itemBuilder: (context, index) {
                                    final token = tokensAdquiridos[index];
                                    return ListTile(
                                      title: Text(
                                        token.startupName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      trailing: Text(
                                        '${token.quantity} Tokens',
                                        style: TextStyle(
                                          color: _primaryBlue,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),

                        const SizedBox(height: 30),

                        // 5. Botão Histórico de Compras
                        OutlinedButton.icon(
                          onPressed: () {
                            showErrorSnackBar(
                              context,
                              "Histórico de transações será carregado aqui.",
                            );
                          },
                          icon: Icon(Icons.history, color: _primaryBlue),
                          label: Text(
                            'Histórico de compras',
                            style: TextStyle(
                              color: _primaryBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            side: const BorderSide(color: Colors.black26),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // 6. Bottom Navigation Bar Customizado
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavItem(Icons.home_outlined, 'Início', false),
                      _buildNavItem(Icons.lightbulb_outline, 'Catálogo', false),
                      _buildNavItem(Icons.bar_chart, 'Dashboards', false),
                      _buildNavItem(
                        Icons.account_balance_wallet,
                        'Carteira',
                        true,
                      ),
                      _buildNavItem(Icons.person_outline, 'Conta', false),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    final color = isActive ? _activeNavColor : _inactiveNavColor;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

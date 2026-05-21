/* Autor: Rafael Henrique dos Santos Inácio */

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mescla_invest_app/core/widgets/app_bottom_navigation.dart';
import 'package:mescla_invest_app/core/widgets/custom_app_bar.dart';
import 'package:mescla_invest_app/core/utils/snackbar_utils.dart';
import 'package:mescla_invest_app/features/wallet/data/models/wallet_model.dart';
import 'package:mescla_invest_app/features/wallet/data/models/token_model.dart';
import 'package:mescla_invest_app/features/wallet/data/repositories/wallet_repository.dart';

import 'deposit_user.dart';
import 'my_offers_screen.dart'; // Importação da ecrã de Minhas Ofertas

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  bool _isObscured = false;
  Future<WalletDetails>? _walletFuture;

  // Paleta de cores do projeto
  final Color _primaryBlue = const Color(0xFF353988);
  final Color _backgroundColor = const Color(0xFFE6E6E6);
  final Color _cardColor = const Color(0xFFD4D4D4);

  // Lista fixa de tokens local inserida diretamente no código (Passo 2)
  final List<TokenModel> _meusTokens = [
    TokenModel(
      startupId: '1',
      startupName: 'PetMatch',
      tokenName: 'PMTK',
      quantity: 790,
    ),
    TokenModel(
      startupId: '2',
      startupName: 'NotaCerta',
      tokenName: 'NCTK',
      quantity: 790,
    ),
    TokenModel(
      startupId: '3',
      startupName: 'HealthVibe',
      tokenName: 'HVTK',
      quantity: 790,
    ),
    TokenModel(
      startupId: '4',
      startupName: 'MetaLive',
      tokenName: 'MLTK',
      quantity: 790,
    ),
    TokenModel(
      startupId: '5',
      startupName: 'CardVision',
      tokenName: 'CVTK',
      quantity: 790,
    ),
  ];

  @override
  void initState() {
    super.initState();

    // Dispara a busca do saldo do utilizador logado no Firebase
    _walletFuture = WalletRepository.instance.getWalletData();
  }

  // Função auxiliar para formatar valores em formato de moeda Real (R$)
  String _formatCurrency(double value) {
    return NumberFormat.simpleCurrency(locale: 'pt_BR').format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: CustomAppBar(
        title: 'Carteira',
      ),

      body: SafeArea(
        bottom: false,

        child: FutureBuilder<WalletDetails>(
          future: _walletFuture,

          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
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
            final double saldoReal = wallet?.balance ?? 0.0;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Seção de Saldo (Alinhado à Esquerda)
                    Text(
                        'Meu saldo:',
                        style: GoogleFonts.montserrat(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        _isObscured
                            ? 'R\$ _ _'
                            : _formatCurrency(saldoReal),
                        style: GoogleFonts.montserrat(
                          color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _isObscured = !_isObscured),

                        child: Row(
                          children: [
                            Icon(
                              _isObscured
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,

                              size: 18,
                              color: Colors.black,
                            ),

                            const SizedBox(width: 6),
                            Text(
                              _isObscured
                                  ? 'Mostrar'
                                  : 'Ocultar',
                              style: GoogleFonts.montserrat(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(
                    color: Colors.grey[400],
                    thickness: 1,
                  ),
                  const SizedBox(height: 16),
                  // 3. Seção de Depósito
                  Center(
                  child: Text(
                    'Clique abaixo para depositar um\nvalor para seu saldo:',
                    style: 
                    GoogleFonts.montserrat(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: SizedBox(
                      width: 187,
                      height: 65,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => WalletUser(
                                valor: '0,00',
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Depositar',
                          style: 
                          GoogleFonts.montserrat(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Divider(
                    color: Colors.grey[400],
                    thickness: 1,
                  ),

                  const SizedBox(height: 16),

                  // 4. Botões de Ação (Navegação para Minhas Ofertas)
                  Center(
                    child: SizedBox(
                      width: 250,

                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MyOffersScreen(),
                            ),
                          );
                        },

                        icon: Icon(
                          Icons.currency_exchange,
                          color: _primaryBlue,
                        ),
                        label: Text(
                          'Minhas ofertas',
                          style: TextStyle(
                            color: _primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          side: BorderSide(
                            color: _primaryBlue,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Center(
                    child: SizedBox(
                      width: 250,

                      child: OutlinedButton.icon(
                        onPressed: () {
                          showErrorSnackBar(
                            context,
                            "Histórico de transações será carregado aqui.",
                          );
                        },

                        icon: Icon(
                          Icons.history,
                          color: _primaryBlue,
                        ),

                        label: Text(
                          'Histórico de compras',

                          style: TextStyle(
                            color: _primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),

                          side: BorderSide(
                            color: _primaryBlue,
                            width: 1.5,
                          ),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Divider(
                    color: Colors.grey[400],
                    thickness: 1,
                  ),

                  const SizedBox(height: 16),

                  // 5. Seção de Lista de Tokens Adquiridos
                  const Center(
                    child: Text(
                      'Lista de Tokens adquiridos',

                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  _isObscured
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),

                          decoration: BoxDecoration(
                            color: _cardColor,
                            borderRadius: BorderRadius.circular(20),
                          ),

                          child: Column(
                            children: List.generate(
                              4,
                              (index) => Container(
                                height: 40,

                                margin: const EdgeInsets.only(
                                  bottom: 12,
                                ),

                                decoration: BoxDecoration(
                                  color: Colors.transparent,

                                  border: Border.all(
                                    color: Colors.black26,
                                  ),

                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        )

                      // Operador ternário para verificação de lista vazia conforme as instruções
                      : _meusTokens.isEmpty
                      ? Container(
                          width: double.infinity,

                          padding: const EdgeInsets.symmetric(
                            vertical: 40,
                          ),

                          decoration: BoxDecoration(
                            color: _cardColor,
                            borderRadius: BorderRadius.circular(20),
                          ),

                          child: const Center(
                            child: Text(
                              'Você ainda não possui tokens.',

                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        )

                      : ListView.builder(
                          shrinkWrap: true,

                          // Alterado para evitar overflow
                          physics:
                              const NeverScrollableScrollPhysics(),

                          itemCount: _meusTokens.length,

                          itemBuilder: (context, index) {
                            final token = _meusTokens[index];

                            // Retorna estritamente um Card com um ListTile dentro
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                vertical: 6,
                              ),

                              elevation: 0,
                              color: Colors.white,

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),

                              child: ListTile(
                                contentPadding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),

                                leading: const Icon(
                                  Icons.attach_money,
                                  color: Colors.black,
                                  size: 28,
                                ),

                                title: Text(
                                  token.tokenName,

                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),

                                subtitle: Text(
                                  token.startupName,

                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),

                                trailing: Text(
                                  '${token.quantity} tokens',

                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                  const SizedBox(height: 20),
                ]
              ),
            );
          },
        ),
      ),

      bottomNavigationBar: const AppBottomNavigation(
        selectedIndex: 4,
      ),
    );
  }
}
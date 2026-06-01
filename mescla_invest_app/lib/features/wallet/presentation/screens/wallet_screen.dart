/* Autor: Rafael Henrique dos Santos Inácio 
RA: 25009719*/

// Importações principais do Flutter e pacote de fontes
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Importações de utilitários e widgets globais do app (Core)
import 'package:mescla_invest_app/core/utils/snackbar_utils.dart';
import 'package:mescla_invest_app/core/widgets/app_bottom_navigation.dart';
import 'package:mescla_invest_app/core/widgets/custom_app_bar.dart';

// Importações de modelos, repositórios e telas/widgets específicos da funcionalidade de Carteira (Wallet)
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

// Widget Stateful que representa a tela principal da Carteira
class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});
  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

// Estado do widget, onde fica a lógica e o gerenciamento de dados da tela
class _WalletScreenState extends State<WalletScreen> {
  // Variável para controlar a visibilidade dos saldos (olhinho aberto/fechado)
  bool _isObscured = false;

  // Future que armazenará os dados gerais da carteira (como o saldo total)
  Future<WalletDetails>? _walletFuture;

  // Cor de fundo padrão da tela
  final Color _backgroundColor = const Color(0xFFE6E6E6);

  // Lista que armazenará os tokens específicos que o usuário possui
  List<TokenModel> _tokens = [];

  // Indicador de carregamento específico para a lista de tokens
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Ao iniciar a tela, dispara simultaneamente a busca pelos dados da carteira e pelos tokens
    _walletFuture = WalletRepository.instance.getWalletData();
    _loadTokens();
  }

  // Alterna o estado de visibilidade (mostra/esconde valores) e reconstrói a tela
  void _toggleVisibility() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }

  // Método assíncrono para buscar a lista de tokens do usuário no repositório
  Future<void> _loadTokens() async {
    try {
      // Aguarda a resposta do repositório com a lista
      final tokens = await WalletRepository.instance.getTokensListByUser();

      // Atualiza o estado com os tokens recebidos e desativa o ícone de carregamento
      setState(() {
        _tokens = tokens;
        _isLoading = false;
      });
    } catch (e) {
      // Em caso de erro, garante que o loading pare
      setState(() {
        _isLoading = false;
      });

      // Notifica o usuário visualmente sobre a falha
      showErrorSnackBar(context, 'Erro ao carregar tokens.');
    }
  }

  // Método de navegação que empilha a tela de depósito em cima da tela atual
  void _goToDeposit() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => WalletUser(valor: '0,00')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: CustomAppBar(title: 'Carteira'),
      // SafeArea garante que o conteúdo não fique escondido sob entalhes ou barras de status do celular
      body: SafeArea(
        // FutureBuilder gerencia as variações de estado da requisição da carteira (carregando, erro ou sucesso)
        child: FutureBuilder<WalletDetails>(
          future: _walletFuture,
          builder: (context, snapshot) {
            // Estado 1: Aguardando a resposta do servidor (exibe o loading)
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: Color(0xFF353988)),
              );
            }
            // Estado 2: Erro na requisição (exibe a mensagem de erro)
            if (snapshot.hasError) {
              return Center(
                child: Text('Erro ao carregar carteira: ${snapshot.error}'),
              );
            }

            // Estado 3: Sucesso. Extrai os dados validados
            final wallet = snapshot.data;

            // SingleChildScrollView permite a rolagem da tela caso o conteúdo ultrapasse a altura do display
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 30,
                ),
                child: Column(
                  children: [
                    // Componente visual do Saldo Total
                    WalletBalanceSection(
                      isObscured: _isObscured,
                      saldo:
                          wallet?.balance ??
                          0, // Usa 0 como valor de fallback caso o saldo retorne nulo
                      onToggle: _toggleVisibility,
                    ),
                    const SizedBox(height: 16),

                    // Linha divisória fina
                    Divider(color: Colors.grey, thickness: 1),
                    const SizedBox(height: 16),

                    // Componente para realizar depósitos, passando a função de navegação
                    Center(
                      child: WalletDepositSection(onDeposit: _goToDeposit),
                    ),

                    const SizedBox(height: 16),

                    // Divisórias usadas para controle de espaçamento estrutural e visual
                    Divider(color: Colors.grey, thickness: 1, height: 20),
                    Divider(color: Colors.transparent, thickness: 40),

                    // Botão de atalho para a tela "Minhas Ofertas"
                    Center(
                      child: CustomOutlinedButton(
                        text: 'Minhas ofertas',
                        icon: Icons.currency_exchange,
                        page: const MyOffersScreen(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Botão de atalho para a tela de "Histórico de compras"
                    Center(
                      child: CustomOutlinedButton(
                        text: 'Histórico de compras',
                        icon: Icons.history,
                        page: const TransactionHistoryScreen(),
                      ),
                    ),

                    // Mais divisórias (transparentes e visíveis) para separar a área de atalhos da lista
                    Divider(color: Colors.transparent, thickness: 40),
                    Divider(color: Colors.grey, thickness: 1, height: 20),
                    const SizedBox(height: 16),

                    /// TOKENS
                    // Título da seção da lista de tokens
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

                    // Componente que renderiza a lista de tokens específica do usuário
                    WalletTokensList(
                      tokens: _tokens,
                      isObscured:
                          _isObscured, // Passa o estado visual para esconder também o valor dos tokens, se ativado
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      // Barra de navegação inferior global do app, marcando a aba "Carteira" (índice 4) como ativa
      bottomNavigationBar: const AppBottomNavigation(selectedIndex: 4),
    );
  }
}

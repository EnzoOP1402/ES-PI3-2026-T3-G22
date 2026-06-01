/* Autor: Bernardo Castro Brandão de Oliveira - RA: 25014953*/

// Importação do pacote principal do Flutter para construção da interface gráfica
import 'package:flutter/material.dart';

// Importação da biblioteca de fontes personalizadas Google Fonts
import 'package:google_fonts/google_fonts.dart';

// Importação dos métodos responsáveis pela exibição de SnackBars
import 'package:mescla_invest_app/core/utils/snackbar_utils.dart';

// Importação da barra de navegação inferior personalizada
import 'package:mescla_invest_app/core/widgets/app_bottom_navigation.dart';

// Importação da AppBar personalizada utilizada na aplicação
import 'package:mescla_invest_app/core/widgets/custom_app_bar.dart';

// Importação do repositório responsável pela autenticação
import 'package:mescla_invest_app/features/auth/data/repositories/auth_repository.dart';

// Importação da seção de exploração da tela inicial
import 'package:mescla_invest_app/features/home/presentation/widgets/explore_section.dart';

// Importação do repositório responsável pelas operações da carteira
import 'package:mescla_invest_app/features/wallet/data/repositories/wallet_repository.dart';

// Importação das rotas nomeadas da aplicação
import 'package:mescla_invest_app/routes/app_routes.dart';

// Tela principal da aplicação após o login do usuário
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

// Classe responsável pelo gerenciamento dos estados da tela Home
class HomeScreenState extends State<HomeScreen> {
  // Controla se o saldo deve estar visível ou oculto
  bool mostrarSaldo = false;

  // Controla o estado de carregamento do saldo
  bool isLoadingBalance = true;

  // Armazena o saldo atual do usuário
  double saldo = 0;

  // Método executado automaticamente ao abrir a tela
  @override
  void initState() {
    super.initState();

    // Carrega os dados da carteira
    _loadBalance();
  }

  // Método responsável por buscar o saldo do usuário
  Future<void> _loadBalance() async {
    try {
      // Obtém os dados da carteira através do repositório
      final wallet = await WalletRepository.instance.getWalletData();

      // Atualiza os dados apenas se o widget ainda estiver montado
      if (mounted) {
        setState(() {
          // Atualiza o saldo carregado
          saldo = wallet.balance;

          // Finaliza o estado de carregamento
          isLoadingBalance = false;
        });
      }
    } catch (e) {
      // Trata possíveis erros durante a consulta
      if (mounted) {
        setState(() {
          // Finaliza o carregamento mesmo em caso de erro
          isLoadingBalance = false;
        });

        // Exibe mensagem de erro para o usuário
        showErrorSnackBar(context, 'Erro ao carregar saldo');
      }
    }
  }

  // Método responsável por realizar o logout do usuário
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
      // Exibe mensagem caso ocorra erro no logout
      if (mounted) {
        showErrorSnackBar(context, 'Erro ao sair: $e');
      }
    }
  }

  // Método responsável pela construção da interface gráfica
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Cor de fundo da tela
      backgroundColor: const Color(0xFFD9D9D9),

      // Barra superior personalizada
      appBar: const CustomAppBar(title: 'MesclaInvest'),

      // Conteúdo principal da tela
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 14),

              // Título da área de saldo
              Text(
                'Saldo do Usuário:',
                style: GoogleFonts.montserrat(
                  fontSize: 25,
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 8),

              // Exibição do saldo ou ocultação dos valores
              Text(
                mostrarSaldo ? 'R\$ ${saldo.toStringAsFixed(2)}' : '— —',
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 7),

              // Botão para mostrar ou ocultar o saldo
              GestureDetector(
                onTap: () {
                  setState(() {
                    // Alterna entre mostrar e ocultar saldo
                    mostrarSaldo = !mostrarSaldo;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Ícone muda conforme o estado atual
                    Icon(
                      mostrarSaldo
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 18,
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 4),

                    // Texto correspondente ao estado atual
                    Text(
                      mostrarSaldo ? 'Ocultar' : 'Mostrar',
                      style: GoogleFonts.montserrat(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Linha divisória da interface
              const Divider(height: 1, thickness: 1, color: Colors.black),

              const SizedBox(height: 28),

              // Seção de atalhos principais da aplicação
              ExploreSection(
                title: 'Explore Mais',

                buttons: [
                  // Botão de acesso ao catálogo
                  ExploreButtonData(
                    icon: Icons.lightbulb_outline,
                    label: 'Catálogo',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.catalog);
                    },
                  ),

                  // Botão de acesso ao balcão
                  ExploreButtonData(
                    icon: Icons.attach_money,
                    label: 'Balcão',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.exchange);
                    },
                  ),

                  // Botão de acesso à carteira
                  ExploreButtonData(
                    icon: Icons.wallet_rounded,
                    label: 'Carteira',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.wallet);
                    },
                  ),

                  // Botão de acesso ao dashboard
                  ExploreButtonData(
                    icon: Icons.bar_chart_rounded,
                    label: 'Dashboard',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.dashboard);
                    },
                  ),

                  // Botão de acesso ao perfil do usuário
                  ExploreButtonData(
                    icon: Icons.person,
                    label: 'Perfil',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.profile);
                    },
                  ),

                  // Botão responsável pelo logout
                  ExploreButtonData(
                    icon: Icons.logout,
                    label: 'Sair',
                    onTap: () async {
                      // Executa o encerramento da sessão
                      await _handleLogout();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      // Barra de navegação inferior
      bottomNavigationBar: const AppBottomNavigation(
        // Índice da tela Home
        selectedIndex: 0,
      ),
    );
  }
}

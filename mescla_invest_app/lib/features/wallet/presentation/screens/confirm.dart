/* Autor: Bernardo Castro Brandão de Oliveira - RA: 25014953*/

// Importação do pacote principal do Flutter para construção da interface gráfica
import 'package:flutter/material.dart';

// Importação da biblioteca Google Fonts para utilização de fontes personalizadas
import 'package:google_fonts/google_fonts.dart';

// Importação da AppBar personalizada utilizada na aplicação
import 'package:mescla_invest_app/core/widgets/custom_app_bar.dart';

// Importação da tela principal da carteira
import 'package:mescla_invest_app/features/wallet/presentation/screens/wallet_screen.dart';

// Tela exibida após a confirmação bem-sucedida de um depósito
class SuccessScreen extends StatelessWidget {
  // Valor depositado recebido da tela anterior
  final String valor;

  // Construtor da tela
  const SuccessScreen({super.key, required this.valor});

  // Método responsável pela construção da interface gráfica
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Cor de fundo da tela
      backgroundColor: const Color(0xFFF3F3F3),

      // Barra superior personalizada
      appBar: CustomAppBar(title: 'Carteira'),

      // Conteúdo principal da tela
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              // Centraliza os elementos verticalmente
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ícone circular indicando sucesso na operação
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.green, width: 5),
                  ),
                  child: const Icon(Icons.check, color: Colors.green, size: 55),
                ),
                const SizedBox(height: 30),

                // Mensagem de confirmação do depósito
                Text(
                  'Valor depositado com\nsucesso!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 45),

                // Exibe o valor que foi depositado
                Text(
                  'Valor Total: R\$$valor',
                  style: GoogleFonts.montserrat(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 70),

                // Área do botão para retorno à carteira
                SizedBox(
                  width: 205,
                  height: 68,
                  child: Container(
                    // Gradiente utilizado como fundo do botão
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF5B5FEF), Color(0xFF353988)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ElevatedButton(
                      // Navega para a tela da carteira removendo as telas anteriores da pilha
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WalletScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Voltar para a carteira',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

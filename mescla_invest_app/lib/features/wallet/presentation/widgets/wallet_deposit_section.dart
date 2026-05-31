/*Autor: Gabriela Sichiroli Ferrari - RA: 25013763 */


import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Widget responsável por exibir a seção de depósito
// da carteira do usuário.
class WalletDepositSection extends StatelessWidget {

  // Função executada quando o botão de depósito é pressionado.
  final VoidCallback onDeposit;

  const WalletDepositSection({
    super.key,
    required this.onDeposit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        // Texto informativo orientando o usuário
        // a realizar um depósito.
        Text(
          'Clique abaixo para depositar um\nvalor para seu saldo:',
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 16),

        // Área que define o tamanho do botão.
        SizedBox(
          width: 187,
          height: 65,

          child: DecoratedBox(

            // Aplica o gradiente de fundo ao botão.
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF5157D6),
                  Color(0xFF353988),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),

              // Define o arredondamento das bordas.
              borderRadius: BorderRadius.circular(15),
            ),

            child: ElevatedButton(

              // Configurações visuais do botão.
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // Executa a ação de depósito.
              onPressed: onDeposit,

              child: Text(
                'Depositar',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
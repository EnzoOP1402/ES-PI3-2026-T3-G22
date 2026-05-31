/*Autor: Gabriela Sichiroli Ferrari - RA: 25013763 */

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mescla_invest_app/core/utils/currency_formatter.dart';

// Widget responsável por exibir o saldo da carteira
// e permitir que o usuário oculte ou visualize o valor.
class WalletBalanceSection extends StatelessWidget {

  // Define se o saldo está oculto ou visível.
  final bool isObscured;

  // Valor atual do saldo da carteira.
  final double saldo;

  // Função chamada ao alternar a visualização do saldo.
  final VoidCallback onToggle;

  const WalletBalanceSection({
    super.key,
    required this.isObscured,
    required this.saldo,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // Texto identificando o saldo da carteira.
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

            // Exibe o saldo formatado ou oculto,
            // dependendo do estado atual.
            Text(
              isObscured
                  ? 'R\$ _ _'
                  : formatCurrency(saldo),
              style: GoogleFonts.montserrat(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.w400,
              ),
            ),

            const SizedBox(width: 16),

            // Área clicável para alternar entre
            // mostrar e ocultar o saldo.
            GestureDetector(
              onTap: onToggle,
              child: Row(
                children: [

                  // Ícone que representa o estado atual
                  // de visualização do saldo.
                  Icon(
                    isObscured
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 18,
                  ),

                  const SizedBox(width: 6),

                  // Texto que informa a ação disponível
                  // para o usuário.
                  Text(
                    isObscured
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
      ],
    );
  }
}
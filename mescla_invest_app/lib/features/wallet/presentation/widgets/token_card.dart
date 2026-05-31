/*Autor: Gabriela Sichiroli Ferrari - RA: 25013763 */

import 'package:flutter/material.dart';
import '../../data/models/token_model.dart';
import 'package:google_fonts/google_fonts.dart';

// Widget responsável por exibir as informações
// de um token da carteira do usuário.
class TokenCard extends StatelessWidget {

  // Dados do token que serão exibidos no card.
  final TokenModel token;

  const TokenCard({
    super.key,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    return Card(

      // Espaçamento vertical entre os cards da lista.
      margin: const EdgeInsets.symmetric(vertical: 6),

      // Cor de fundo do card.
      color: const Color(0xFFF4F4F4),

      child: ListTile(

        // Ícone representando o token/ativo financeiro.
        leading: const Icon(Icons.attach_money),

        // Nome do token.
        title: Text(
          token.tokenName,
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),

        // Nome da startup associada ao token.
        subtitle: Text(
          token.startupName,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),

        // Quantidade de tokens que o usuário possui.
        trailing: Text(
          '${token.quantity} tokens',
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
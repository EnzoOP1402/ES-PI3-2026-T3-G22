/*Gabriela Sichiroli Ferrari*/

import 'package:flutter/material.dart';
import '../../data/models/token_model.dart';
import 'token_card.dart';

// Widget responsável por exibir a lista de tokens
// presentes na carteira do usuário.
class WalletTokensList extends StatelessWidget {

  // Lista de tokens que serão exibidos.
  final List<TokenModel> tokens;

  // Define se as informações devem ficar ocultas.
  final bool isObscured;

  const WalletTokensList({
    super.key,
    required this.tokens,
    required this.isObscured,
  });

  @override
  Widget build(BuildContext context) {

    // Caso o saldo esteja oculto, a lista de tokens
    // não é exibida.
    if (isObscured) {
      return const Text('');
    }

    // Exibe uma mensagem quando o usuário
    // ainda não possui tokens na carteira.
    if (tokens.isEmpty) {
      return const Center(
        child: Text(
          'Você ainda não possui tokens.',
        ),
      );
    }

    // Exibe a lista de tokens utilizando
    // um TokenCard para cada item.
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tokens.length,
      itemBuilder: (context, index) {
        return TokenCard(
          token: tokens[index],
        );
      },
    );
  }
}
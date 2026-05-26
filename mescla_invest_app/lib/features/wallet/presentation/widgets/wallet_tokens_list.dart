/*Gabriela Sichiroli Ferrari*/

import 'package:flutter/material.dart';
import '../../data/models/token_model.dart';
import 'token_card.dart';

class WalletTokensList extends StatelessWidget {
  final List<TokenModel> tokens;
  final bool isObscured;

  const WalletTokensList({
    super.key,
    required this.tokens,
    required this.isObscured,
  });

  @override
  Widget build(BuildContext context) {

    if (isObscured) {
      return const Text('Oculto');
    }

    if (tokens.isEmpty) {
      return const Center(
        child: Text(
          'Você ainda não possui tokens.',
        ),
      );
    }

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
/*Gabriela Sichiroli Ferrari*/

import 'package:flutter/material.dart';
import '../../data/models/token_model.dart';

class TokenCard extends StatelessWidget {
  final TokenModel token;

  const TokenCard({
    super.key,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),

      child: ListTile(
        leading: const Icon(Icons.attach_money),
        title: Text(
          token.tokenName,
        ),
        subtitle: Text(
          token.startupName,
        ),
        trailing: Text(
          '${token.quantity} tokens',
        ),
      ),
    );
  }
}
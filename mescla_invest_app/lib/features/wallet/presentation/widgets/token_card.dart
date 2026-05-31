/*Gabriela Sichiroli Ferrari*/

import 'package:flutter/material.dart';
import '../../data/models/token_model.dart';
import 'package:google_fonts/google_fonts.dart';

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
      color: Color(0xFFF4F4F4),
      child: ListTile(
        leading: Icon(Icons.attach_money),
        title: Text(
          token.tokenName,
            style:GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          token.startupName,
            style:GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w400,
          )
        ),
        trailing: Text(
          '${token.quantity} tokens',
            style:GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w500,
        ),
        )
      ),
    );
  }
}
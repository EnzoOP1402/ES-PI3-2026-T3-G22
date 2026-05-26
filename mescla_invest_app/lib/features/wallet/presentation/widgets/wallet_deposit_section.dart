/*Gabriela Sichiroli Ferrari*/

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WalletDepositSection extends StatelessWidget {
  final VoidCallback onDeposit;

  const WalletDepositSection({
    super.key,
    required this.onDeposit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Clique abaixo para depositar um\nvalor para seu saldo:',
          textAlign: TextAlign.center,

          style: GoogleFonts.montserrat(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 16),

        SizedBox(
          width: 187,
          height: 65,

          child: ElevatedButton(
            onPressed: onDeposit,

            child: const Text('Depositar'),
          ),
        ),
      ],
    );
  }
}
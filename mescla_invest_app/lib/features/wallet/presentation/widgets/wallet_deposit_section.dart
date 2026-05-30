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
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: 187,
          height: 65,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF5157D6),
                  Color(0xFF353988),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
                borderRadius: BorderRadius.circular(15),
            ),

            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            onPressed: onDeposit,
            child: Text(
              'Depositar',
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            )
          ),
        ),
      ],
    );
  }
}
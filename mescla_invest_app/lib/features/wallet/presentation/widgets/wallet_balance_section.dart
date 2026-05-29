/*Gabriela Sichiroli Ferrari*/

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class WalletBalanceSection extends StatelessWidget {
  final bool isObscured;
  final double saldo;
  final VoidCallback onToggle;

  const WalletBalanceSection({
    super.key,
    required this.isObscured,
    required this.saldo,
    required this.onToggle,
  });

  String formatCurrency(double value) {
    return NumberFormat.simpleCurrency(
      locale: 'pt_BR',
    ).format(value);
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            GestureDetector(
              onTap: onToggle,
              child: Row(
                children: [
                  Icon(
                    isObscured
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isObscured
                        ? 'Mostrar'
                        : 'Ocultar',
                        style: GoogleFonts.montserrat(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        )
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
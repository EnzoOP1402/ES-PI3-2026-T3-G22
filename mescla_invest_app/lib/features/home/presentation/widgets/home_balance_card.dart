import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeBalanceCard extends StatelessWidget {
  final bool loading;
  final bool showBalance;
  final double balance;
  final VoidCallback onToggle;

  const HomeBalanceCard({
    super.key,
    required this.loading,
    required this.showBalance,
    required this.balance,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Saldo do Usuário:',
          style: GoogleFonts.montserrat(
          fontSize: 20,
          fontWeight: FontWeight.w400
          ),
        ),

        const SizedBox(height: 8),

        Text(
          loading
              ? 'Carregando...'
              : showBalance
                  ? 'R\$ ${balance.toStringAsFixed(2)}'
                  : '— —',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.w400,
          ),
        ),

        const SizedBox(height: 7),

        GestureDetector(
          onTap: onToggle,
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Icon(
                showBalance
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              const SizedBox(width: 4),
              Text(
                showBalance
                    ? 'Ocultar'
                    : 'Mostrar',
                style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
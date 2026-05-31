/*Gabriela Sichiroli Ferrari*/

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OffersHeader extends StatelessWidget {
  const OffersHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        24,
        24,
        24,
        16,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'Minhas Ofertas',
            style:GoogleFonts.montserrat(
              color:const Color(0xFF353988),
              fontSize: 24,
              fontWeight:FontWeight.w700,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Confira suas ofertas ativas esperando por ser realizadas. Para cancelá-las basta arrastá-las para a direita.',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
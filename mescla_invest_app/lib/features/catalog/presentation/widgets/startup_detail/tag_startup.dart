/* Autor: Livia Lucizano */

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TagStartup extends StatelessWidget {
  final String texto;

  const TagStartup({
    super.key,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF353988).withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: const Color(0xFF353988).withValues(alpha: 0.35),
        ),
      ),
      child: Text(
        texto,
        style: GoogleFonts.montserrat(
          color: const Color(0xFF353988),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
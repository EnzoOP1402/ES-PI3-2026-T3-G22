/* Autor: Enzo Olivato Pazian */

// Importando as dependências
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Função showErrorSnackBar: responsável por obter uma mensagem de erro e exibir um Snackbar
/// com a mensagem formatada e estilizada
void showErrorSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message, style: GoogleFonts.montserrat(fontWeight: FontWeight(600)),),
      backgroundColor: Colors.redAccent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}

/// Função showSuccessSnackBar: responsável por exibir um Snackbar com uma mensagem de sucesso estilizada
void showSuccessSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message, style: GoogleFonts.montserrat(fontWeight: FontWeight(600)),),
      backgroundColor: Colors.lightGreen,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}
/* Autor: Enzo Olivato Pazian */

// Importando as dependências
import 'package:flutter/material.dart';

/// Função showErrorSnackBar: responsável por obter uma mensagem de erro e exibir um Snackbar
/// com a mensagem formatada e estilizada
void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(fontWeight: FontWeight(600)),),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
// Autor: Murillo Iamarino Caravita

import 'package:flutter/material.dart';

class BotaoIrPara extends StatelessWidget {
  final Widget pagina;
  final String texto;

  const BotaoIrPara({
    super.key,
    required this.pagina,
    this.texto = 'Ver mais',
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => pagina),
        );
      },
      child: Text(texto),
    );
  }
}
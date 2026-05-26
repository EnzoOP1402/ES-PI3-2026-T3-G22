/* Autor: Bernardo Castro Brandão de Oliveira */

import 'package:flutter/material.dart';
import 'package:mescla_invest_app/features/wallet/screens/confirm.dart';

class TelaBranca extends StatefulWidget {
  final String valor;

  const TelaBranca({
    super.key,
    required this.valor,
  });

  @override
  State<TelaBranca> createState() => _TelaBrancaState();
}

class _TelaBrancaState extends State<TelaBranca> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SuccessScreen(
              valor: widget.valor,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          'Pix feito!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}

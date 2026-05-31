/*Autor: Gabriela Sichiroli Ferrari - RA: 25013763 */

import 'package:flutter/material.dart';

// Widget utilizado para exibir requisitos de validação,
// como regras de senha ou preenchimento de formulários.
class AuthRequirement extends StatelessWidget {

  // Texto que descreve o requisito.
  final String text;

  // Indica se o requisito foi atendido.
  final bool isValid;

  const AuthRequirement({
    super.key,
    required this.text,
    required this.isValid,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [

        // Exibe um ícone de sucesso ou erro
        // de acordo com o estado do requisito.
        Icon(
          isValid ? Icons.check : Icons.close,
          color:
              isValid
                  ? Colors.green
                  : Colors.red,
          size: 18,
        ),

        const SizedBox(width: 8),

        // Exibe a descrição do requisito.
        // A cor acompanha o estado da validação.
        Text(
          text,
          style: TextStyle(
            color:
                isValid
                    ? Colors.green
                    : Colors.red,
          ),
        ),
      ],
    );
  }
}
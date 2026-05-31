/* Autor: Gabriela Sichiroli Ferrari */

import 'package:flutter/material.dart';

// Botão reutilizável utilizado nas telas de autenticação
// (login, cadastro e recuperação de senha).
class AuthButton extends StatelessWidget {

  // Texto exibido no botão.
  final String text;

  // Função executada quando o botão é pressionado.
  final VoidCallback onPressed;

  // Indica se uma operação está em andamento.
  // Quando true, exibe um indicador de carregamento
  // e desabilita o botão.
  final bool loading;

  const AuthButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(

      // Define a largura do botão como 60% da largura da tela.
      width: MediaQuery.of(context).size.width * 0.6,

      // Altura fixa do botão.
      height: 55,

      child: ElevatedButton(

        // Desabilita o botão enquanto estiver carregando.
        onPressed: loading ? null : onPressed,

        style: ElevatedButton.styleFrom(

          // Cor principal do botão.
          backgroundColor: const Color(0xFFE60073),

          // Arredondamento das bordas.
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),

        // Exibe um indicador de carregamento ou o texto,
        // dependendo do estado do botão.
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }
}
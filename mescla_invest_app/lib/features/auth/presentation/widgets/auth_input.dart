/*Autor: Gabriela Sichiroli Ferrari - RA: 25013763 */

import 'package:flutter/material.dart';
import 'package:mescla_invest_app/core/theme/app_colors.dart';
import 'package:flutter/services.dart';

// Campo de entrada reutilizável utilizado
// nos formulários de autenticação.
class AuthInput extends StatelessWidget {

  // Texto exibido como dica dentro do campo.
  final String hint;

  // Controlador responsável por armazenar
  // e gerenciar o valor digitado.
  final TextEditingController controller;

  // Define se o conteúdo deve ser ocultado
  // (utilizado para senhas).
  final bool obscure;

  // Formatadores aplicados ao texto digitado.
  final List<TextInputFormatter>? inputFormatters;

  // Tipo de teclado exibido ao usuário.
  final TextInputType? keyboardType;

  // Função de validação do campo.
  final String? Function(String?)? validator;

  // Widget exibido ao final do campo.
  // Exemplo: ícone de mostrar/ocultar senha.
  final Widget? suffixIcon;

  // Callback executado sempre que o valor do campo é alterado.
  final Function(String)? onChanged;

  const AuthInput({
    super.key,
    required this.hint,
    required this.controller,
    this.obscure = false,
    this.inputFormatters,
    this.keyboardType,
    this.validator,
    this.suffixIcon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(

      // Espaçamento inferior entre os campos do formulário.
      margin: const EdgeInsets.only(bottom: 16),

      child: TextFormField(

        // Controla o valor digitado.
        controller: controller,

        // Oculta o conteúdo quando necessário.
        obscureText: obscure,

        inputFormatters: inputFormatters,
        keyboardType: keyboardType,
        validator: validator,
        onChanged: onChanged,

        decoration: InputDecoration(

          // Texto de dica exibido quando o campo está vazio.
          hintText: hint,

          // Define o preenchimento do campo.
          filled: true,
          fillColor: AppColors.surface,

          // Espaçamento interno do campo.
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),

          // Configuração das bordas.
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.border),
          ),

          // Widget opcional exibido ao final do campo.
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
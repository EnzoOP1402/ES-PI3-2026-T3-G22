/* Autor: Gabriela Sichiroli Ferrari */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AuthInput extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final bool obscure;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
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
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        inputFormatters: inputFormatters,
        keyboardType: keyboardType,
        validator: validator,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Color(0xFFF4F4F4),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
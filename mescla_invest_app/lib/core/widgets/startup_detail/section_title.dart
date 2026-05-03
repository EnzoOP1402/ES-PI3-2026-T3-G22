/* Autor: Livia Lucizano */
import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF2F3192),
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
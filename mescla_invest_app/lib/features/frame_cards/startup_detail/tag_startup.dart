/* Autor: Livia Lucizano */
import 'package:flutter/material.dart';

class TagStartup extends StatelessWidget {
  final String texto;

  const TagStartup({super.key, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFB9D8FF),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        texto,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}
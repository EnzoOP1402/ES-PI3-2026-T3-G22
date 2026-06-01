/*  Autor: Murillo Iamarino Caravita RA: 25014012 */ 

import 'package:flutter/material.dart';

class BuscaStartup extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const BuscaStartup({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Pesquisar startup...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
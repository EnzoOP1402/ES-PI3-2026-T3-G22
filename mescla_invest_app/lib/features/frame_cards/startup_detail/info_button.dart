/* Autor: Livia Lucizano */
import 'package:flutter/material.dart';


class InfoButton extends StatelessWidget {
  final String text;

  const InfoButton({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.article_outlined),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}
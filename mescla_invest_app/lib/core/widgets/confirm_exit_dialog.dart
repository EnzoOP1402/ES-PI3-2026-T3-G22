import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ConfirmExitDialog extends StatelessWidget {
  final String title;
  final String message;
  final String question;

  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  const ConfirmExitDialog({
    super.key,
    required this.title,
    required this.message,
    required this.question,
    required this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 350,
        padding: const EdgeInsets.all(24),

        decoration: BoxDecoration(
          color: const Color(0xFFDEDEDE),
          borderRadius: BorderRadius.circular(20),
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Text(
              title,
              style: GoogleFonts.montserrat(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            // Mensagem
            Text(
              message,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 4),

            // Pergunta
            Text(
              question,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 24),

            // Botões
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Botão SIM
                GestureDetector(
                  onTap: onConfirm,
                  child: Container(
                    width: 80,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(
                        color: const Color(0xFF353988),
                        width: 2,
                      ),

                      borderRadius: BorderRadius.circular(22),
                    ),

                    child:Center(
                      child: Text(
                        'Sim',
                        style: GoogleFonts.montserrat(
                          color: Color(0xFF353988),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Botão NÃO
                GestureDetector(
                  onTap:
                      onCancel ??
                      () {
                        Navigator.pop(context);
                      },

                  child: Container(
                    width: 80,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDB0065),
                      borderRadius: BorderRadius.circular(22),
                    ),

                    child: Center(
                      child: Text(
                        'Não',
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
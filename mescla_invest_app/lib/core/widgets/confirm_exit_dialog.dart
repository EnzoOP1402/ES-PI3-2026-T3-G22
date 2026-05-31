import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Dialog personalizado utilizado para confirmar
// ações que podem fazer o usuário perder dados
// ou sair de uma determinada tela.
class ConfirmExitDialog extends StatelessWidget {

  // Título exibido no topo do diálogo.
  final String title;

  // Mensagem explicativa da ação.
  final String message;

  // Pergunta de confirmação apresentada ao usuário.
  final String question;

  // Função executada quando o usuário confirma a ação.
  final VoidCallback onConfirm;

  // Função executada ao cancelar a ação.
  // Caso não seja informada, o diálogo será fechado.
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

      // Remove o fundo padrão do Dialog.
      backgroundColor: Colors.transparent,

      child: Container(
        width: 350,
        padding: const EdgeInsets.all(24),

        decoration: BoxDecoration(

          // Cor de fundo do diálogo.
          color: const Color(0xFFDEDEDE),

          // Arredondamento das bordas.
          borderRadius: BorderRadius.circular(20),
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Título principal do diálogo.
            Text(
              title,
              style: GoogleFonts.montserrat(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 12),

            // Mensagem explicativa.
            Text(
              message,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 4),

            // Pergunta de confirmação.
            Text(
              question,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 24),

            // Área dos botões de ação.
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [

                // Botão responsável por confirmar a ação.
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

                    child: Center(
                      child: Text(
                        'Sim',
                        style: GoogleFonts.montserrat(
                          color: const Color(0xFF353988),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Botão responsável por cancelar a ação.
                GestureDetector(
                  onTap:
                      onCancel ??
                      () {

                        // Fecha o diálogo caso nenhuma ação
                        // personalizada de cancelamento seja fornecida.
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
/* Autor: Gabriela Sichiroli Ferrari - RA: 25013763 */

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mescla_invest_app/routes/app_routes.dart';

// AppBar personalizada utilizada nas telas do aplicativo.
// Implementa PreferredSizeWidget para definir a altura
// padrão exigida pelo Scaffold.
class CustomAppBar extends StatelessWidget
    implements PreferredSizeWidget {

  // Título exibido no centro da AppBar.
  final String title;

  // Ação personalizada para o botão de voltar.
  // Caso não seja informada, será executado um Navigator.pop().
  final VoidCallback? onBackPressed;

  const CustomAppBar({
    super.key,
    required this.title,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(

      // Configurações visuais da AppBar.
      backgroundColor: const Color(0xFF353988),
      elevation: 0,
      centerTitle: true,

      // Exibe o título da tela.
      title: Text(
        title,
        style: GoogleFonts.montserrat(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),

      // Botão de retorno localizado à esquerda.
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.white,
          size: 20,
        ),

        // Executa uma ação personalizada ou retorna
        // para a tela anterior por padrão.
        onPressed:
            onBackPressed ??
            () {
              Navigator.pop(context);
            },
      ),

      // Botões exibidos no lado direito da AppBar.
      actions: [
        IconButton(

          // Atalho para a tela de perfil do usuário.
          icon: const Icon(
            Icons.person,
            color: Colors.white,
            size: 28,
          ),

          onPressed: () {
            Navigator.pushNamed(
              context,
              AppRoutes.profile,
            );
          },
        ),
      ],
    );
  }

  // Define a altura padrão da AppBar.
  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight);
}
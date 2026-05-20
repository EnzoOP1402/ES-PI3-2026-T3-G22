/* Autor: Gabriela Sichiroli Ferrari */

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mescla_invest_app/routes/app_routes.dart';

class CustomAppBar extends StatelessWidget
    implements PreferredSizeWidget {

  final String title;

  const CustomAppBar({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {

    return AppBar(
      backgroundColor: const Color(0xFF353988),
      elevation: 0,
      centerTitle: true,

      title: Text(
        title,
        style: GoogleFonts.montserrat(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),

      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.white,
          size: 20,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),

      actions: [

        // BOTÃO PERFIL
        IconButton(
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
  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight);
}
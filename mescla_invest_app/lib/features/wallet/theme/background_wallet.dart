import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BackgroundWallet extends StatelessWidget {
  final Widget body;
  final VoidCallback? onBackPressed;

  const BackgroundWallet({super.key, required this.body, this.onBackPressed});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.montserratTextTheme(),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFDEDEDE),
        appBar: AppBar(
          backgroundColor: const Color(0xFF353988),
          centerTitle: true,
          title: const Text("Carteira"),
          foregroundColor: const Color(0xFFFFFFFF),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed:
                onBackPressed ??
                () {
                  Navigator.pop(context);
                },
          ),
        ),
        body: body,
      ),
    );
  }
}

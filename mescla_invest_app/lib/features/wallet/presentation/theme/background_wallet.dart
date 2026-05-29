import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mescla_invest_app/core/widgets/custom_app_bar.dart';

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
            appBar: CustomAppBar(
            title: 'Carteira',
          ),
        body: body,
      ),
    );
  }
}

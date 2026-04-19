import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MesclaInvest());
}

class MesclaInvest extends StatelessWidget {
  const MesclaInvest({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BackgroundContainer(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child : Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF353988),
                        ),
                        onPressed: () {},
                      ),
                    ),

                    const Text(
                      "Titulo Qualquer",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF353988),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(
                thickness: 1,
                color: Colors.black26,
              ),
            ],
          ),
        ),
      ),

      theme: ThemeData(
        textTheme: GoogleFonts.montserratTextTheme(),
      ),
    );
  }
}


class BackgroundContainer extends StatelessWidget {
  final Widget? child;

  const BackgroundContainer({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],

      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFD4D4D4),
        ),

        child: Stack(
          children: [
            Positioned(
              top: -40,
              right: -20,
              child: Container(
                width: 130,
                height: 130,
                decoration: const BoxDecoration(
                  color: Color(0xFFDB0065),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: 20,
              right: -80,
              child: Container(
                width: 130,
                height: 130,
                decoration: const BoxDecoration(
                  color: Color(0xFF353988),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            child ?? const SizedBox(),
          ],
        ),
      ),
    );

  }
}

//Fundo
Widget header_text(String title, String subtitle) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(30),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const SizedBox(height: 20),
        Text(title,
            style: const TextStyle(color: Colors.white, fontSize: 22)),
        const SizedBox(height: 10),
        Text(subtitle,
            style: const TextStyle(color: Colors.white70)),
      ],
    ),
  );
}


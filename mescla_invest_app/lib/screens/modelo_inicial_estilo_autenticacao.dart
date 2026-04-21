/* Autor: Bernardo Castro Brandão de Oliveira */

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
      home: RecuperarSenha(),
      theme: ThemeData(
        textTheme: GoogleFonts.montserratTextTheme(),
      ),
    );
  }
}

//tela nova senha

class RecuperarSenha extends StatefulWidget {
  const RecuperarSenha({super.key});

  @override
  State<RecuperarSenha> createState() => RecuperarSenhaState();
}

class RecuperarSenhaState extends State<RecuperarSenha> {
  String? erroEmail;
  String email = '';
  final LinearGradient gradient = LinearGradient(
    begin: Alignment.topLeft,
    colors: [Color(0xFFDB0065), Color(0xFF353988)],
  );


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          title: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Image.asset(
                  'images/logo_app.png',
                  width: 35,
                  height: 35,
                ),
              ]
          )
      ),


      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.4],
            colors: [
              Color(0xFFDB0065),
              Color(0xFF353988),
            ],
          ),
        ),

        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Recuperação de senha",
                      style: TextStyle(
                        color: Color(0xFFD4D4D4),
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const Text(
                      "Insira o e-mail utilizado em seu cadastro\npara enviarmos um código de verificação.",
                      style: TextStyle(
                        color: Color(0xFFD4D4D4),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 100),

              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD4D4D4),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 30),

                      _input(
                        hint: "E-mail",
                        errorText: erroEmail,
                        onChanged: (v) => email = v,
                      ),

                      const SizedBox(height: 25),

                      _button("Enviar", () {
                        if (!email.contains('@') || !email.contains('gmail.com')) {
                          setState(() {
                            erroEmail = "Digite um e-mail válido (gmail.com)";
                          });
                          return;
                        }
                        setState(() {
                          erroEmail = null;
                        });
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
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

Widget _input({required String hint, Function(String)? onChanged, String? errorText}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 30),
    child: TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
          label: RichText(
            text: const TextSpan(
              text: 'E-mail ',
              style: TextStyle(color: Colors.black87),
              children: [
                TextSpan(
                  text: '*',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
          floatingLabelStyle: const TextStyle(
            color: Color(0xFFDB0065),
          ),
          errorText: errorText,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.grey),
          ),

          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.red),
          ),

          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.red, width: 2),
          )
      ),
    ),
  );
}

Widget _button(String text, VoidCallback onPressed) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 60),
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFDB0065),
        foregroundColor: Color(0xFFD4D4D4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(vertical: 15),
      ),
      child: Center(child: Text(text)),
    ),
  );
}
/* Autor: Gabriela Sichiroli Ferrari */

import 'package:flutter/material.dart';

class AuthLayout extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const AuthLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child:Stack(
        children: [
          // FUNDO GRADIENTE
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF353988),
                  Color(0xFFDB0065),
                ],
                stops: [0.75, 1.0],
                begin: Alignment.bottomCenter,
                end: Alignment.topLeft,
              ),
            ),
          ),
          //CONTEÚDO
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TOPO (ALINHADO À ESQUERDA)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // BOTÃO VOLTAR
                      // InkWell(
                      //   onTap: () => Navigator.pop(context),
                      //   child: const Icon(
                      //     Icons.arrow_back,
                      //     color: Colors.white,
                      //   ),
                      // ),
                      // const SizedBox(height: 15),
                      Text(
                        title,
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                //FORMULÁRIO
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(30),
                    decoration: const BoxDecoration(
                      color: Color(0xFFD4D4D4),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, -5),
                        ),
                      ],
                    ),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }
}
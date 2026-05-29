/* Autor: Rafael Henrique dos Santos Inácio */

import 'package:flutter/material.dart';
import 'package:mescla_invest_app/features/auth/presentation/theme/background_painter.dart';
import 'package:mescla_invest_app/routes/app_routes.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          //FUNDO GRADIENTE
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF353988),
                  Color(0xFFDB0065)
                ],
                stops: [0.65, 0.95],
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
              ),
            ),
          ),
          // CONTEÚDO
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              // 1. Forçamos a largura total para que a centralização funcione
              child: SizedBox(
                width: double.infinity, 
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(),

                    // TEXTO, LOGO e NOME (Mantidos)
                    const Text("Bem-vindo ao", style: TextStyle(color: Colors.white, fontSize: 18)),
                    const SizedBox(height: 10),
                    Image.asset('assets/images/logo_app.png', width: 100),
                    const SizedBox(height: 10),
                    const Text(
                      "MesclaInvest",
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),

                    const Spacer(),

                    // BOTÃO ENTRAR (60% da largura)
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.6,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE60073),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text("Entrar", style: TextStyle(color: Colors.white)),
                      ),
                    ),

                    const SizedBox(height: 10),
                    const Text("ou", style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 10),

                    // BOTÃO CADASTRO (Ajustado para 60% também, para não quebrar a tela)
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.6, 
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text("Criar conta"),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
/* Autor: Livia Lucizano */
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF9C27B0), // Cor roxa
              Color(0xFFFF4081), // Cor rosa
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Container(
              width: 350,
              decoration: BoxDecoration(
                color: Colors.deepPurple, // Cor roxa escura
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Título de boas-vindas
                  Text(
                    'Bem-vindo ao',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'MesclaInvest',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 40),

                  // Botão para "Criar conta"
                  ElevatedButton(
                    onPressed: () {
                      // Navegar para a tela de cadastro
                      Navigator.pushNamed(context, '/signup');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFF4081), // Cor do botão
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Criar conta',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // "ou" entre os botões
                  Text(
                    'ou',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),

                  SizedBox(height: 20),

                  // Botão para "Entrar"
                  ElevatedButton(
                    onPressed: () {
                      // Navegar para a tela de login
                      Navigator.pushNamed(context, '/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFBB86FC), // Cor do botão
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Entrar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
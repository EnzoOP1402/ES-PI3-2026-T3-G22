/* Autor: Livia Lucizano */

import 'package:flutter/material.dart';

class CadastroScreen extends StatelessWidget {
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
                    'Ainda não possui uma conta no MesclaInvest? ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  
                  SizedBox(height: 40),

                  // Introdução
                  Text(
                    'Escolha como deseja se cadastrar:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),

                  // Botão para cadastrar como usuário
                  ElevatedButton(
                    onPressed: () {
                      // Navegar para a tela de cadastro de usuário
                      Navigator.pushNamed(context, '/cadastro_usuario');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFF4081), // Cor do botão
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Cadastrar como Usuário',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // Botão para cadastrar como startup
                  ElevatedButton(
                    onPressed: () {
                      // Navegar para a tela de cadastro de startup
                      Navigator.pushNamed(context, '/cadastro_startup');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFBB86FC), // Cor do botão
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Cadastrar como Startup',
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
/* Autor: Enzo Olivato Pazian */

// Importação das dependências
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:mescla_invest_app/features/auth/data/repositories/auth_repository.dart';
import 'package:mescla_invest_app/features/auth/presentation/screens/welcome_screen.dart';
import 'package:mescla_invest_app/features/catalog/presentation/screens/startup_catalog_screen.dart';

// Criando a classe responsável por identificar o estado da autenticação do usuário e
// alternar qual tela será exibida: com sessão -> catálogo; sem sessão -> tela de recepção
class AuthWrapper extends StatelessWidget {
  // Declarando o construtor com a chave de sua superclasse
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Usando o StreamBuilder nativo para ouvir as mudanças de estado
    return StreamBuilder<User?>(
      // O observador de stream vem do Singleton definido no AuthRepository
      stream: AuthRepository.instance.authStateChange,
      builder: (context, snapshot) {
        // Verificando o estado da conexão enquanto carrega o token do usuário
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF353988),
              ),
            ),
          );
        }

        // Se houver algum erro na stream, exibe uma página de erro
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text('Erro ao verificar autenticação'),
            ),
          );
        }

        // Se houver usuário logado, abre o catálogo.
        // Se não houver usuário logado, abre a tela de recepção.
        if (snapshot.hasData) {
          return const Catalogo();
        } else {
          return const WelcomeScreen();
        }
      },
    );
  }
}
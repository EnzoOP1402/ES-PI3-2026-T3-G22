/* Autor: Enzo Olivato Pazian */

// AVISO: Ao fazer as telas, usem esse arquivo para rodar o app e testá-las,
// mas, quando vocês finalizarem o desenvolimento e fizerem o último commit,
// voltem essa tela ao estado original (esta versão) para evitar conflitos de merge.

// Importação das dependências
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mescla_invest_app/core/widgets/auth_wrapper.dart';
import 'firebase_options.dart';

// Função principal: ponto de entrada da aplicação
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Função responsável por executar a aplicação
  runApp(const MesclaInvest());
}

// Widget que representa a aplicação
class MesclaInvest extends StatelessWidget {
  // Construtor da aplicação (herda o atributo key de sua superclasse)
  const MesclaInvest({super.key});

  // Raiz da aplicação
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MesclaInvest',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      // Definindo a página de recepção como a página inicial do aplicativo
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
    );
  }
}
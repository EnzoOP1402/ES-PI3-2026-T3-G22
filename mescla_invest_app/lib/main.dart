/* Autor: Enzo Olivato Pazian */

// AVISO: Ao fazer as telas, usem esse arquivo para rodar o app e testá-las,
// mas, quando vocês finalizarem o desenvolimento e fizerem o último commit,
// voltem essa tela ao estado original (esta versão) para evitar conflitos de merge.

// Importação das dependências
import 'package:flutter/material.dart';

// Função principal: ponto de entrada da aplicação
void main() {
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
      home: const ReceptionPage(title: 'MesclaInvest'),
    );
  }
}

// A página de recepção poderá ser separada e será reestilizada. Esta tela é, por enquanto, apenas um protótipo.

// Widget que representa a página de recepção (possui controle de estado)
class ReceptionPage extends StatefulWidget {
  const ReceptionPage({super.key, required this.title});

  final String title;

  @override
  State<ReceptionPage> createState() => _ReceptionPageState();
}

// Classe que possui os elementos gráficos e o controle de estado da página de recepção
class _ReceptionPageState extends State<ReceptionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        // Título da aplicação trazido do construtor
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            Text(
              'Seja bem-vindo ao MesclaInvest!',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

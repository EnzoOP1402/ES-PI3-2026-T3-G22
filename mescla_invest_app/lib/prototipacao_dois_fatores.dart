/* Autor: Murillo Caravita */

// Importação das dependências
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


// // Função principal: ponto de entrada da aplicação
// void main() {
//   // Função responsável por executar a aplicação
//   runApp(const MesclaInvest());
// }

// Widget que representa a aplicação 
class MesclaInvest extends StatelessWidget {
  // Construtor da aplicação (herda o atributo key de sua superclasse)
  const MesclaInvest({super.key});

  // Raiz da aplicação
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MesclaInvest',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      // Definindo a página de recepção como a página inicial do aplicativo
      home: const AutenticacaoPage(title: 'MesclaInvest'),
    );
  }
}

// A página de recepção poderá ser separada e será reestilizada. Esta tela é, por enquanto, apenas um protótipo.

// Widget que representa a página de recepção (possui controle de estado)
class AutenticacaoPage extends StatefulWidget {
  const AutenticacaoPage({super.key, required this.title});

  final String title;

  @override
  State<AutenticacaoPage> createState() => _AutenticacaoPageState();
}

// Classe que possui os elementos gráficos e o controle de estado da página de recepção
class _AutenticacaoPageState extends State<AutenticacaoPage> {

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
            Row(
              mainAxisAlignment:  MainAxisAlignment.center,
              children: [
                const Text(
                  'Autenticação de 2 Fatores',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              ],
            ),
        
            Row(
              mainAxisAlignment:  MainAxisAlignment.center,
              children: [
                const Text(
                  'Informe o código de 2 dígitos enviado para o e-mail fulano@gmail.com.',
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),

            Row(
              mainAxisAlignment:  MainAxisAlignment.center,
              children: [
                Container(
                  width: 200.0,
                  margin: const EdgeInsets.symmetric(vertical: 20.0),
                  child: TextField(
                    keyboardType: TextInputType.number,
                    maxLength: 2,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Código',
                      counterText: '',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
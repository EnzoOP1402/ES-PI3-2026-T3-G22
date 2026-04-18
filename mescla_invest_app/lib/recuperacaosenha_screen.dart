/* Autor: Livia Lucizano */
import 'package:flutter/material.dart';

class RecuperacaoSenhaScreen extends StatefulWidget {
  @override
  _RecuperacaoSenhaScreenState createState() => _RecuperacaoSenhaScreenState();
}

class _RecuperacaoSenhaScreenState extends State<RecuperacaoSenhaScreen> {
  final _emailController = TextEditingController();
  String? _emailError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recuperação de Senha'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
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
              height: 500,
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
                  // Título de recuperação de senha
                  Text(
                    'Recuperar Senha',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Digite o e-mail utilizado no cadastro para enviarmos um código de recuperação.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 40),

                  // Campo E-mail com asterisco e mensagem de campo obrigatório
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'E-mail *',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '* Campo obrigatório',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      errorText: _emailError,
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20),
                      errorStyle: TextStyle(color: Colors.white),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 20),

                  // Botão Enviar
                  ElevatedButton(
                    onPressed: () {
                      String email = _emailController.text;
                      setState(() {
                        _emailError = null;
                      });

                      if (email.isEmpty || !email.contains('@')) {
                        setState(() {
                          _emailError = "Por favor, insira um e-mail válido.";
                        });
                      } else {
                        // Lógica para enviar o código, se necessário
                        print('Código enviado para: $email');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFF4081), // Cor do botão
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Enviar',
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
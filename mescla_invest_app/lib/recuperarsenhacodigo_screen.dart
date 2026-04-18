/* Autor: Livia Lucizano */
import 'package:flutter/material.dart';

class RecuperacaoSenhaCodigoScreen extends StatefulWidget {
  @override
  _RecuperacaoSenhaCodigoScreenState createState() => _RecuperacaoSenhaCodigoScreenState();
}

class _RecuperacaoSenhaCodigoScreenState extends State<RecuperacaoSenhaCodigoScreen> {
  final _codigoController = TextEditingController();
  String? _codigoError;

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
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Informe o código de verificação enviado para o seu e-mail.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 40),

                  // Campo Código com asterisco e mensagem de campo obrigatório
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Código *',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  TextField(
                    controller: _codigoController,
                    decoration: InputDecoration(
                      errorText: _codigoError,
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20),
                      errorStyle: TextStyle(color: Colors.white),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 20),

                  // Botão Verificar
                  ElevatedButton(
                    onPressed: () {
                      String codigo = _codigoController.text;
                      setState(() {
                        _codigoError = null;
                      });

                      if (codigo.isEmpty) {
                        setState(() {
                          _codigoError = "Código é obrigatório.";
                        });
                      } else {
                        // Lógica para verificar o código, se necessário
                        print('Código verificado: $codigo');
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
                      'Verificar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Link para "Enviar novo código"
                  TextButton(
                    onPressed: () {
                      // Ação para enviar novo código
                    },
                    child: Text(
                      'Enviar novo código',
                      style: TextStyle(color: Colors.white),
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
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Função de login (simulada)
  void _login() {
    String email = _emailController.text;
    String password = _passwordController.text;
    
    if (email.isNotEmpty && password.isNotEmpty) {
      // Aqui, você pode adicionar lógica de autenticação, como verificar os dados no servidor.
      print('Login com Email: $email e Senha: $password');
    } else {
      print('Por favor, preencha todos os campos.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tela de Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Campo de e-mail
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 20),
              
              // Campo de senha
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(),
                ),
                obscureText: true, // Esconde o texto da senha
              ),
              SizedBox(height: 20),
              
              // Botão de login
              ElevatedButton(
                onPressed: _login,
                child: Text('Entrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
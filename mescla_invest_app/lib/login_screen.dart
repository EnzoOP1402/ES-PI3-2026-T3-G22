/* Autor: Livia Lucizano */
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  String? _emailError;
  String? _passwordError;

  // Função de login (simulada)
  void _login() {
    String email = _emailController.text;
    String password = _passwordController.text;

    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    if (email.isEmpty && password.isEmpty) {
      setState(() {
        _emailError = "E-mail é obrigatório";
        _passwordError = "Senha é obrigatória";
      });
    } else if (email.isEmpty) {
      setState(() {
        _emailError = "E-mail é obrigatório";
      });
    } else if (password.isEmpty) {
      setState(() {
        _passwordError = "Senha é obrigatória";
      });
    } else if (!email.contains('@')) {
      setState(() {
        _emailError = "Por favor, insira um e-mail válido";
      });
    } else {
      print('Login com Email: $email e Senha: $password');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tela de Login'),
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
                  // Texto de boas-vindas
                  Text(
                    'Seja bem-vindo!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'É muito bom te ter de volta.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 40),

                  // Campo de e-mail com asterisco e mensagem de campo obrigatório
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
                          fontSize: 14,
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
                        borderSide: BorderSide(color: Colors.white), // Cor da borda
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20),
                      errorStyle: TextStyle(color: Colors.white), // Cor do texto de erro
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 20),
                  
                  // Campo de senha com asterisco e mensagem de campo obrigatório
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Senha *',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  TextField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      errorText: _passwordError,
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.white), // Cor da borda
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20),
                      errorStyle: TextStyle(color: Colors.white), // Cor do texto de erro
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  
                  // Botão de login
                  ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFBB86FC), // Cor do botão
                      foregroundColor: Colors.white, // Cor do texto do botão
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: Text('Entrar'),
                  ),
                  SizedBox(height: 10),
                  
                  // Link para "Esqueceu a senha?"
                  TextButton(
                    onPressed: () {
                      // Ação para a recuperação de senha
                    },
                    child: Text(
                      'Esqueceu a senha?',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),

                  // Link para "Não possui cadastro?"
                  TextButton(
                    onPressed: () {
                      // Ação para cadastrar
                    },
                    child: Text(
                      'Não possui cadastro?',
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
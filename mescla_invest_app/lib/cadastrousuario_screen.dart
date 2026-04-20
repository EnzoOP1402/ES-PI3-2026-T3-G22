/* Autor: Livia Lucizano */
import 'package:flutter/material.dart';

class CadastroUsuarioScreen extends StatefulWidget {
  @override
  _CadastroUsuarioScreenState createState() => _CadastroUsuarioScreenState();
}

class _CadastroUsuarioScreenState extends State<CadastroUsuarioScreen> {
  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _isPasswordVisible = false;

  String? _nomeError;
  String? _cpfError;
  String? _emailError;
  String? _telefoneError;
  String? _senhaError;

  // Função de cadastro (simulada)
  void _cadastrar() {
    String nome = _nomeController.text;
    String cpf = _cpfController.text;
    String email = _emailController.text;
    String telefone = _telefoneController.text;
    String senha = _senhaController.text;

    setState(() {
      _nomeError = null;
      _cpfError = null;
      _emailError = null;
      _telefoneError = null;
      _senhaError = null;
    });

    if (nome.isEmpty) {
      setState(() {
        _nomeError = "Nome completo é obrigatório";
      });
    }
    if (cpf.isEmpty) {
      setState(() {
        _cpfError = "CPF é obrigatório";
      });
    }
    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        _emailError = "E-mail é obrigatório e deve ser válido";
      });
    }
    if (telefone.isEmpty) {
      setState(() {
        _telefoneError = "Telefone é obrigatório";
      });
    }
    if (senha.isEmpty || senha.length < 8) {
      setState(() {
        _senhaError = "Senha é obrigatória";
      });
    } else {
      print('Cadastro realizado com Nome: $nome, CPF: $cpf, Email: $email');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView( // Permite rolagem
        child: Container(
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
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    // Título da tela de cadastro
                    Text(
                      'Crie sua conta',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    // Centralizando a frase
                    Text(
                      'e faça parte da melhor plataforma de investimentos.',
                      textAlign: TextAlign.center, // Centraliza o texto
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 40),

                    // Campo Nome Completo
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Nome completo *',
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
                      controller: _nomeController,
                      decoration: InputDecoration(
                        errorText: _nomeError,
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 20),
                        errorStyle: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Campo CPF
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'CPF',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    TextField(
                      controller: _cpfController,
                      decoration: InputDecoration(
                        errorText: _cpfError,
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 20),
                        errorStyle: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Campo E-mail
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'E-mail',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
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

                    // Campo Telefone
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Telefone',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    TextField(
                      controller: _telefoneController,
                      decoration: InputDecoration(
                        errorText: _telefoneError,
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 20),
                        errorStyle: TextStyle(color: Colors.white),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 20),

                    // Campo Senha
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Senha',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    TextField(
                      controller: _senhaController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        errorText: _senhaError,
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 20),
                        errorStyle: TextStyle(color: Colors.white),
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

                    // Frase explicativa para a senha
                    Text(
                      '* Sua senha deve conter pelo menos 8 caracteres, entre eles, 1 número, 1 letra e 1 caractere especial.',
                      textAlign: TextAlign.center, // Centraliza o texto
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 20),

                    // Botão de cadastro
                    ElevatedButton(
                      onPressed: _cadastrar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFBB86FC), // Cor do botão
                        foregroundColor: Colors.white, // Cor do texto do botão
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: Text('Cadastrar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
/* Autor: Livia Lucizano */

import 'package:flutter/material.dart';
import 'package:mescla_invest_app/data/repositories/auth_repository.dart';
import 'package:mescla_invest_app/presentation/screens/password_recovery_screen.dart';
import 'package:mescla_invest_app/presentation/screens/register_screen.dart';
import 'package:mescla_invest_app/presentation/widgets/snackbar_utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Variável controladora do carregamento da página
  // Quando o login entra em operação, ela muda de valor e aciona a tela de carregamento,
  // fazendo com que o usuário não consiga apertar múltiplas vezes o mesmo botão e enviar
  // várias requisições ao Firebase
  bool _isLoading = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool obscureText = true;
  bool obscureConfirm = true;

  // Método usado para eliminar variáveis, objetos, etc da árvore de elementos para liberar memória.
  // Ele é chamado quando o widget é removido da Widget tree, por exemplo, quando saímos dessa página
  @override
  void dispose() {
    // Elimina os controladores
    _emailController.dispose();
    _passwordController.dispose();
    // Elimina todas as variáveis usadas na página
    super.dispose();
  }

  // Função que lida com o Login dos usuários
  // Ela é responsável por acionar a função do repositório que lida com a autenticação do app
  // e exibe a snackbar com os erros encontrados
  Future<void> _handleLogin() async{
    // Se o estado atual do formulário com os campos validados for nulo,
    // executa as operações
    if (_formKey.currentState?.validate() ?? false) {
      try {
        // Muda o estado para mudar o valor do indicador de carregamento e acionar
        // a renderização da tela de carregamento no Scaffold
        setState( () => _isLoading = true,);

        // Executando o login do usuário
        // Invoca a instância do repositório de autenticação e aciona o método de login,
        // passando como parâmetro os valores obtidos dos controladores dos inputs
        await AuthRepository.instance.login(_emailController.text.trim(), _passwordController.text.trim());
      }
      catch (e) {
        // Se o Widget foi destruído, encerra a função
        if(!mounted) return;
        // Chama a função responsável por exibir erros na snackbar, passando como parâmetro o erro encontrado
        showErrorSnackBar(context, e.toString());
      }
      finally {
        // Se a operação foi bem sucedida e o widget não foi destruído, atualiza o controlador de carregamento
        if (mounted) setState(() => _isLoading = false,);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: _isLoading ?
        Center(child: CircularProgressIndicator(),) :
        SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              // EMAIL
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o email';
                  }
                  if (!value.contains('@')) {
                    return 'Email inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // SENHA
              TextFormField(
                obscureText: obscureText,
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        obscureText = !obscureText;
                      });
                    },
                    icon: Icon(
                      obscureText
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe a senha';
                  }
                  return null;
                },
              ),
              
              // Definindo uma caixa de espaçamento
              const SizedBox(height: 16,),

              // Link para a tela de esqueci a senha
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PasswordRecoveryScreen())),
                child: Text("Esqueceu a senha?")
              ),

              const SizedBox(height: 24),
              // BOTÃO
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _handleLogin,
                  child: const Text('Entrar'),
                ),
              ),

              // Definindo uma caixa de espaçamento
              const SizedBox(height: 16,),

              // Link para a tela de cadastro
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen())),
                child: Text("Cadastre-se")
              ),
              
              // Definindo uma caixa de espaçamento
              const SizedBox(height: 16,),
            ],
          ),
        ),
      ),
    );
  }
}
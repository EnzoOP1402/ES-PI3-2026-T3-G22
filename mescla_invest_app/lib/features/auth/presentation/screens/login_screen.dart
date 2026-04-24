/* Autor: Livia Lucizano */
import 'package:flutter/material.dart';

import 'package:mescla_invest_app/features/auth/data/repositories/auth_repository.dart';
import 'package:mescla_invest_app/core/utils/snackbar_utils.dart';
import 'package:mescla_invest_app/features/auth/presentation/widgets/auth_button.dart';
import 'package:mescla_invest_app/features/auth/presentation/widgets/auth_input.dart';
import 'package:mescla_invest_app/features/auth/presentation/widgets/auth_layout.dart';
import 'package:mescla_invest_app/routes/app_routes.dart';

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

  // Variável controladora da propriedade de visibilidade da senha
  bool obscureText = true;

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

        // Se a operação foi bem sucedida e o widget não foi destruído, volta para a base da pilha de telas,
        // permitindo que o AuthWrapper perceba o login e mostre a tela inicial
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
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
    // Se estiver carregando, ainda precisamos do AuthLayout para manter o fundo/estilo
    if (_isLoading) {
      return const AuthLayout(
        title: "Seja bem-vindo!",
        subtitle: "É muito bom te ter de volta.",
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return AuthLayout(
      title: "Seja bem-vindo!",
      subtitle: "É muito bom te ter de volta.",
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // EMAIL
              AuthInput(
                hint: "E-mail",
                controller: _emailController,
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
              AuthInput(
                hint: "Senha",
                controller: _passwordController,
                obscure: obscureText,
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe a senha';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 10),

              // ESQUECEU SENHA
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.recover);
                  },
                  child: const Text(
                    "Esqueceu a senha?",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // BOTÃO LOGIN
              AuthButton(
                text: "Entrar",
                onPressed: _handleLogin,
              ),

              const SizedBox(height: 20),

              // IR PARA CADASTRO
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Não tem conta?"),
                  TextButton(
                    onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.register);
                      },
                    child: Text(
                      " Cadastrar",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE60073),
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ) 
    );
  }
}
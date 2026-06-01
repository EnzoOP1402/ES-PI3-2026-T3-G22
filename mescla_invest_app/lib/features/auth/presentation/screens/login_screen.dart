/* Autor: Livia Lucizano - RA: 25017514*/

// Importa os pacotes e arquivos necessários para a tela de login
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mescla_invest_app/core/utils/snackbar_utils.dart';
import 'package:mescla_invest_app/features/auth/presentation/widgets/auth_button.dart';
import 'package:mescla_invest_app/features/auth/presentation/widgets/auth_input.dart';
import 'package:mescla_invest_app/features/auth/presentation/widgets/auth_layout.dart';
import 'package:mescla_invest_app/features/auth/presentation/screens/2fa_screen.dart';
import 'package:mescla_invest_app/routes/app_routes.dart';

// Tela de login do aplicativo
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// Estado da tela de login
class _LoginScreenState extends State<LoginScreen> {
  // Chave do formulário para validar os campos antes do login
  final _formKey = GlobalKey<FormState>();

  // Controla estado de carregamento e visibilidade da senha
  bool _isLoading = false;
  bool obscureText = true;

  // Controllers dos campos de e-mail e senha
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    // Libera os controllers ao destruir a tela
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

   // Converte os códigos de erro do Firebase em mensagens mais claras para o usuário
  String _mapFirebaseLoginError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'user-not-found':
        return 'Usuário não encontrado.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-mail ou senha inválidos.';
      case 'user-disabled':
        return 'Esta conta foi desativada.';
      case 'too-many-requests':
        return 'Muitas tentativas. Aguarde alguns minutos e tente novamente.';
      case 'network-request-failed':
        return 'Sem conexão com a internet. Verifique sua rede.';
      case 'multi-factor-auth-required':
      case 'second-factor-required':
        return 'É necessário confirmar o segundo fator de autenticação.';
      default:
        return e.message ?? 'Erro ao fazer login.';
    }
  }
  // Função chamada quando o usuário clica no botão "Entrar"
  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // Remove espaços extras do e-mail e pega a senha digitada
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      // Ativa o estado de carregamento
      setState(() => _isLoading = true);

      // Define que a sessão do usuário será mantida apenas durante a sessão atual
      await FirebaseAuth.instance.setPersistence(Persistence.SESSION);

      // Tenta fazer login com e-mail e senha no Firebase
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Verifica se a tela ainda está ativa antes de navegar
      if (!mounted) return;

      // Após login bem-sucedido, volta para a primeira rota da pilha
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on FirebaseAuthMultiFactorException catch (e) {
      
      // Caso a conta tenha autenticação de dois fatores ativada
      if (!mounted) return;

      // Exibe mensagem informando que o segundo fator é necessário
      showErrorSnackBar(
        context,
        'Segundo fator necessário. Confirme o código enviado ao seu celular.',
      );

      // Abre a tela de verificação em duas etapas
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TwoFAScreen(
            resolver: e.resolver,
          ),
        ),
      );
      // Trata erros conhecidos do Firebase Auth
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      showErrorSnackBar(context, _mapFirebaseLoginError(e));
    } catch (e) {
      // Trata qualquer erro inesperado
      if (!mounted) return;
      showErrorSnackBar(context, 'Erro inesperado: $e');
    } finally {
      // Desativa o carregamento ao finalizar a tentativa de login
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Exibe loading enquanto o login está em andamento
    if (_isLoading) {
      return const AuthLayout(
        title: "Seja bem-vindo!",
        subtitle: "É muito bom te ter de volta.",
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // Layout principal da tela de login
    return AuthLayout(
      title: "Seja bem-vindo!",
      subtitle: "É muito bom te ter de volta.",
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Campo de e-mail
              AuthInput(
                hint: "E-mail",
                controller: _emailController,
                validator: (value) {
                  // Verifica se o campo está vazio
                  if (value == null || value.isEmpty) {
                    return 'Informe o email';
                  }
                  // Verifica se o e-mail possui "@"
                  if (!value.contains('@')) {
                    return 'Email inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo de senha
              AuthInput(
                hint: "Senha",
                controller: _passwordController,
                obscure: obscureText,

                // Ícone para mostrar ou esconder a senha
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      obscureText = !obscureText;
                    });
                  },
                  icon: Icon(
                    obscureText ? Icons.visibility : Icons.visibility_off,
                  ),
                ),
                validator: (value) {
                  // Verifica se a senha foi informada
                  if (value == null || value.isEmpty) {
                    return 'Informe a senha';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // Link para recuperação de senha
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

              // Botão principal de login
              AuthButton(
                text: "Entrar",
                onPressed: _handleLogin,
              ),
              const SizedBox(height: 20),

              // Link para cadastro
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Não tem conta?"),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.register);
                    },
                    child: const Text(
                      " Cadastrar",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE60073),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
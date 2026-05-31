/* Autor: Livia Lucizano */
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mescla_invest_app/core/utils/snackbar_utils.dart';
import 'package:mescla_invest_app/features/auth/presentation/widgets/auth_button.dart';
import 'package:mescla_invest_app/features/auth/presentation/widgets/auth_input.dart';
import 'package:mescla_invest_app/features/auth/presentation/widgets/auth_layout.dart';
import 'package:mescla_invest_app/features/auth/presentation/screens/2fa_screen.dart';
import 'package:mescla_invest_app/routes/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

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

  // Traduz erros comuns do Firebase em mensagens mais amigáveis
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

  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      setState(() => _isLoading = true);

      await FirebaseAuth.instance.setPersistence(Persistence.SESSION);

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on FirebaseAuthMultiFactorException catch (e) {
      if (!mounted) return;

      showErrorSnackBar(
        context,
        'Segundo fator necessário. Confirme o código enviado ao seu celular.',
      );

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TwoFAScreen(
            resolver: e.resolver,
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      showErrorSnackBar(context, _mapFirebaseLoginError(e));
    } catch (e) {
      if (!mounted) return;
      showErrorSnackBar(context, 'Erro inesperado: $e');
    } finally {
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

              // Campo de senha
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
                    obscureText ? Icons.visibility : Icons.visibility_off,
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
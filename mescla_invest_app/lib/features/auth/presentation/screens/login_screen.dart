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
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool obscureText = true;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    try {
      setState(() => _isLoading = true);

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on FirebaseAuthMultiFactorException catch (e) {
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TwoFAScreen(
            resolver: e.resolver,
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      showErrorSnackBar(context, e.message ?? 'Erro ao fazer login.');
    } catch (e) {
      if (!mounted) return;
      showErrorSnackBar(context, 'Erro inesperado: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              AuthButton(
                text: "Entrar",
                onPressed: _handleLogin,
              ),
              const SizedBox(height: 20),
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
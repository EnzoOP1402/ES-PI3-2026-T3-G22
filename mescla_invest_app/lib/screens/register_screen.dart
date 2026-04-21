/* Autor: Gabriela Sichiroli Ferrari */

import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _cpfController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  final cpfMask = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final telefoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  bool obscureText = true;
  bool obscureConfirm = true;

  bool hasUppercase = false;
  bool hasNumber = false;
  bool hasMinLength = false;
  bool hasSpecialChar = false;
  bool showRequirements = false;

  bool get senhaValida =>
      hasUppercase && hasNumber && hasMinLength && hasSpecialChar;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _cpfController.dispose();
    _telefoneController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadastro realizado com sucesso!')),
      );
    }
  }

  Widget _buildRequirement(String text, bool isValid) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check : Icons.close,
          color: isValid ? Colors.green : Colors.red,
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: isValid ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // NOME
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome completo',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o nome completo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

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

              // CPF
              TextFormField(
                controller: _cpfController,
                inputFormatters: [cpfMask],
                decoration: const InputDecoration(
                  labelText: 'CPF',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o CPF';
                  }
                  if (value.length < 14) {
                    return 'CPF incompleto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // TELEFONE
              TextFormField(
                controller: _telefoneController,
                inputFormatters: [telefoneMask],
                decoration: const InputDecoration(
                  labelText: 'Telefone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o telefone';
                  }
                  if (value.length < 15) {
                    return 'Telefone incompleto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // SENHA
              TextFormField(
                obscureText: obscureText,
                controller: _senhaController,
                onChanged: (value) {
                  setState(() {
                    showRequirements = true;
                    hasUppercase = value.contains(RegExp(r'[A-Z]'));
                    hasNumber = value.contains(RegExp(r'[0-9]'));
                    hasMinLength = value.length >= 8;
                    hasSpecialChar = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
                  });
                },
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
                  if (!senhaValida) {
                    return 'Senha não atende os requisitos';
                  }
                  return null;
                },
              ),

              // REQUISITOS
              if (showRequirements) ...[
                const SizedBox(height: 8),
                _buildRequirement(
                    "Pelo menos 1 letra maiúscula", hasUppercase),
                _buildRequirement(
                    "Pelo menos 1 número", hasNumber),
                _buildRequirement(
                    "Mínimo 8 caracteres", hasMinLength),
                _buildRequirement(
                    "Pelo menos 1 caractere especial",
                    hasSpecialChar),
              ],

              const SizedBox(height: 16),

              // CONFIRMAR SENHA (SÓ APARECE SE FOR VÁLIDA)
              if (senhaValida) ...[
                TextFormField(
                  obscureText: obscureConfirm,
                  controller: _confirmarSenhaController,
                  onTap: () {
                    setState(() {
                      showRequirements = false;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Confirmar senha',
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          obscureConfirm = !obscureConfirm;
                        });
                      },
                      icon: Icon(
                        obscureConfirm
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirme a senha';
                    }
                    if (value != _senhaController.text) {
                      return 'As senhas estão diferentes';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 24),
              // BOTÃO
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submit,
                  child: const Text('Cadastrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
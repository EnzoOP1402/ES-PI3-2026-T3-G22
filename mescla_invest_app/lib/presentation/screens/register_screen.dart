/* Autor: Gabriela Sichiroli Ferrari */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:mescla_invest_app/data/models/user_model.dart';
import 'package:mescla_invest_app/data/repositories/auth_repository.dart';
import 'package:mescla_invest_app/presentation/widgets/snackbar_utils.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Variável controladora do carregamento da página
  // Quando o login entra em operação, ela muda de valor e aciona a tela de carregamento,
  // fazendo com que o usuário não consiga apertar múltiplas vezes o mesmo botão e enviar
  // várias requisições ao Firebase
  bool _isLoading = false;

  // Declarando o controlador do campo de nome
  final TextEditingController _nameController = TextEditingController();
  // Declarando o controlador do campo de email
  final TextEditingController _emailController = TextEditingController();
  // Declarando o controlador do campo de cpf
  final TextEditingController _cpfController = TextEditingController();
  // Declarando o controlador do campo de telefone
  final TextEditingController _phoneController = TextEditingController();
  // Declarando o controlador do campo de senha
  final TextEditingController _passwordController = TextEditingController();
  // Declarando o controlador do campo de confirmação senha
  final TextEditingController _confirmPasswordController = TextEditingController();

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

  // Método usado para eliminar variáveis, objetos, etc da árvore de elementos para liberar memória. Ele é chamado quando o widget é removido da Widget tree, por exemplo, quando saímos dessa página
  @override
  void dispose() {
    // Elimina os controladores
    _nameController.dispose();
    _emailController.dispose();
    _cpfController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    // Elimina todas as variáveis usadas na página
    super.dispose();
  }

  // Função que lida com o cadastro dos usuários
  // Ela é responsável por acionar a função do repositório que lida com a autenticação de novos usuários do app
  // e exibe a snackbar com os erros encontrados
  void _handleRegister() async {
    // Se o estado atual do formulário com os campos validados for nulo, executa as operações
    if (_formKey.currentState?.validate() ?? false) {
      try {
        // Muda o estado para mudar o valor do indicador de carregamento e acionar
        // a renderização da tela de carregamento no Scaffold
        setState( () => _isLoading = true,);

        // Obtendo os dados do usuário a partir dos valores armazenados nos controladores do formulário
        final newUser = UserModel(
          uid: '', // O repositório preencherá isso
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          cpf: _cpfController.text.trim(),
          phone: _phoneController.text.trim(),
          createdAt: Timestamp.now(),
        );

        // Executando o cadastro do usuário
        // Invoca a instância do repositório de autenticação e aciona o método de cadastro,
        // passando como parâmetro o objeto de usuário criado e a senha contida no controlador do input
        await AuthRepository.instance.register(newUser, _confirmPasswordController.text.trim());
        
        // Se a operação foi bem sucedida e o widget não foi destruído, volta para a base da pilha de telas,
        // permitindo que o AuthWrapper perceba o login e mostre a tela inicial
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      }
      catch (e) {
        // Se o Widget foi destruído, encerra a função
        if(!mounted) return;
        // Cas contrário, chama a função responsável por exibir erros na snackbar
        showErrorSnackBar(context, e.toString());
      }
      finally {
        // Se deu certo e o widget não foi destruído, atualiza o controlador de carregamento
        if (mounted) setState(() => _isLoading = false,);
      }
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
      body: _isLoading ?
      Center(child: CircularProgressIndicator(),) :
      SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // NOME
              TextFormField(
                controller: _nameController,
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
                controller: _phoneController,
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
                controller: _passwordController,
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
                  controller: _confirmPasswordController,
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
                    if (value != _passwordController.text) {
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
                  onPressed: _handleRegister,
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
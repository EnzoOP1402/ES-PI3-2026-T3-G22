//Autor: Gabriela Sichiroli
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
// Widget principal do app (Stateless = não tem estado mutável)
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cadastro',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple, // Cor principal
        useMaterial3: true, // Ativa Material Design 3
      ),
      home: const CadastroPage(), // Tela inicial
    );
  }
}
// Tela de cadastro (Stateful = possui estado que pode mudar)
class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});
  @override
  State<CadastroPage> createState() => _CadastroPageState();
}
// Estado da tela (onde fica a lógica)
class _CadastroPageState extends State<CadastroPage> {
  // Chave do formulário (permite validar todos os campos)
  final _formKey = GlobalKey<FormState>();
  // Controllers capturam e controlam o texto digitado
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _cpfController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _senhaController = TextEditingController();
  // Máscara para CPF (formato: 000.000.000-00)
  final cpfMask = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')}, // só aceita números
  );

  // Máscara para telefone (formato: (00) 00000-0000)
  final telefoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  // Método chamado quando o widget é destruído
  @override
  void dispose() {
    // Libera memória dos controllers
    _nomeController.dispose();
    _emailController.dispose();
    _cpfController.dispose();
    _telefoneController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  // Função chamada ao clicar no botão
  void _submit() {
    // Valida todos os campos do formulário
    if (_formKey.currentState!.validate()) {
      // Se tudo estiver válido, mostra mensagem
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadastro realizado com sucesso!')),
      );
    }
  }
  bool obscureText = true;
  IconData iconPassword = Icons.visibility;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Espaçamento interno
        child: Form(
          key: _formKey, // Conecta o formulário à chave
          child: Column(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome completo',
                  border: OutlineInputBorder(),

                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  // Validação simples
                  if (value == null || value.isEmpty) {
                    return 'Informe o nome completo';
                  }
                  return null; // válido
                },
              ),
              const SizedBox(height: 16),
              // CAMPO EMAIL
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),

                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  // Validação simples
                  if (value == null || value.isEmpty) {
                    return 'Informe o email';
                  }
                  if (!value.contains('@')) {
                    return 'Email inválido';
                  }
                  return null; // válido
                },
              ),
              const SizedBox(height: 16),

              // CAMPO CPF
              TextFormField(
                controller: _cpfController,
                inputFormatters: [cpfMask], // aplica máscara
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

              // CAMPO TELEFONE
              TextFormField(
                controller: _telefoneController,
                inputFormatters: [telefoneMask], // aplica máscara
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

              // CAMPO SENHA
              TextFormField(
                obscureText: obscureText, // esconde o texto
                controller: _senhaController,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  suffixIcon: IconButton(
                    onPressed: (){
                      if (obscureText == true) {
                        setState(() {
                          obscureText = false;
                          iconPassword = Icons.visibility_off;
                        });
                      } else {
                        setState(() {
                          obscureText = true;
                          iconPassword = Icons.visibility;
                        });
                      }
                    },
                    icon: Icon(iconPassword),
                  ),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe a senha';
                  }
                  if (value.length < 6) {
                    return 'Mínimo 6 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // BOTÃO DE CADASTRO
              SizedBox(
                width: double.infinity, // ocupa largura total
                child: FilledButton(
                  onPressed: _submit, // chama função
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

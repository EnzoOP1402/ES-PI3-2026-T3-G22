/* Autor: Bernardo Castro Brandão de Oliveira */

import 'package:flutter/material.dart';
import 'package:mescla_invest_app/features/auth/data/repositories/auth_repository.dart';
import 'package:mescla_invest_app/core/utils/snackbar_utils.dart';

class PasswordRecoveryScreen extends StatefulWidget {
  const PasswordRecoveryScreen({super.key});

  @override
  State<PasswordRecoveryScreen> createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
  final _formKey = GlobalKey<FormState>();

  // Variável controladora do carregamento da página
  // Quando o envio de e-mail de recuperação entra em operação, ela muda de valor e aciona
  // a tela de carregamento, fazendo com que o usuário não consiga apertar múltiplas vezes
  // o mesmo botão e enviar várias requisições ao Firebase
  bool _isLoading = false;

  final _recoveryEmailController = TextEditingController();

  // Método usado para eliminar variáveis, objetos, etc da árvore de elementos para liberar memória. Ele é chamado quando o widget é removido da Widget tree, por exemplo, quando saímos dessa página
  @override
  void dispose() {
    // Elimina os controladores
    _recoveryEmailController.dispose();
    // Elimina todas as variáveis usadas na página
    super.dispose();
  }

  // Função que lida com a recuperação de senha dos usuários
  // Ela é responsável por acionar a função do repositório que lida com a recuperação de senha
  // referente à autenticação do app e exibe a snackbar com os erros encontrados
  Future<void> _handlePasswordRecovery() async{
    // Se o estado atual do formulário com os campos validados for nulo,
    // executa as operações
    if (_formKey.currentState?.validate() ?? false) {
      try {
        // Muda o estado para mudar o valor do indicador de carregamento e acionar
        // a renderização da tela de carregamento no Scaffold
        setState( () => _isLoading = true,);

        // Executando a recuperação de senha do usuário
        // Invoca a instância do repositório de autenticação e aciona o método de
        // recuperação de senha, passando como parâmetro o valor obtido do controlador do input
        await AuthRepository.instance.recoverPassword(_recoveryEmailController.text.trim());
        
        // Mostra um diálogo de sucesso e volta para o login
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("E-mail Enviado"),
              content: const Text("Verifique sua caixa de entrada para redefinir sua senha (não se esqueça de verificar o Spam)."),
              actions: [
                TextButton(
                  onPressed: () {
                    // Fecha o diálogo
                    Navigator.pop(context);
                    // Volta para a tela de Login
                    Navigator.pop(context);
                  },
                  child: const Text("OK"),
                ),
              ],
            ),
          );
        }
      }
      catch (e) {
        // Se o Widget foi destruído, encerra a função
        if(!mounted) return;
        // Chama a função responsável por exibir erros na snackbar
        showErrorSnackBar(context, e.toString());
      }
      finally {
        // Se deu certo e o widget não foi destruído, atualiza o controlador de carregamento
        if (mounted) setState(() => _isLoading = false,);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperação de senha'),
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
                controller: _recoveryEmailController,
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

              const SizedBox(height: 24),
              // BOTÃO
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _handlePasswordRecovery,
                  child: const Text('Enviar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
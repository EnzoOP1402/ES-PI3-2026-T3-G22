/* Autor: Bernardo Castro Brandão de Oliveira */

import 'package:flutter/material.dart';
import 'package:mescla_invest_app/features/auth/data/repositories/auth_repository.dart';
import 'package:mescla_invest_app/core/utils/snackbar_utils.dart';
import 'package:mescla_invest_app/features/auth/presentation/widgets/auth_button.dart';
import 'package:mescla_invest_app/features/auth/presentation/widgets/auth_input.dart';
import 'package:mescla_invest_app/features/auth/presentation/widgets/auth_layout.dart';

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
    // Se estiver carregando, ainda precisamos do AuthLayout para manter o fundo/estilo
    if (_isLoading) {
      return const AuthLayout(
        title: "Recuperar senha",
        subtitle: "Insira o e-mail utilizado em seu cadastro para enviarmos um link de recuperação.",
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return AuthLayout(
      title: "Recuperar senha",
      subtitle: "Insira o e-mail utilizado em seu cadastro para enviarmos um link de recuperação.",
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AuthInput(hint: "E-mail *",
                    controller:_recoveryEmailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Informe o e-mail';
                      }
                      if (!value.contains('@')) {
                        return 'E-mail inválido';
                      }
                      return null;
                    },
                  ),
              const SizedBox(height: 20),
              AuthButton(
                text: "Enviar",
                onPressed:_handlePasswordRecovery,
              ),
            ],
          ),
        ),
      ) 
    );
  }
}
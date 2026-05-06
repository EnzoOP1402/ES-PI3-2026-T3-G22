import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mescla_invest_app/core/utils/snackbar_utils.dart';
import 'package:mescla_invest_app/features/auth/data/repositories/auth_repository.dart';
import 'package:mescla_invest_app/features/auth/presentation/data/models/question_model.dart';
import 'package:mescla_invest_app/features/catalog/presentation/widgets/detailed_catalog_card_section.dart';

class PublicQuestions extends StatefulWidget {
  const PublicQuestions({super.key});

  @override
  State<PublicQuestions> createState() => _PublicQuestionsState();
}

class _PublicQuestionsState extends State<PublicQuestions> {
  // Definindo a chave do formulário do card
  final _formKey = GlobalKey<FormState>();
  // Definindo a chave do formulário do modal
  final _modalFormKey = GlobalKey<FormState>();
  
  // Variável controladora do carregamento da página
  // Quando o login entra em operação, ela muda de valor e aciona a tela de carregamento,
  // fazendo com que o usuário não consiga apertar múltiplas vezes o mesmo botão e enviar
  // várias requisições ao Firebase
  bool _isLoading = false;

  // Definindo o controlador do input de pergunta pública
  final _publicQuestionController = TextEditingController();

  // Definindo a variável que exibe a quantidade de perguntas públicas
  final int _publicQuestionsAmount = 0;

  // >> VARIÁVEIS DE TESTE <<
  // Após a integração, elas serão substituídas por outras variáveis que recebam os valores do banco
  final String _startupName = "NotaCerta LTDA";

  // Método usado para eliminar variáveis, objetos, etc da árvore de elementos para liberar memória.
  // Ele é chamado quando o widget é removido da Widget tree, por exemplo, quando saímos dessa página
  @override
  void dispose() {
    // Elimina os controladores
    _publicQuestionController.dispose();
    // Elimina todas as variáveis usadas na página
    super.dispose();
  }

  Future<void> _handlePublicQuestionSending() async {
    // Se o estado atual do formulário com os campos validados for nulo,
    // executa as operações
    if (_formKey.currentState?.validate() ?? false) {
      try {
        // Muda o estado para mudar o valor do indicador de carregamento e acionar
        // a renderização da tela de carregamento no Scaffold
        setState( () => _isLoading = true,);

        // Teste
        print("Mensagem enviada: ${_publicQuestionController.text}");

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
        _publicQuestionController.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Se estiver carregando, ainda precisamos do AuthLayout para manter o fundo/estilo
    // if (_isLoading) {
    //   return Scaffold(
    //     appBar: AppBar(
    //       backgroundColor: Colors.transparent,
    //       centerTitle: true,
    //       title: const Text("Catálogo"),
    //       foregroundColor: const Color(0xFF353988),
    //       actions: [
    //         TextButton.icon(
    //           onPressed: AuthRepository.instance.logout,
    //           label: Icon(Icons.logout)
    //         )
    //       ],
    //     ),
    //     body: Center(
    //       child: CircularProgressIndicator(),
    //     ),
    //   );
    // }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text("Catálogo"),
        foregroundColor: const Color(0xFF353988),
        actions: [
          TextButton.icon(
            onPressed: AuthRepository.instance.logout,
            label: Icon(Icons.logout)
          )
        ],
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 20,),
            // Sessão de perguntas públicas
            DetailedCatalogCardSection(
              // Definindo o título da sessão
              title: "Perguntas públicas",
              // Definindo o conteúdo da sessão
              children: [
                // Linha com a quantidade de perguntas e o disparador do Canvas
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${_publicQuestionsAmount} pergunta(s)",
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        showModalBottomSheet<void>(
                          isScrollControlled: true,
                          context: context,
                          builder: (BuildContext context) {
                            return Container(
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height * 0.9,
                              decoration: BoxDecoration(
                                color: const Color(0xFFD9D9D9),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20)
                                )
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  // Espaçamento
                                  SizedBox(
                                    height: 8,
                                  ),
                                  // "Ícone" para arrastar o modal ára baixo
                                  Container(
                                    width: 52,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFA2A2A2),
                                      borderRadius: BorderRadius.circular(5)
                                    ),
                                  ),
                                  // Espaçamento
                                  SizedBox(
                                    height: 12,
                                  ),
                                  // Cabeçalho com Stack para alinhamento independente
                                  SizedBox(
                                    width: double.infinity,
                                    child: Stack(
                                      // Centraliza os filhos por padrão
                                      alignment: Alignment.center,
                                      children: [
                                        // Título e Subtítulo (Sempre no centro)
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              "Perguntas públicas",
                                              style: GoogleFonts.montserrat(
                                                color: const Color(0xFF353988),
                                                fontWeight: FontWeight.w700,
                                                fontSize: 20,
                                              ),
                                            ),
                                            Text(
                                              _startupName,
                                              style: GoogleFonts.montserrat(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w400,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                        // 2. Ícone de Fechar (Posicionado na esquerda)
                                        Positioned(
                                          left: 12, // Margem da esquerda
                                          child: IconButton(
                                            onPressed: () => Navigator.pop(context),
                                            icon: const Icon(
                                              Icons.keyboard_arrow_down,
                                              color: Color(0xFF353988),
                                              size: 48, // Tamanho conforme indicado na sua imagem
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Espaçamento
                                  SizedBox(
                                    height: 12,
                                  ),
                                  // Linha divisória
                                  Container(
                                    height: 1,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFA2A2A2)
                                    ),
                                  ),
                                  // Espaçamento
                                  SizedBox(
                                    height: 16,
                                  ),
                                  // Conteúdo principal
                                  Expanded(
                                    // Perguntas
                                    child: SingleChildScrollView(
                                      child: Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Column(
                                          children: [
                                            // Aqui entram seus cards de perguntas (Juliano, Fernanda, etc.)
                                            const Text("Lista de perguntas será renderizada aqui..."),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    // Posicionando o input na base da página
                                    padding: EdgeInsets.only(
                                      left: 16, 
                                      right: 16, 
                                      // Ajuste para o teclado
                                      bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                                      top: 16,
                                    ),
                                    // Mantendo o padrão do modal
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFD9D9D9), 
                                      border: Border(top: BorderSide(color: Color(0xFFA2A2A2), width: 1)),
                                    ),
                                    // Input
                                    child: Form(
                                      key: _modalFormKey,
                                      child: TextFormField(
                                        controller: _publicQuestionController,
                                        validator: (value) {
                                          if (value == null || value.isEmpty || value.toString().trim().isEmpty) {
                                            return 'Informe a mensagem';
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          hintText: "Faça sua pergunta...",
                                          // Configurando a cor de fundo
                                          filled: true,
                                          fillColor: Color(0xFFF4F4F4),
                                          border: OutlineInputBorder(
                                            // Deixando-o com as bordas arredondadas
                                            borderRadius: BorderRadius.all(Radius.circular(16)),
                                            // Removendo a borda padrão
                                            borderSide: BorderSide.none
                                          ),
                                          // Adicionando o ícone que funciona como botão de envio
                                          suffixIcon: IconButton(
                                            // Definindo a função acionada ao clicar no botão
                                            onPressed: _handlePublicQuestionSending,
                                            // Definindo o ícone
                                            icon: const Icon(Icons.send_rounded, color: Colors.black,)
                                          ),
                                        ),
                                        // Permitindo que o formulário seja acionado ao clicar "Enter"
                                        onFieldSubmitted: (_) => _handlePublicQuestionSending(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: Text(
                        "Ver tudo",
                        style: GoogleFonts.montserrat(
                          color: Color(0xFFDB0065),
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 12,),
                Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _publicQuestionController,
                    validator: (value) {
                      if (value == null || value.isEmpty || value.toString().trim().isEmpty) {
                        return 'Informe a mensagem';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: "Faça sua pergunta...",
                      // Configurando a cor de fundo
                      filled: true,
                      fillColor: Color(0xFFF4F4F4),
                      border: OutlineInputBorder(
                        // Deixando-o com as bordas arredondadas
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        // Removendo a borda padrão
                        borderSide: BorderSide.none
                      ),
                      // Adicionando o ícone que funciona como botão de envio
                      suffixIcon: IconButton(
                        // Definindo a função acionada ao clicar no botão
                        onPressed: _handlePublicQuestionSending,
                        // Definindo o ícone
                        icon: const Icon(Icons.send_rounded, color: Colors.black,)
                      ),
                    ),
                    // Permitindo que o formulário seja acionado ao clicar "Enter"
                    onFieldSubmitted: (_) => _handlePublicQuestionSending(),
                  ),
                ),
              ]
            )
          ],
        ),
      ),
    );
  }
}
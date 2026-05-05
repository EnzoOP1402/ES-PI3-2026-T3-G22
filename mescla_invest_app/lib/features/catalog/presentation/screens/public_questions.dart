import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mescla_invest_app/core/utils/snackbar_utils.dart';
import 'package:mescla_invest_app/features/auth/data/repositories/auth_repository.dart';
import 'package:mescla_invest_app/features/catalog/data/models/question_model.dart';
import 'package:mescla_invest_app/features/catalog/presentation/widgets/detailed_catalog_card_section.dart';
import 'package:cloud_functions/cloud_functions.dart';


class PublicQuestions extends StatefulWidget {
  // Variáveis que o widget precisa receber para funcionar
  final String startupId;
  final String startupName;

  const PublicQuestions({
    super.key, 
    required this.startupId, 
    required this.startupName,
  });

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

  // Definindo o controlador do input principal de pergunta pública
  final _publicQuestionController = TextEditingController();
  // Definindo o controlador do input do modal de pergunta pública
  final _modalPublicQuestionController = TextEditingController();

  // Definindo a variável que exibe a quantidade de perguntas públicas
  final int _publicQuestionsAmount = 0;

  // Método usado para eliminar variáveis, objetos, etc da árvore de elementos para liberar memória.
  // Ele é chamado quando o widget é removido da Widget tree, por exemplo, quando saímos dessa página
  @override
  void dispose() {
    // Elimina os controladores
    _publicQuestionController.dispose();
    // Elimina todas as variáveis usadas na página
    super.dispose();
  }

  // Função responsável por acionar a Firebase Function de postagem da pergunta
  Future<void> _handleCorePublicQuestionSending(String message) async {
    try {
      setState(() => _isLoading = true);
      
      // 1. Criamos uma instância temporária do modelo
      // O authorId e authorEmail serão preenchidos pelo Firebase no backend (onCall),
      // mas precisamos deles para instanciar a classe no Flutter.
      final novaPergunta = QuestionModel(
        authorId: AuthRepository.instance.currentUser?.uid ?? '', 
        text: message,
        visibility: QuestionVisibility.publica,
        createdAt: Timestamp.now(), // Timestamp local apenas para o objeto
      );

      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('createStartupQuestion');

      // 2. Usamos o toMap() para garantir a estrutura correta!
      // Adicionamos o startupId manualmente pois ele não faz parte do documento da pergunta,
      // mas sim do caminho/parâmetro que a função espera.
      final payload = novaPergunta.toCallableMap();
      payload['startupId'] = widget.startupId; 

      await callable.call(payload);

      // 3. Opcional: Você pode acessar os dados retornados pela função, se precisar
      // final data = response.data;
      // print("Pergunta criada com ID: ${data['id']}");

      // Exibe uma mensagem de sucesso
      if (mounted) {
        showSuccessSnackBar(context, "Pergunta enviada com sucesso!");
      }
    } on FirebaseFunctionsException catch (e) {
      // O backend lança HttpsError específicos (ex: 'invalid-argument', 'not-found')
      // O FirebaseFunctionsException captura esses erros do onCall para podermos tratá-los no app
      if (!mounted) return;
      showErrorSnackBar(context, e.message ?? "Erro ao comunicar com o servidor.");
    } catch (e) {
      // Captura erros genéricos (ex: falta de internet)
      if (!mounted) return;
      showErrorSnackBar(context, "Erro inesperado: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isLoading = false);
      _publicQuestionController.clear();
      _modalPublicQuestionController.clear();
    }
  }

  // Função que lida com o envio da pergunta na página principal
  void _onMainPublicQuestionSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      _handleCorePublicQuestionSending(_publicQuestionController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    Expanded(
                      child: Text(
                        "$_publicQuestionsAmount pergunta(s)",
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        showModalBottomSheet<void>(
                          isScrollControlled: true,
                          context: context,
                          builder: (BuildContext context) {
                            return StatefulBuilder(
                              builder: (BuildContext context, StateSetter setModalState) {
                                // Função o envio da pergunta através do modal
                                Future<void> onModalPublicQuestionSubmit(StateSetter setModalState) async {
                                  if (_modalFormKey.currentState?.validate() ?? false) {
                                    // Sincroniza o loading no modal e na tela de fundo
                                    setModalState(() => _isLoading = true);
                                    
                                    // Chama o envio passando o texto do controlador do MODAL
                                    await _handleCorePublicQuestionSending(_modalPublicQuestionController.text.trim());
                                    
                                    if (mounted) {
                                      setModalState(() => _isLoading = false);
                                    }
                                  }
                                }

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
                                                  widget.startupName,
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
                                        child: _isLoading ?
                                        const Center(child: CircularProgressIndicator(),)
                                        : Column(
                                          children: [
                                            Expanded(
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
                                                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
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
                                                  controller: _modalPublicQuestionController,
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
                                                      onPressed: () => onModalPublicQuestionSubmit(setModalState),
                                                      // Definindo o ícone
                                                      icon: const Icon(Icons.send_rounded, color: Colors.black,)
                                                    ),
                                                  ),
                                                  // Permitindo que o formulário seja acionado ao clicar "Enter"
                                                  onFieldSubmitted: (_) => onModalPublicQuestionSubmit(setModalState),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      ),
                                    ],
                                  ),
                                );
                              },
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
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else 
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
                          onPressed: _onMainPublicQuestionSubmit,
                          // Definindo o ícone
                          icon: const Icon(Icons.send_rounded, color: Colors.black,)
                        ),
                      ),
                      // Permitindo que o formulário seja acionado ao clicar "Enter"
                      onFieldSubmitted: (_) => _onMainPublicQuestionSubmit(),
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
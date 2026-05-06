/* Autor: Enzo Olivato Pazian */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mescla_invest_app/core/utils/snackbar_utils.dart';
import 'package:mescla_invest_app/features/auth/data/repositories/auth_repository.dart';
import 'package:mescla_invest_app/features/catalog/data/models/question_model.dart';
import 'package:mescla_invest_app/features/catalog/presentation/widgets/detailed_catalog_card_section.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:mescla_invest_app/features/catalog/presentation/widgets/detailed_catalog_modal_layout.dart';
import 'package:mescla_invest_app/features/catalog/presentation/widgets/question_item_tile.dart';


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
  
  // Variável controladora do carregamento dos dados da página
  // Quando a página é acessada, el muda de valor e aciona a tela de carregamento,
  // fazendo com que a tela com as informações só seja visível após todas estarem posicionadas
  bool _isLoading = false;
  // Variável controladora do carregamento de perguntas
  // Quando uma pergunta é enviada, ela muda de valor e aciona a tela de carregamento,
  // fazendo com que o usuário não consiga apertar múltiplas vezes o mesmo botão e enviar
  // várias requisições ao Firebase
  bool _isQuestionLoading = false;

  // Definindo o controlador do input principal de pergunta pública
  final _publicQuestionController = TextEditingController();
  // Definindo o controlador do input do modal de pergunta pública
  final _modalPublicQuestionController = TextEditingController();

  // Definindo a lista que recebe as perguntas públicas obtidas
  List<dynamic> _publicQuestionsList = []; // Lista bruta vinda do backend

  // Variável para armazenar os dados do usuário ao enviar mensagens
  Map<String, dynamic>? _currentUserProfile;

  // Função para obter dados do usuário necessários para a exibição de uma
  // mensagem recém enviada
  Future<void> _loadCurrentUserProfile() async {
    final uid = AuthRepository.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists && mounted) {
        setState(() => _currentUserProfile = doc.data());
      }
    }
  }

  // Função para obter os dados da página detalhada
  Future<void> _fetchStartupDetails() async {
    try {
      setState(() => _isLoading = true);

      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('getStartupDetails');

      // Chamada passando o ID que o widget recebeu no construtor
      final response = await callable.call(<String, dynamic>{
        'id': widget.startupId,
      });

      // Os dados chegam dentro de response.data['data'] conforme definido no backend
      final Map<String, dynamic> startupData = Map<String, dynamic>.from(response.data['data']);

      if (mounted) {
        setState(() {
          // Mapeamos a lista de perguntas retornada pela listPublicQuestions (backend)
          _publicQuestionsList = startupData['publicQuestions'] ?? [];
          _isLoading = false;
        });
      }
    } on FirebaseFunctionsException catch (e) {
      if (mounted) showErrorSnackBar(context, e.message ?? "Erro ao carregar dados.");
    } catch (e) {
      if (mounted) showErrorSnackBar(context, "Erro: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    // Chamamos as funções assim que o widget é carregado
    // O Flutter iniciará o carregamento dos dados imediatamente

    // Função de obtenção dos dados da startup
    _fetchStartupDetails();
    // Função de obtenção dos dados do usuário para o envio de mensagens
    _loadCurrentUserProfile();
  }

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
      setState(() => _isQuestionLoading = true);
      
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

      // Exibe uma mensagem de sucesso
      if (mounted) {
        // 3. Inserindo a pergunta recém criada na lista de perguntas sem precisar chamar a Function
        final novaPerguntaLocal = {
          'id': 'temp_${DateTime.now().millisecondsSinceEpoch}', // ID temporário
          'authorName': _currentUserProfile?['fullName'] ?? 'Eu', // Busca o fullName do Firestore
          'authorPhotoUrl': _currentUserProfile?['profilePicture'], // Busca a foto do Firestore
          'text': message,
          'createdAt': DateTime.now().toIso8601String(), // Data local para exibição imediata
          'answer': null,
          'answeredAt': null,
        };

        setState(() {
          // Insere no início da lista (index 0) para aparecer no topo, 
          // respeitando a ordenação por data do protótipo
          _publicQuestionsList.insert(0, novaPerguntaLocal);
        });

        // Emite uma mensagem de sucesso
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
      if (mounted) setState(() => _isQuestionLoading = false);
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
        title: Text(widget.startupName),
        foregroundColor: const Color(0xFF353988),
        actions: [
          TextButton.icon(
            onPressed: AuthRepository.instance.logout,
            label: Icon(Icons.logout)
          )
        ],
      ),
      body: _isLoading ?
        Center(child: CircularProgressIndicator(),) :
        Center(
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
                          "${_publicQuestionsList.length.toString()} pergunta(s)",
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
                                      setModalState(() => _isQuestionLoading = true);
                                      
                                      // Chama o envio passando o texto do controlador do MODAL
                                      await _handleCorePublicQuestionSending(_modalPublicQuestionController.text.trim());
                                      
                                      if (mounted) {
                                        setModalState(() => _isQuestionLoading = false);
                                      }
                                    }
                                  }

                                  return DetailedCatalogModalLayout(
                                    title: "Perguntas Públicas",
                                    subtitle: widget.startupName,
                                    // Conteúdo do modal
                                    children: [
                                      Expanded(
                                        // Perguntas
                                        child: _isQuestionLoading ?
                                        const Center(child: CircularProgressIndicator(),)
                                        : Column(
                                          children: [
                                            Expanded(
                                              child: SingleChildScrollView(
                                                child: Padding(
                                                  padding: EdgeInsets.all(16),
                                                  child: Column(
                                                    children: [
                                                      // RENDERIZANDO AS PERGUNTAS PÚBLICAS
                                                      _isLoading 
                                                        ? const Center(child: CircularProgressIndicator())
                                                        : _publicQuestionsList.isEmpty
                                                          ? Center(
                                                            child: Padding(
                                                              padding: const EdgeInsets.symmetric(vertical: 40.0),
                                                              child: Text(
                                                                "Essa startup ainda não possui nenhuma pergunta.",
                                                                textAlign: TextAlign.center,
                                                                style: GoogleFonts.montserrat(
                                                                  fontSize: 14,
                                                                  color: Colors.grey[700],
                                                                  fontStyle: FontStyle.italic,
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                          : ListView.builder(
                                                              shrinkWrap: true,
                                                              physics: const NeverScrollableScrollPhysics(),
                                                              itemCount: _publicQuestionsList.length,
                                                              itemBuilder: (context, index) {
                                                                // Cada item da lista é um Map contendo: 
                                                                // authorName, authorPhotoUrl, text, answer, etc.
                                                                return QuestionItemTile(
                                                                  questionData: Map<String, dynamic>.from(_publicQuestionsList[index]),
                                                                );
                                                              },
                                                            ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            // Rodapé do modal
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
                                                  // Configurações para o comportamento de textarea
                                                  minLines: 1,      // Começa com uma linha
                                                  maxLines: 5,      // Cresce até 5 linhas e depois habilita scroll interno
                                                  keyboardType: TextInputType.multiline, // Permite o botão 'Enter' para pular linha
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
                                    ]
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
                  if (_isQuestionLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else 
                    Form(
                      key: _formKey,
                      child: TextFormField(
                        // Configurações para o comportamento de textarea
                        minLines: 1,      // Começa com uma linha
                        maxLines: 5,      // Cresce até 5 linhas e depois habilita scroll interno
                        keyboardType: TextInputType.multiline, // Permite o botão 'Enter' para pular linha
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
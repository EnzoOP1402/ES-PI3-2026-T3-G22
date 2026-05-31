/* Autor: Enzo Olivato Pazian - 25001654 */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:mescla_invest_app/core/utils/snackbar_utils.dart';
import 'package:mescla_invest_app/features/auth/data/repositories/auth_repository.dart';
import 'package:mescla_invest_app/features/catalog/data/models/question_model.dart';
import 'package:mescla_invest_app/features/catalog/presentation/widgets/startup_detail/detailed_catalog_card_section.dart';
import 'package:mescla_invest_app/features/catalog/presentation/widgets/startup_detail/detailed_catalog_modal_layout.dart';
import 'package:mescla_invest_app/features/catalog/presentation/widgets/startup_detail/question_item_tile.dart';

class PrivateQuestionsCard extends StatefulWidget {
   // Parâmetro para a chamada da Firebase Function
  final String startupId;
  // Lista de perguntas trazida da página principal
  final List<dynamic> perguntasPrivadas;

  // Construtor do Widget
  const PrivateQuestionsCard({
    super.key,
    required this.startupId,
    required this.perguntasPrivadas,
  });

  @override
  State<PrivateQuestionsCard> createState() => _PrivateQuestionsCardState();
}

class _PrivateQuestionsCardState extends State<PrivateQuestionsCard> {
  // Definindo a lista que recebe as perguntas privadas obtidas
  late List<dynamic> _localQuestions;
  final _modalPrivateQuestionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  // Variáveis controladoras de carregamento
  bool _isLoading = false;
  bool _isQuestionLoading = false;
  
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

  @override
  void initState() {
    super.initState();
    // Inicializando a lista local com a lista trazida do banco
    _localQuestions = List.from(widget.perguntasPrivadas);
    // Obtendo os dados do usuário para a realização das postagens
    _loadCurrentUserProfile();
  }

  @override
  void dispose() {
    // Elimina os controladores
    _modalPrivateQuestionController.dispose();
    // Função de obtenção dos dados do usuário para o envio de mensagens
    super.dispose();
  }

  // Função responsável por acionar a Firebase Function de postagem da pergunta privada
  Future<void> _handleCorePrivateQuestionSending(String message) async {
    try {
      // Muda o e
      setState(() => _isQuestionLoading = true);
      
      // Criamos a instância temporária mudando para a pergunta privada
      final novaPergunta = QuestionModel(
        authorId: AuthRepository.instance.currentUser?.uid ?? '', 
        text: message,
        visibility: QuestionVisibility.privada, // Definido como privada
        createdAt: Timestamp.now(), // Timestamp local apenas para o objeto
      );

      // Armazenando o acesso à Function de criação de perguntas
      final HttpsCallable callable = FirebaseFunctions.instanceFor(region: 'southamerica-east1')
          .httpsCallable('createStartupQuestion');

      // Adicionando o id da startup ao objeto que será passado como
      // parâmetro pela função
      final payload = novaPergunta.toCallableMap();
      payload['startupId'] = widget.startupId; 

      // Chamando a Function
      await callable.call(payload);

      if (mounted) {
        // Inserindo a pergunta recém criada na lista de perguntas sem precisar chamar a Function para recarregar a lista
        final novaPerguntaLocal = {
          // ID temporário
          'id': 'temp_${DateTime.now().millisecondsSinceEpoch}',
          // Obtém o fullName do Firestore
          'authorName': _currentUserProfile?['fullName'] ?? 'Eu',
          // Obtém a foto do Firestore
          'authorPhotoUrl': _currentUserProfile?['profilePicture'],
          // A mensagem em si
          'text': message,
          // Data local para exibição imediata
          'createdAt': DateTime.now().toIso8601String(), 
          'answer': null,
          'answeredAt': null,
        };

        setState(() {
          // Insere no início da lista (index 0) para aparecer no topo, 
          // respeitando a ordenação por data
          _localQuestions.insert(0, novaPerguntaLocal);
        });

        // Emite uma mensagem de sucesso
        showSuccessSnackBar(context, "Pergunta privada enviada com sucesso!");
      }
    } on FirebaseFunctionsException catch (e) {
      // Tratando erros do Firebase
      if (!mounted) return;
      showErrorSnackBar(context, e.message ?? "Erro ao comunicar com o servidor.");
    } catch (e) {
      // Capturando erros genéricos
      if (!mounted) return;
      showErrorSnackBar(context, "Erro inesperado: ${e.toString()}");
    } finally {
      // Mudando o valor da variável de controle do carregamento e
      // limpando o valor do input de perguntas
      if (mounted) setState(() => _isQuestionLoading = false);
      _modalPrivateQuestionController.clear();
    }
  }

  // Função responsável pela abertura do modal que carrega a lista de
  // perguntas privadas
  void _abrirModalPergunta() {
    showModalBottomSheet(
      context: context,
      // Definindo scroll
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          
          // Função de envio da pergunta através do modal
          Future<void> onModalPrivateQuestionSubmit(StateSetter setModalState) async {
            // Se o input tiver sido validado, muda o valor da variável
            // de controle do carregamento, chama a função de publicação
            // da pergunta e volta o estado ao original
            if (_formKey.currentState?.validate() ?? false) {
              // Sincroniza o loading no modal e na tela de fundo
              setModalState(() => _isQuestionLoading = true);
              
              // Chama o envio passando o texto do controlador do MODAL
              await _handleCorePrivateQuestionSending(_modalPrivateQuestionController.text.trim());
              
              if (mounted) {
                setModalState(() => _isQuestionLoading = false);
              }
            }
          }
          
          // Definindo a interface
          return DetailedCatalogModalLayout(
            // Informações do cabeçalho do modal padrão
            title: "Perguntas Privadas",
            subtitle: "Quantidade de perguntas: ${_localQuestions.length.toString()}",
            children: [
              // Renderizando a lista em um Expanded para ocupar todo o
              // espaço disponível
              Expanded(
                child: _isQuestionLoading 
                // Exibe o indicativo de carregamento quando
                // uma pergunta estiver sendo enviada ou a lista
                // estiver sendo carregada
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  children: [
                    Expanded(
                      // Habilitando a rolagem da lista
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              // Renderizando as perguntas públicas
                              _isLoading 
                                ? const Center(child: CircularProgressIndicator())
                                : _localQuestions.isEmpty
                                // Se a lista estiver vazia, exibe uma
                                // mensagem amigável
                                  ? Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 40.0),
                                      child: Text(
                                        "Você ainda não realizou nenhuma pergunta privada.",
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  )
                                  // Renderizando a lista
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: _localQuestions.length,
                                      itemBuilder: (context, index) {
                                        // Cada item da lista é um Map contendo: 
                                        // authorName, authorPhotoUrl, text, answer, etc.
                                        return QuestionItemTile(
                                          questionData: Map<String, dynamic>.from(_localQuestions[index]),
                                        );
                                      },
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Rodapé do modal contendo o input privado
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
                        key: _formKey,
                        child: TextFormField(
                          // Configurações para o comportamento de textarea
                          minLines: 1,      // Começa com uma linha
                          maxLines: 5,      // Cresce até 5 linhas e depois habilita scroll interno
                          keyboardType: TextInputType.multiline, // Permite o botão 'Enter' para pular linha
                          controller: _modalPrivateQuestionController,
                          validator: (value) {
                            if (value == null || value.isEmpty || value.toString().trim().isEmpty) {
                              return 'Informe a mensagem';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: "Faça sua pergunta privada...",
                            filled: true,
                            // Configurando a cor de fundo
                            fillColor: const Color(0xFFF4F4F4),
                            border: const OutlineInputBorder(
                              // Deixando-o com as bordas arredondadas
                              borderRadius: BorderRadius.all(Radius.circular(16)),
                              // Removendo a borda padrão
                              borderSide: BorderSide.none
                            ),
                            // Adicionando o ícone que funciona como botão de envio
                            suffixIcon: IconButton(
                              // Definindo a função acionada ao clicar no botão
                              onPressed: () => onModalPrivateQuestionSubmit(setModalState),
                              // Definindo o ícone
                              icon: const Icon(Icons.send_rounded, color: Colors.black)
                            ),
                          ),
                          // Permitindo que o formulário seja acionado ao clicar "Enter"
                          onFieldSubmitted: (_) => onModalPrivateQuestionSubmit(setModalState),
                        ),
                      ),
                    ),
                  ],
                )
              ),
            ],
          );
        },
      ),
    );
  }

  // Definindo a interface do Widget
  @override
  Widget build(BuildContext context) {
    // Usando o card padrão do catálogo para envolver o conteúdo
    return DetailedCatalogCardSection(
      // Título e descrição do card
      title: 'Perguntas privadas',
      children: [
        Text(
          'Canal exclusivo para investidores que possuem tokens desta startup.',
          style: GoogleFonts.montserrat(
            fontSize: 14, 
            color: Colors.black,
            height: 1.4,
          ),
        ),

        // Espaçamento
        const SizedBox(height: 12),

        // Seção que recebe o botão principal
        SizedBox(
          width: double.infinity,
          height: 40,
          // Definido o botão
          child: FilledButton.icon(
            // Definindo a ação do botão (abrir o modal)
            onPressed: _abrirModalPergunta,
            // Definindo o ícone do botão
            icon: const Icon(Icons.lock_outline),
            // Definindo o texto do botão
            label: Text(
              'Abrir chat privado',
              style: GoogleFonts.montserrat(
                color: const Color(0xFFF4F4F4),
              )
            ),
            // Estilizando o botão
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF353988),
              foregroundColor: const Color(0xFFF4F4F4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
                fontSize: 16
              ),
            ),
          ),
        ),
      ],
    );
  }
}
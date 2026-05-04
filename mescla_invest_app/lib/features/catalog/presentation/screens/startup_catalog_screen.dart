/* Autor: Bernardo Castro Brandão de Oliveira */

import 'package:flutter/material.dart'; //Importa o framework principal do Flutter (widgets, UI, Scaffold, etc) 
import 'package:cloud_firestore/cloud_firestore.dart'; //Importa o Firebase Firestore (banco de dados).
import 'package:mescla_invest_app/features/frame_cards/data_cards.dart'; //(importa o arquivo que tem a classe com as informações de cada card)
import 'package:mescla_invest_app/features/catalog/presentation/theme/background_app.dart';
import '../widgets/nav_menu.dart';
import '../widgets/pesquisar_menu.dart';
import '../widgets/botao_ir_para.dart';

class Catalogo extends StatefulWidget {
  //Tela que muda dinamicamente
  const Catalogo({super.key}); //Construtor da classe

  @override
  State<Catalogo> createState() => _CatalogoState(); //Cria o estado da tela.
}

class _CatalogoState extends State<Catalogo> {
  final TextEditingController buscaController = TextEditingController();
  // Variáveis de controle para menu e busca
  int paginaAtual = 1;
  String textoBusca = '';

  //Classe que controla comportamento da tela.
  final List<CardCatalogo> startups = []; //Lista de startups carregadas.
  final ScrollController controller =
      ScrollController(); //Controla a rolagem da lista.

  List<CardCatalogo> get startupsFiltradas {
    //Retorna a lista de startups filtrada pelo texto de busca.
    if (textoBusca.trim().isEmpty) return startups; //Se a busca está vazia, retorna tudo.

    final busca = textoBusca.toLowerCase(); //Transforma a busca em minúscula para comparação.
    return startups.where((s) {
      //Filtra a lista de startups
      final nome = s.nome_startup.toLowerCase();
      final descricao = s.mini_descricao.toLowerCase();

      return nome.contains(busca) || descricao.contains(busca); //Retorna true se o nome ou descrição contiverem o texto de busca.
    }).toList();
  }

  QueryDocumentSnapshot? lastDoc; //Guarda o último documento (para paginação).
  bool carregando = false; //Indica se está carregando dados.
  bool acabou = false; //Indica se não há mais dados.

  @override
  void initState() {
    //Executa quando a tela inicia.
    super.initState(); //Inicializa corretamente a classe pai.
    carregarMais(); //Carrega os primeiros dados

    controller.addListener(() {
      //Escuta a rolagem
      if (controller.position.pixels >=
              controller.position.maxScrollExtent - 200 &&
          !carregando &&
          !acabou) {
        //verifica se chegou no fim da lista

        carregarMais(); //Carrega mais dados, se não estiver carregando e ainda tem dados
      }
    });
  }

  Future<void> carregarMais() async {
    if (carregando || acabou) return; // Proteção extra

    setState(() => carregando = true);

    try {
      Query query = FirebaseFirestore.instance.collection('startups').limit(20);

      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc!);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        // ATUALIZA O ÚLTIMO DOCUMENTO PARA A PRÓXIMA PÁGINA
        lastDoc = snapshot.docs.last;
        final novos = snapshot.docs.map((doc) {
          return CardCatalogo.fromFirestore(doc.data() as Map<String, dynamic>);
        }).toList();

        setState(() {
          startups.addAll(novos);
        });
        print("DOCS: ${snapshot.docs.length}");

        // Aqui deve vir a lógica de adicionar os itens na sua lista (ex: lista.addAll)
      } else {
        acabou = true; // Não há mais dados no banco
      }
    } catch (e) {
      print("Erro ao carregar: $e");
      
    } finally {
      // SEMPRE volta para false, mesmo se der erro, para não travar o app
      setState(() => carregando = false);
    }
    
  }

  @override
  Widget build(BuildContext context) {
    final lista = startupsFiltradas;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo'),
      ),
      bottomNavigationBar: MenuInferior(
        PaginaAtual: paginaAtual,
        onItemSelected: (index) {
          setState(() => paginaAtual = index);
        },
      ),
      body: BackgroundContainer(
        child: Column(
          children: [
            BuscaStartup(
              controller: buscaController,
              onChanged: (valor) {
                setState(() {
                  textoBusca = valor;
                });
              },
            ),
            Expanded(
              child: startups.isEmpty && carregando
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : lista.isEmpty
                      ? const Center(
                          child: Text("Nenhuma startup encontrada"),
                        )
                      : ListView.builder(
                          controller: controller,
                          itemCount: lista.length + (carregando ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index < lista.length) {
                              final s = lista[index];

                              return Card(
                                color: const Color(0xFFE8E9EB),
                                elevation: 2,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 22,
                                        backgroundColor: Colors.white,
                                        child: const Icon(
                                          Icons.business,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    s.nome_startup,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'R\$ ${s.valorFixo_token}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                    color: Color.fromARGB(255, 47, 40, 148),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              s.mini_descricao,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFDADADA),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: const Text(
                                                'Startup',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: BotaoIrPara(
                                                pagina: const Placeholder(),
                                                texto: "Ver mais",
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

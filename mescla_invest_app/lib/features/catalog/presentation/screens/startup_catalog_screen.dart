/* Autor: Rafael Henrique dos Santos Inácio (responsável pela função de filtro de Startups) */

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mescla_invest_app/features/frame_cards/data_cards.dart';
import 'package:mescla_invest_app/features/catalog/presentation/theme/background_app.dart';
import '../widgets/nav_menu.dart';
import '../widgets/pesquisar_menu.dart';
import '../widgets/botao_ir_para.dart';

class Catalogo extends StatefulWidget {
  const Catalogo({super.key});

  @override
  State<Catalogo> createState() => _CatalogoState();
}

class _CatalogoState extends State<Catalogo> {
  final TextEditingController buscaController = TextEditingController();

  // Variáveis de controle de estado
  int paginaAtual = 1;
  String textoBusca = '';
  String filtroSelecionado = 'Todas';
  final List<String> categorias = [
    'Todas',
    'Em operação',
    'Em expansão',
    'Nova',
  ];

  final List<CardCatalogo> startups = [];
  final ScrollController controller = ScrollController();

  // Lógica de filtragem combinada (Filtro + Busca)
  List<CardCatalogo> get startupsFiltradas {
    List<CardCatalogo> resultado = startups;

    // 1. Aplicar filtro de categoria (estágio)
    if (filtroSelecionado != 'Todas') {
      // Mapeia o texto do botão para o padrão do seu Firestore (ex: em_operacao)
      String valorBanco = filtroSelecionado.toLowerCase().replaceAll(' ', '_');
      if (valorBanco == "em_operação") valorBanco = "em_operacao";
      if (valorBanco == "em_expansão") valorBanco = "em_expansao";

      resultado = resultado.where((s) => s.estagio_stp == valorBanco).toList();
    }

    // 2. Aplicar filtro de busca por texto
    if (textoBusca.trim().isEmpty) return resultado;

    final busca = textoBusca.toLowerCase();
    return resultado.where((s) {
      final nome = s.nome_startup.toLowerCase();
      final descricao = s.mini_descricao.toLowerCase();
      return nome.contains(busca) || descricao.contains(busca);
    }).toList();
  }

  QueryDocumentSnapshot? lastDoc;
  bool carregando = false;
  bool acabou = false;

  @override
  void initState() {
    super.initState();
    carregarMais();

    controller.addListener(() {
      if (controller.position.pixels >=
              controller.position.maxScrollExtent - 200 &&
          !carregando &&
          !acabou) {
        carregarMais();
      }
    });
  }

  Future<void> carregarMais() async {
    if (carregando || acabou) return;

    setState(() => carregando = true);

    try {
      // Busca na coleção 'Startups' com S maiúsculo conforme seu banco
      Query query = FirebaseFirestore.instance.collection('Startups').limit(20);

      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc!);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        lastDoc = snapshot.docs.last;
        final novos = snapshot.docs.map((doc) {
          return CardCatalogo.fromFirestore(doc.data() as Map<String, dynamic>);
        }).toList();

        setState(() {
          startups.addAll(novos);
        });
      } else {
        setState(() => acabou = true);
      }
    } catch (e) {
      print("Erro ao carregar no Firestore: $e");
    } finally {
      setState(() => carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lista = startupsFiltradas;

    return Scaffold(
      appBar: AppBar(title: const Text('Catálogo')),
      bottomNavigationBar: MenuInferior(
        PaginaAtual: paginaAtual,
        onItemSelected: (index) {
          setState(() => paginaAtual = index);
        },
      ),
      body: BackgroundContainer(
        child: Column(
          children: [
            // Barra de busca
            BuscaStartup(
              controller: buscaController,
              onChanged: (valor) {
                setState(() => textoBusca = valor);
              },
            ),

            // Linha de Filtros (Chips)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: categorias.map((cat) {
                  final selecionado = filtroSelecionado == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: selecionado,
                      onSelected: (bool selected) {
                        setState(() => filtroSelecionado = cat);
                      },
                      selectedColor: const Color(
                        0xFFE91E63,
                      ), // Cor rosa da imagem
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: selecionado ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Lista de Startups
            Expanded(
              child: startups.isEmpty && carregando
                  ? const Center(child: CircularProgressIndicator())
                  : lista.isEmpty
                  ? const Center(child: Text("Nenhuma startup encontrada"))
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
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const CircleAvatar(
                                    radius: 22,
                                    backgroundColor: Colors.white,
                                    child: Icon(
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                s.nome_startup,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              'R\$ ${s.valorFixo_token.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF2F2894),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          s.mini_descricao,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        const SizedBox(height: 8),
                                        // Badge de estágio
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFDADADA),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            s.estagio_stp
                                                .replaceAll('_', ' ')
                                                .toUpperCase(),
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
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
                          child: Center(child: CircularProgressIndicator()),
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

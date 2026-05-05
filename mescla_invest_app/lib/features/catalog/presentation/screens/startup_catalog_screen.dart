/* Autor: Bernardo Castro Brandão de Oliveira */

import 'package:flutter/material.dart'; //Importa o framework principal do Flutter (widgets, UI, Scaffold, etc)
import 'package:cloud_firestore/cloud_firestore.dart'; //Importa o Firebase Firestore (banco de dados).
import 'package:mescla_invest_app/features/frame_cards/data_cards.dart'; //(importa o arquivo que tem a classe com as informações de cada card)
import 'package:mescla_invest_app/features/catalog/presentation/theme/background_app.dart';

class Catalogo extends StatefulWidget {
  const Catalogo({super.key});

  @override
  State<Catalogo> createState() => _CatalogoState();
}

class _CatalogoState extends State<Catalogo> {
  final List<CardCatalogo> startups = [];
  final ScrollController controller = ScrollController();

  QueryDocumentSnapshot? lastDoc;
  bool carregando = false;
  bool acabou = false;

  int? expandedIndex;

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

  Future<void> recarregarTudo() async {
    setState(() {
      startups.clear();
      lastDoc = null;
      acabou = false;
    });

    await carregarMais();
  }

  Future<void> carregarMais() async {
    if (carregando || acabou) return;

    setState(() => carregando = true);

    try {
      Query query = FirebaseFirestore.instance.collection('startups').limit(20);

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
        acabou = true;
      }
    } catch (e) {
      print("Erro: $e");
    } finally {
      setState(() => carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDEDEDE),

      appBar: AppBar(
        title: const Text(
          "Catálogo",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF353988),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        elevation: 0,
      ),

      body: Column(
        children: [
          /// 🔍 PESQUISA
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Pesquisar Startup",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          /// 🏷️ FILTROS
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                filtroChip("Todas", true),
                filtroChip("Em operação", false),
                filtroChip("Em expansão", false),
                filtroChip("Nova", false),
              ],
            ),
          ),

          const SizedBox(height: 10),

          /// 📜 LISTA
          Expanded(
            child: ListView.builder(
              controller: controller,
              itemCount: startups.length + 1,
              itemBuilder: (context, index) {
                if (index < startups.length) {
                  final s = startups[index];
                  final isExpanded = expandedIndex == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        expandedIndex = isExpanded ? null : index;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      padding: const EdgeInsets.all(16),

                      /// 🎨 CARD IGUAL AO DESIGN
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// 🔝 TOPO
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  s.nome_startup,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Icon(
                                isExpanded
                                    ? Icons.close_fullscreen
                                    : Icons.open_in_full,
                                size: 18,
                                color: Colors.black45,
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          /// 📝 DESCRIÇÃO
                          Text(
                            s.mini_descricao,
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 13,
                            ),
                          ),

                          const SizedBox(height: 10),

                          /// 🏷️ TAG (cor correta)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFC3C0FF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              s.estagio_stp,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                              ),
                            ),
                          ),

                          /// 🔽 EXPANSÃO
                          if (isExpanded) ...[
                            const SizedBox(height: 12),
                            const Divider(),

                            Text("Setor: ${s.setor_stp}"),
                            Text("Status: ${s.status_stp}"),

                            const SizedBox(height: 10),

                            const Text(
                              "Participação:",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            ...s.part_societaria.map((p) => Text(p)),

                            const SizedBox(height: 10),

                            const Text(
                              "Membros:",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            ...s.socios_stp.map((m) => Text(m)),
                          ],

                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              /// 🔢 TOKENS (lado esquerdo)
                              Text(
                                "${s.tokens_emitidos} tokens",
                                style: const TextStyle(color: Colors.black),
                              ),

                              /// 🔘 BOTÃO (cor correta)
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF353988),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  onPressed: () {},
                                  child: const Text(
                                    "Ver mais",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return carregando
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : const SizedBox();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

Widget filtroChip(String label, bool selecionado) {
  return Container(
    margin: const EdgeInsets.only(right: 8),
    child: ChoiceChip(
      label: Text(label),
      selected: selecionado,
      onSelected: (_) {
        // depois você implementa filtro real
      },
      selectedColor: const Color(0xFFDB0065),
      checkmarkColor: Colors.white,

      labelStyle: TextStyle(color: selecionado ? Colors.white : Colors.black),
      backgroundColor: Colors.white,
    ),
  );
}

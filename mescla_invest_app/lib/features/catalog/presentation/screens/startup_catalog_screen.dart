/* Autor: Bernardo Castro Brandão de Oliveira */

import 'package:flutter/material.dart'; //Importa o framework principal do Flutter (widgets, UI, Scaffold, etc) 
import 'package:cloud_firestore/cloud_firestore.dart'; //Importa o Firebase Firestore (banco de dados).
import 'package:mescla_invest_app/features/frame_cards/data_cards.dart'; //(importa o arquivo que tem a classe com as informações de cada card)
import 'package:mescla_invest_app/features/catalog/presentation/theme/background_app.dart';


class Catalogo extends StatefulWidget {
  //Tela que muda dinamicamente
  const Catalogo({super.key}); //Construtor da classe

  @override
  State<Catalogo> createState() => _CatalogoState(); //Cria o estado da tela.
}

class _CatalogoState extends State<Catalogo> {
  //Classe que controla comportamento da tela.
  final List<CardCatalogo> startups = []; //Lista de startups carregadas.
  final ScrollController controller =
      ScrollController(); //Controla a rolagem da lista.

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
    //Constrói o design
    return Scaffold(
      //Estrutura base da tela
      appBar: AppBar(title: const Text('Catálogo')), //Barra superior com título
      body: BackgroundContainer(
        //Fundo personalizado
        child: ListView.builder(
          //Lista dinâmica
          controller: controller, //Liga a rolagem ao controller
          itemCount: startups.length + 1, //+1 para mostrar loading no final.
          itemBuilder: (context, index) {
            //Função que cria cada item.
            if (index < startups.length) {
              final s = startups[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(s.nome_startup),
                  subtitle: Text(s.mini_descricao),
                  trailing: Text('R\$ ${s.valorFixo_token}'),
                ),
              ); //Se ainda for item normal mostra o card
            } else {
              return carregando //Caso contrário, se estiver carregando, mostra espaço com padding.
                  ? const Padding(
                      padding: EdgeInsets.all(16), //Espaçamento
                      child: Center(
                        child: CircularProgressIndicator(),
                      ), //Mostra o Girador de Carregamento
                    )
                  : const SizedBox(); //Se não estiver carregando, não mostra nada.
            }
          },
        ),
      ),
    );
  }
}

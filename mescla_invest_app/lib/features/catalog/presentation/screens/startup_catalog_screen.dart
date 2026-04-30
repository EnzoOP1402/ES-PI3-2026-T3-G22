/* Autor: Bernardo Castro Brandão de Oliveira */

import 'package:flutter/material.dart'; //Importa o framework principal do Flutter (widgets, UI, Scaffold, etc)
import 'package:google_fonts/google_fonts.dart'; //Permite usar fontes externas (como Montserrat) no app.
import 'package:mescla_invest_app/features/auth/data/repositories/auth_repository.dart'; //Importa um arquivo do seu projeto (provavelmente usado para login/logout)
import '../theme/background_app.dart'; //Importa um widget personalizado de fundo (BackgroundContainer).
import 'package:cloud_firestore/cloud_firestore.dart'; //Importa o Firebase Firestore (banco de dados).



class MesclaInvest extends StatelessWidget { //Define o app principal como imutável (Stateless).
  const MesclaInvest({super.key}); //Construtor da classe.

  @override //Indica que você está sobrescrevendo um método da classe pai.
  Widget build(BuildContext context) { //Método obrigatório que constrói a interface
    return MaterialApp( //Cria o app com Material Design
      debugShowCheckedModeBanner: false, //Remove o banner "DEBUG"
      home: Catalogo(), //Define a tela inicial como Catalogo
      theme: ThemeData( //Define o tema do app
        textTheme: GoogleFonts.montserratTextTheme(), //Aplica a fonte Montserrat globalmente
        
      ),
    );
  }
}


class Catalogo extends StatefulWidget { //Tela que muda dinamicamente
  const Catalogo({super.key}); //Construtor da classe

  @override
  State<Catalogo> createState() => _CatalogoState(); //Cria o estado da tela.
}

class _CatalogoState extends State<Catalogo> { //Classe que controla comportamento da tela.
  final List<CardCatalogo> startups = []; //Lista de startups carregadas.
  final ScrollController controller = ScrollController(); //Controla a rolagem da lista.

  QueryDocumentSnapshot? lastDoc; //Guarda o último documento (para paginação).
  bool carregando = false; //Indica se está carregando dados.
  bool acabou = false; //Indica se não há mais dados.

  @override
  void initState() { //Executa quando a tela inicia.
    super.initState();//Inicializa corretamente a classe pai.
    carregarMais(); //Carrega os primeiros dados

    controller.addListener(() { //Escuta a rolagem
      if (controller.position.pixels == 
          controller.position.maxScrollExtent && 
          !carregando &&
          !acabou) {  //verifica se chegou no fim da lista
        
        carregarMais(); //Carrega mais dados, se não estiver carregando e ainda tem dados
      }
    });
  }
Future<void> carregarMais() async { //Função assíncrona para mostrar o carregamento
    setState(() => carregando = true); //Atualiza a tela para mostrar que está carregando

    Query query = FirebaseFirestore.instance //Busca 20 documentos do Firebase.
        .collection('startups')
        .limit(20); //Coloca o limite de 20 aqui!

    if (lastDoc != null) { //Veriffica se já carregou antes
      query = query.startAfterDocument(lastDoc!);//Continua a partir do último documento
    }

    final snapshot = await query.get(); //Execulta a query (pega os dados do Firebase)

    if (snapshot.docs.isEmpty) { 
      acabou = true; //Se não vier nada, acaba a exibição
    } else { 
      final novos = snapshot.docs.map((doc) { //Caso contrário, Converte documentos em objetos
        return CardCatalogo.fromFirestore(
          doc.data() as Map<String, dynamic>,
        );
      }).toList(); //Transforma em lista

      startups.addAll(novos); //Adiciona novos itens à lista existente.
      lastDoc = snapshot.docs.last; //Atualiza o último documento
    }

    setState(() => carregando = false); //Remove loading
  }

  @override
  Widget build(BuildContext context) { //Constrói o design
    return Scaffold( //Estrutura base da tela
      appBar: AppBar(title: const Text('Catálogo')), //Barra superior com título
      body: BackgroundContainer( //Fundo personalizado
        child: ListView.builder( //Lista dinâmica
          controller: controller, //Liga a rolagem ao controller
          itemCount: startups.length + 1, //+1 para mostrar loading no final.
          itemBuilder: (context, index) { //Função que cria cada item.
            if (index < startups.length) {
              return CardStartup(s: startups[index]); //Se ainda for item normal mostra o card
            } else {
              return carregando //Caso contrário, se estiver carregando, mostra espaço com padding.
                  ? const Padding(
                      padding: EdgeInsets.all(16), //Espaçamento
                      child: Center(child: CircularProgressIndicator()), //Mostra o Girador de Carregamento
                    )
                  : const SizedBox(); //Se não estiver carregando, não mostra nada.
            }
          },
        ),

      ),
    );
  }
}

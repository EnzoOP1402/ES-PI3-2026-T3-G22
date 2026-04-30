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

  factory CardCatalogo.fromFirestore(Map<String, dynamic> data) { //Construtor especial que transforma dados do Firebase em objeto Dart.
  return CardCatalogo( //Cria um novo objeto
    nome_startup: data['nome_startup'] ?? '', //Se existir usa, senão usa string vazia
    data_criacao: data['data_criacao'] ?? '',
    mini_descricao: data['mini_descricao'] ?? '',
    estagio_stp: data['estagio_stp'] ?? '',
    status_stp: data['status_stp'] ?? '',
    tokens_disponiveis: data['tokens_disponiveis'] ?? 0,
    tokens_emitidos: data['tokens_emitidos'] ?? 0,
    valorFixo_token: (data['valorFixo_token'] ?? 0).toDouble(), //Garante que o valor seja double
    capital_aportado: (data['capital_aportado'] ?? 0).toDouble(),
    setor_stp: data['setor_stp'] ?? '',
    video_demoURL: data['video_demoURL'],
    socios_stp: List<String>.from(data['socios_stp'] ?? []), //Converte lista dinâmica em lista de String
    ment_conselho: List<String>.from(data['ment_conselho'] ?? []),
    ofetas_ativas: List<int>.from(data['ofetas_ativas'] ?? []),
    part_societaria: List<String>.from(data['part_societaria'] ?? []),
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


  @override
  Widget build(BuildContext context) { //Constrói o design
    return Scaffold( //Estrutura base da tela
      appBar: AppBar(title: const Text('Catálogo')), //Barra superior com título
      body: BackgroundContainer( //Fundo personalizado

      ),
    );
  }
}

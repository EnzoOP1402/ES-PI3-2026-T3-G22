class CardCatalogo { //Classe que representa uma startup
  final String nome_startup;
  final String data_criacao;
  final String mini_descricao;
  final String estagio_stp;
  final String status_stp;
  final int tokens_disponiveis;
  final int tokens_emitidos;
  final double valorFixo_token;
  final double capital_aportado;
  final String setor_stp;
  final String? video_demoURL;
  final List<String> socios_stp;
  final List<String> ment_conselho;
  final List<int> ofertas_ativas;
  final List<String> part_societaria;

  CardCatalogo({ //Construtor da classe
    required this.nome_startup,
    required this.data_criacao,
    required this.mini_descricao,
    required this.estagio_stp,
    required this.status_stp,
    required this.tokens_disponiveis,
    required this.tokens_emitidos,
    required this.valorFixo_token,
    required this.capital_aportado,
    required this.setor_stp,
    this.video_demoURL,
    required this.socios_stp,
    required this.ment_conselho,
    required this.ofertas_ativas,
    required this.part_societaria,

      });
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
    ofertas_ativas: List<int>.from(data['ofetas_ativas'] ?? []),
    part_societaria: List<String>.from(data['part_societaria'] ?? []),
  );    
}

}



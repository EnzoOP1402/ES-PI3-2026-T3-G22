class CardCatalogo {
  //Classe que representa uma startup
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
  final List<Map<String, dynamic>> ofertas_ativas;
  final List<String> part_societaria;

  CardCatalogo({
    //Construtor da classe
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
  factory CardCatalogo.fromFirestore(Map<String, dynamic> data) {
    //Construtor especial que transforma dados do Firebase em objeto Dart.
    return CardCatalogo(
      //Cria um novo objeto
      nome_startup: data['nome'] ?? '', //Se existir usa, senão usa string vazia
      data_criacao: data['dataCriacao'] ?? '',
      mini_descricao: data['descricao'] ?? '',
      estagio_stp: data['estagio'] ?? '',
      status_stp: data['status'] ?? '',
      tokens_disponiveis: data['tokensDisponiveis'] ?? 0,
      tokens_emitidos: data['tokensEmitidos'] ?? 0,
      valorFixo_token: (data['valorFixoTokens'] ?? 0)
          .toDouble(), //Garante que o valor seja double
      capital_aportado: (data['capitalAportado'] ?? 0).toDouble(),
      setor_stp: data['setor'] ?? '',
      video_demoURL: data['videoDemo'],
      socios_stp: List<String>.from(
        data['socios'] ?? [],
      ), //Converte lista dinâmica em lista de String
      ment_conselho: List<String>.from(data['mentoresConselho'] ?? []),
      ofertas_ativas: List<Map<String, dynamic>>.from(
        data['ofertasAtivas'] ?? [],
      ),
      part_societaria: List<String>.from(data['participacaoSocietaria'] ?? []),
    );
  }
}

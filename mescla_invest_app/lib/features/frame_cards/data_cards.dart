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
    // 1. Tratamento para a lista de sócios (founders)
    final List<String> listaSocios = [];
    if (data['founders'] != null && data['founders'] is List) {
      for (var f in data['founders']) {
        if (f is Map && f['name'] != null) {
          listaSocios.add(f['name'].toString());
        }
      }
    }

    // 2. Tratamento para a lista de mentores (externalMembers)
    final List<String> listaMentores = [];
    if (data['externalMembers'] != null && data['externalMembers'] is List) {
      for (var m in data['externalMembers']) {
        if (m is Map && m['name'] != null) {
          listaMentores.add(m['name'].toString());
        }
      }
    }

    // 3. Retorno do objeto mapeando os campos do Firebase para os da classe
    return CardCatalogo(
      nome_startup: data['name'] ?? 'Sem nome',
      data_criacao: data['dataCriacao'] ?? '',
      mini_descricao: data['shortDescription'] ?? data['description'] ?? '',
      estagio_stp: data['stage'] ?? '',
      status_stp: data['status'] ?? 'Ativo',
      tokens_disponiveis: (data['totalTokensIssued'] ?? 0) as int,
      tokens_emitidos: (data['totalTokensIssued'] ?? 0) as int,
      valorFixo_token: ((data['currentTokenPriceCents'] ?? 0) as int) / 100.0,
      capital_aportado: ((data['capitalRaisedCents'] ?? 0) as int) / 100.0,
      setor_stp: (data['tags'] as List?)?.isNotEmpty == true
          ? data['tags'][0].toString()
          : 'Geral',
      video_demoURL: (data['demoVideos'] as List?)?.isNotEmpty == true
          ? data['demoVideos'][0].toString()
          : null,
      socios_stp: listaSocios,
      ment_conselho: listaMentores,
      ofertas_ativas: [], // Inicializa vazio se não houver no banco
      part_societaria: [], // Inicializa vazio se não houver no banco
    );
  }
}

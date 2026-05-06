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
    return CardCatalogo(
      nome_startup: data['name'] ?? '',

      data_criacao: '', // você não tem esse campo no Firebase

      mini_descricao: data['shortDescription'] ?? data['description'] ?? '',

      estagio_stp: data['stage'] ?? '',

      status_stp:
          data['stage'] ?? '', // você não tem "status", então usei stage

      tokens_disponiveis: 0, // não existe no Firebase

      tokens_emitidos: data['totalTokensIssued'] ?? 0,

      valorFixo_token: ((data['currentTokenPriceCents'] ?? 0) / 100).toDouble(),

      capital_aportado: ((data['capitalRaisedCents'] ?? 0) / 100).toDouble(),

      setor_stp: (data['tags'] != null && data['tags'].isNotEmpty)
          ? data['tags'][0]
          : '',

      video_demoURL:
          (data['demoVideos'] != null &&
              (data['demoVideos'] as List).isNotEmpty)
          ? data['demoVideos'][0]
          : null,

      /// 👇 founders → nomes
      socios_stp: List<String>.from(
        data['founders']?.map((e) => e['name']) ?? [],
      ),

      /// 👇 externalMembers → nomes
      ment_conselho: List<String>.from(
        data['externalMembers']?.map((e) => e['name']) ?? [],
      ),

      ofertas_ativas: [], // não existe no Firebase
      /// 👇 equityPercent → string formatada
      part_societaria: List<String>.from(
        data['founders']?.map((e) => "${e['name']} - ${e['equityPercent']}%") ??
            [],
      ),
    );
  }
}

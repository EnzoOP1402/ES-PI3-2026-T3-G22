/* Autor: Rafael Henrique dos Santos Inácio 
RA: 25009719*/

// Modelo de dados (Data Model) que representa um Token que o usuário possui na carteira.
// Serve para estruturar as informações do token e sua relação com a startup emissora.
class TokenModel {
  // Identificador único da startup associada a este token
  final String startupId;

  // Nome da startup que emitiu o token
  final String startupName;

  // Nome ou sigla identificadora do token em si
  final String tokenName;

  // Quantidade de unidades deste token que o usuário possui
  final int quantity;

  // Construtor principal da classe.
  // Utiliza 'required' para garantir que nenhum token seja instanciado com dados incompletos,
  // protegendo o aplicativo de possíveis quebras por valores nulos (Null Safety).
  TokenModel({
    required this.startupId,
    required this.startupName,
    required this.tokenName,
    required this.quantity,
  });

  // Método de Serialização (Object para Map).
  // Transforma as propriedades da classe em uma estrutura de chave-valor (Map<String, dynamic>).
  // É amplamente utilizado na hora de enviar esses dados para o backend, APIs ou salvar em bancos de dados (ex: Firebase).
  Map<String, dynamic> toMap() {
    return {
      'startupId': startupId,
      'startupName': startupName,
      'tokenName': tokenName,
      'quantity': quantity,
    };
  }

  // Factory Constructor de Desserialização (Map para Object).
  // Faz o caminho inverso do toMap: recebe um mapa (geralmente um JSON vindo da API/Banco de Dados)
  // e constrói uma instância válida de TokenModel a partir dele.
  factory TokenModel.fromMap(Map<String, dynamic> map) {
    return TokenModel(
      // O operador '??' (if null) atua como um fallback de segurança.
      // Se a chave não existir no mapa ou vier nula, ele atribui uma string vazia ('') ou zero (0),
      // evitando que o aplicativo quebre na hora de renderizar a tela.
      startupId: map['startupId'] ?? '',
      startupName: map['startupName'] ?? '',
      tokenName: map['tokenName'] ?? '',
      quantity: map['quantity'] ?? 0,
    );
  }
}

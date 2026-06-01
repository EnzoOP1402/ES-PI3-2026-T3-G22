/* Autor: Rafael Henrique dos Santos Inácio 
RA: 25009719*/

// Modelo de dados que representa de forma simplificada um token associado à carteira do usuário.
class UserTokenModel {
  // Identificador único da startup (geralmente corresponde ao ID do documento no banco de dados)
  final String startupId;

  // Nome da startup responsável pela emissão do token
  final String startupName;

  // Quantidade de tokens desta startup que o usuário possui
  final int quantity;

  // Construtor principal da classe, exigindo o preenchimento de todos os campos (Null Safety)
  UserTokenModel({
    required this.startupId,
    required this.startupName,
    required this.quantity,
  });

  // Factory Constructor de Desserialização (Map para Object).
  // Recebe o ID separadamente do Map. Esse padrão é amplamente utilizado na integração com
  // bancos de dados NoSQL (como o Firebase Firestore), onde o ID do documento é extraído
  // do snapshot e os dados reais vêm do corpo do documento (map).
  factory UserTokenModel.fromMap(String id, Map<String, dynamic> map) {
    return UserTokenModel(
      startupId: id, // O ID é injetado diretamente pelo parâmetro avulso
      startupName:
          map['startupName'] ??
          '', // Fallback para string vazia em caso de ausência do dado
      quantity:
          map['quantity'] ??
          0, // Fallback para zero para garantir segurança em cálculos
    );
  }
}

// Modelo de dados agregado que consolida as informações gerais da carteira do usuário.
// Serve como um "Wrapper" (empacotador) para enviar o estado completo da carteira para a interface (UI).
class WalletDetails {
  // Saldo financeiro total disponível na carteira
  final double balance;

  // Lista contendo todos os tokens (e suas respectivas quantidades) que compõem o portfólio do usuário
  final List<UserTokenModel> tokens;

  // Construtor da classe, garantindo que a carteira sempre seja instanciada com seu saldo e seus tokens
  WalletDetails({required this.balance, required this.tokens});
}

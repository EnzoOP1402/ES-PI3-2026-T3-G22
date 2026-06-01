/* Autor: livia */

// Modelo que representa uma ordem exibida no balcão de negociações
class BoardOrderModel {
  // Identificador da ordem
  final String id;

  // Identificador da startup relacionada à ordem
  final String startupId;

  // Nome da startup
  final String startupName;

  // Nome do token negociado
  final String tokenName;

  // Tipo da ordem, como compra ou venda
  final String type;

  // Preço do token em centavos
  final int priceCents;

  // Quantidade total da ordem
  final int quantity;

  // Quantidade restante ainda disponível
  final int remainingQuantity;

  // Indica se a ordem é considerada uma boa oportunidade
  final bool appreciated;

  // Tendência do preço, como alta, baixa ou igual
  final String priceTrend;

  // Status da ordem
  final String status;

  const BoardOrderModel({
    required this.id,
    required this.startupId,
    required this.startupName,
    required this.tokenName,
    required this.type,
    required this.priceCents,
    required this.quantity,
    required this.remainingQuantity,
    required this.appreciated,
    required this.priceTrend,
    required this.status,
  });

  // Cria um BoardOrderModel a partir de um Map vindo do backend ou Firestore
  factory BoardOrderModel.fromMap(Map<String, dynamic> map) {
    return BoardOrderModel(
      id: map['id']?.toString() ?? '',
      startupId: map['startupId']?.toString() ?? '',
      startupName: map['startupName']?.toString() ?? 'Startup sem nome',
      tokenName: map['tokenName']?.toString() ?? 'TOKEN',
      type: map['type']?.toString() ?? '',
      priceCents: _toInt(map['priceCents']),
      quantity: _toInt(map['quantity']),
      remainingQuantity: _toInt(map['remainingQuantity'] ?? map['quantity']),
      appreciated: _toBool(map['isGoodDeal']),
      priceTrend: map['trend']?.toString() ?? "equal",
      status: map['status']?.toString() ?? 'open',
    );
  }

  // Converte valores dinâmicos para inteiro de forma segura
  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  // Converte valores dinâmicos para booleano de forma segura
  static bool _toBool(dynamic value) {
    if (value is bool) return value;

    if (value?.toString() == 'up') return true;
    if (value?.toString() == 'true') return true;

    return false;
  }
}
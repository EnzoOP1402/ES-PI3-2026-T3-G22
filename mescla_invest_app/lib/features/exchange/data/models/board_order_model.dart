/* Autor: livia */


class BoardOrderModel {
  final String id;
  final String startupId;
  final String startupName;
  final String tokenName;
  final String type;
  final int priceCents;
  final int quantity;
  final int remainingQuantity;
  final bool appreciated;
  final String priceTrend;
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

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value?.toString() == 'up') return true;
    if (value?.toString() == 'true') return true;
    return false;
  }
}
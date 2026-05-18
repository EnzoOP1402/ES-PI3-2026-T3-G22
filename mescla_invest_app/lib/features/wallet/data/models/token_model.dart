/* Autor: Rafael Henrique dos Santos Inácio */

class TokenModel {
  final String startupId;
  final String startupName;
  final String tokenName;
  final int quantity;

  TokenModel({
    required this.startupId,
    required this.startupName,
    required this.tokenName,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'startupId': startupId,
      'startupName': startupName,
      'tokenName': tokenName,
      'quantity': quantity,
    };
  }

  factory TokenModel.fromMap(Map<String, dynamic> map) {
    return TokenModel(
      startupId: map['startupId'] ?? '',
      startupName: map['startupName'] ?? '',
      tokenName: map['tokenName'] ?? '',
      quantity: map['quantity'] ?? 0,
    );
  }
}

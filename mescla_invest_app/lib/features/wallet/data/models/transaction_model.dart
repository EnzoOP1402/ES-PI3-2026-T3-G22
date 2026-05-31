class TransactionModel {
  final String id;
  final String operationType;
  final bool isNegative;
  final int quantity;
  final double amount;
  final String tokenName;
  final DateTime date;

  TransactionModel({
    required this.id,
    required this.operationType,
    required this.isNegative,
    required this.quantity,
    required this.amount,
    required this.tokenName,
    required this.date,
  });

  factory TransactionModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return TransactionModel(
      id: json['id'],
      operationType: json['operationType'],
      isNegative: json['isNegative'],
      quantity: json['quantity'],
      amount: (json['amount'] as num).toDouble(),
      tokenName: json['tokenName'],
      date: DateTime.parse(json['date']),
    );
  }
}
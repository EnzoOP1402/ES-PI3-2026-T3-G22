/*Gabriela Sichiroli Ferrari*/

// Modelo responsável por representar uma transação
// realizada pelo usuário.
class TransactionModel {

  // Identificador único da transação.
  final String id;

  // Tipo da operação realizada
  // (ex.: compra, venda, transferência).
  final String operationType;

  // Indica se a transação representa uma saída de saldo.
  // true = valor negativo
  // false = valor positivo
  final bool isNegative;

  // Quantidade de tokens envolvidos na transação.
  final int quantity;

  // Valor monetário da transação.
  final double amount;

  // Nome do token relacionado à transação.
  final String tokenName;

  // Data em que a transação foi realizada.
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

  // Constrói um objeto TransactionModel a partir
  // de um mapa JSON retornado pela API.
  factory TransactionModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return TransactionModel(
      id: json['id'],
      operationType: json['operationType'],
      isNegative: json['isNegative'],
      quantity: json['quantity'],

      // Converte o valor para double, garantindo compatibilidade
      // mesmo quando a API retorna int ou double.
      amount: (json['amount'] as num).toDouble(),

      tokenName: json['tokenName'],

      // Converte a data recebida como String para DateTime.
      date: DateTime.parse(json['date']),
    );
  }
}
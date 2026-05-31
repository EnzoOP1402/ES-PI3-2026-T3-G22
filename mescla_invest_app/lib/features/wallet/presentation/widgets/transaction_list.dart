/*Gabriela Sichiroli Ferrari*/

import 'package:flutter/material.dart';
import '../../data/models/transaction_model.dart';
import 'transaction_card.dart';

class TransactionList extends StatelessWidget {
  final List<TransactionModel> transactions;
  const TransactionList({
    super.key,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        return TransactionCard(
          transaction: transactions[index],
        );
      },
    );
  }
}
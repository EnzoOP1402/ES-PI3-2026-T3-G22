/* Autor: Rafael Henrique dos Santos Inácio */

import 'package:cloud_firestore/cloud_firestore.dart';

class UserTokenModel {
  final String startupId;
  final String startupName;
  final int quantity;

  UserTokenModel({
    required this.startupId,
    required this.startupName,
    required this.quantity,
  });

  factory UserTokenModel.fromMap(String id, Map<String, dynamic> map) {
    return UserTokenModel(
      startupId: id,
      startupName: map['startupName'] ?? '',
      quantity: map['quantity'] ?? 0,
    );
  }
}

class WalletDetails {
  final double balance;
  final List<UserTokenModel> tokens;

  WalletDetails({required this.balance, required this.tokens});
}

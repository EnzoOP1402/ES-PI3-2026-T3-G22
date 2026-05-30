/* Autor: livia */

import 'package:cloud_firestore/cloud_firestore.dart';

class OfferModel {
  final String startupId;
  final String startupName;
  final String tokenName;
  final String type; // buy ou sell
  final int priceCents;
  final int quantity;
  final int remainingQuantity;
  final bool appreciated;
  final String status; // open, partial, completed ou canceled
  final Timestamp createdAt;

  OfferModel({
    required this.startupId,
    required this.startupName,
    required this.tokenName,
    required this.type,
    required this.priceCents,
    required this.quantity,
    required this.remainingQuantity,
    required this.appreciated,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'startupId': startupId,
      'startupName': startupName,
      'tokenName': tokenName,
      'type': type,
      'priceCents': priceCents,
      'quantity': quantity,
      'remainingQuantity': remainingQuantity,
      'appreciated': appreciated,
      'status': status,
      'createdAt': createdAt,
    };
  }

  factory OfferModel.fromMap(Map<String, dynamic> map) {
    return OfferModel(
      startupId: map['startupId'] ?? '',
      startupName: map['startupName'] ?? '',
      tokenName: map['tokenName'] ?? '',
      type: map['type'] ?? '',
      priceCents: map['priceCents'] ?? 0,
      quantity: map['quantity'] ?? 0,
      remainingQuantity: map['remainingQuantity'] ?? 0,
      appreciated: map['appreciated'] ?? false,
      status: map['status'] ?? 'open',
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }

  String get formattedPrice {
    return 'R\$ ${(priceCents / 100).toStringAsFixed(2).replaceAll('.', ',')}';
  }
}
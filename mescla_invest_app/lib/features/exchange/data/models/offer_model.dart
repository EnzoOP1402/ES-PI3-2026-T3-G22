/* Autor: livia */

// Importa o Timestamp do Firestore para armazenar data e hora da oferta
import 'package:cloud_firestore/cloud_firestore.dart';

// Modelo que representa uma oferta no balcão/marketplace
class OfferModel {
  // Identificador da startup relacionada à oferta
  final String startupId;

  // Nome da startup exibido na oferta
  final String startupName;

  // Nome do token negociado
  final String tokenName;

  // Tipo da oferta: buy ou sell
  final String type;

  // Preço do token em centavos
  final int priceCents;

  // Quantidade total de tokens da oferta
  final int quantity;

  // Quantidade restante disponível
  final int remainingQuantity;

  // Indica se a oferta está valorizada ou é uma boa oportunidade
  final bool appreciated;

  // Status da oferta: open, partial, completed ou canceled
  final String status;

  // Data de criação da oferta
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

  // Converte o objeto para Map, facilitando salvar no Firestore
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

  // Cria um OfferModel a partir de um Map vindo do Firestore
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

  // Retorna o preço formatado em reais
  String get formattedPrice {
    return 'R\$ ${(priceCents / 100).toStringAsFixed(2).replaceAll('.', ',')}';
  }
}
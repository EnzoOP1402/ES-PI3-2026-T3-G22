/* Autor: Rafael Henrique dos Santos Inácio */

class OfferModel {
  final String id;
  final String tokenTicker;
  final double price;
  final String orderType; // "Ordem de compra" ou "Ordem de venda"
  final int quantity;

  OfferModel({
    required this.id,
    required this.tokenTicker,
    required this.price,
    required this.orderType,
    required this.quantity,
  });
}

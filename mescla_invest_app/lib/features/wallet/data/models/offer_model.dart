/* Autor: Rafael Henrique dos Santos Inácio 
RA: 25009719*/

// Modelo de dados (Data Model) que representa uma oferta/ordem estruturada dentro do aplicativo.
// Esta classe é utilizada para tipar e padronizar as informações dos tokens,
// facilitando o tráfego de dados entre a interface (UI) e o repositório/API.
class OfferModel {
  // Identificador único da oferta, geralmente gerado pelo banco de dados
  final String id;

  // Sigla ou código identificador do token relacionado à oferta (Ex: BTC, ETH, MSCL)
  final String tokenTicker;

  // Preço unitário estipulado para a oferta do token em questão
  final double price;

  // Define a natureza da operação financeira que o usuário está realizando
  final String orderType; // "Ordem de compra" ou "Ordem de venda"

  // Quantidade de tokens que compõem o lote desta oferta específica
  final int quantity;

  // Construtor da classe.
  // O modificador 'required' garante segurança (Null Safety), impedindo que um objeto
  // OfferModel seja instanciado sem que todos esses dados obrigatórios sejam informados.
  OfferModel({
    required this.id,
    required this.tokenTicker,
    required this.price,
    required this.orderType,
    required this.quantity,
  });
}

/*Autor: Gabriela Sichiroli Ferrari - RA: 25013763 */


import 'package:cloud_functions/cloud_functions.dart';
import 'package:mescla_invest_app/features/wallet/data/models/offer_model.dart';
import 'package:mescla_invest_app/features/wallet/data/models/token_model.dart';
import 'package:mescla_invest_app/features/wallet/data/models/transaction_model.dart';
import '../models/wallet_model.dart';

// Repositório responsável pela comunicação entre o aplicativo
// e as Firebase Functions relacionadas à carteira.
class WalletRepository {

  // Construtor privado para implementar Singleton.
  WalletRepository._();

  // Instância única do repositório.
  static final instance = WalletRepository._();

  // Referência para as Cloud Functions da região utilizada pelo projeto.
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(
        region: 'southamerica-east1',
      );

  // Obtém os dados da carteira do usuário.
  Future<WalletDetails> getWalletData() async {
    try {
      final callable = _functions.httpsCallable(
        'getUserBalance',
      );

      final result = await callable.call();

      final data = Map<String, dynamic>.from(
        result.data,
      );

      // Saldo recebido em centavos.
      final int balanceAvailableCents =
          data['balanceAvailableCents'] ?? 0;

      // Conversão de centavos para reais.
      final wallet = WalletDetails(
        balance: balanceAvailableCents / 100,
        tokens: [],
      );

      return wallet;
    } on FirebaseFunctionsException catch (e) {

      // Trata erros retornados pela Function.
      throw Exception(
        e.message ??
            'Erro ao carregar carteira',
      );
    } catch (e) {

      // Repassa outros erros para camadas superiores.
      rethrow;
    }
  }

  // Adiciona saldo à carteira do usuário.
  Future<void> addBalance(int amountCents
  ) async {
    try {
      final callable = _functions.httpsCallable(
        'addBalance',
      );

      await callable.call({
        'amountCents': amountCents,
      });
    } on FirebaseFunctionsException catch (e) {
      throw Exception(
        e.message ??
            'Erro ao adicionar saldo',
      );
    }
  }

  // Obtém todas as ofertas criadas pelo usuário.
  Future<List<OfferModel>> getUserOffers(
  ) async {
    try {
      final result = await _functions
          .httpsCallable(
            'getUserOffers',
          )
          .call();

      final data = result.data;

      final List offers =
          data['userOffers'];

      // Converte os dados retornados pela API
      // em uma lista de OfferModel.
      return offers.map((offer) {
        return OfferModel(
          id: offer['id'],
          tokenTicker:
              offer['tokenName'],

          // Conversão de centavos para reais.
          price:
              offer['priceCents'] / 100,

          // Tradução do tipo de ordem.
          orderType:
              offer['type'] == 'buy'
                  ? 'Ordem de compra'
                  : 'Ordem de venda',

          quantity:
              offer['quantity'],
        );
      }).toList();
    } catch (e) {
      throw Exception(
        'Erro ao carregar ofertas: $e',
      );
    }
  }

  // Obtém a lista de tokens pertencentes ao usuário.
  Future<List<TokenModel>> getTokensListByUser(
  ) async {
    try {
      final result = await _functions
          .httpsCallable(
            'getTokensListByUser',
          )
          .call();

      final List tokenList =
          result.data['tokenList'];

      // Converte os dados recebidos em objetos TokenModel.
      return tokenList.map((token) {
        return TokenModel(
          startupId:
              token['startupId'],
          startupName:
              token['startupName'],
          tokenName:
              token['tokenName'],
          quantity:
              token['quantity'],
        );
      }).toList();
    } catch (e) {
      throw Exception(
        'Erro ao carregar tokens: $e',
      );
    }
  }

  // Cancela uma oferta existente.
  Future<void> cancelOrder({
    required String orderId,
  }) async {
    try {
      final callable = _functions
          .httpsCallable(
        'cancelOrder',
      );

      await callable.call({
        'orderId': orderId,
      });
    } on FirebaseFunctionsException catch (e) {
      throw Exception(
        e.message ??
            'Erro ao cancelar oferta',
      );
    }
  }

  // Obtém o histórico de transações do usuário.
  Future<List<TransactionModel>> getTransactionHistory(
  ) async {
    try {
      final result = await _functions
          .httpsCallable(
            'getUserTradesHistory',
          )
          .call();

      final List transactions = result.data['transactions'];

      // Converte cada item retornado pela API
      // para um objeto TransactionModel.
      return transactions.map( (transaction) {
          return TransactionModel.fromJson(
            Map<String, dynamic>.from(
              transaction,
            ),
          );
        },
      ).toList();
    } on FirebaseFunctionsException catch (e) {
      throw Exception(
        e.message ??
          'Erro ao carregar histórico',
      );
    }
  }
}
/*Gabriela Sichiroli Ferrari*/

import 'package:cloud_functions/cloud_functions.dart';
import 'package:mescla_invest_app/features/wallet/data/models/offer_model.dart';
import 'package:mescla_invest_app/features/wallet/data/models/token_model.dart';
import 'package:mescla_invest_app/features/wallet/data/models/transaction_model.dart';
import '../models/wallet_model.dart';

class WalletRepository {
  WalletRepository._();

  static final instance = WalletRepository._();

  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor( region: 'southamerica-east1');

Future<WalletDetails> getWalletData() async {
  try {
    final callable = _functions.httpsCallable(
      'getUserBalance' 
      );

    final result = await callable.call();
    final data = Map<String, dynamic>.from(result.data);
    final int balanceAvailableCents = data['balanceAvailableCents'] ?? 0;
    final wallet = WalletDetails(
      balance: balanceAvailableCents / 100,
      tokens: [],
    );
    return wallet;
  } on FirebaseFunctionsException catch (e) {

    throw Exception(
      e.message ??
        'Erro ao carregar carteira',
    );
  } catch (e) {
    rethrow;
  }
}

Future<void> addBalance(int amountCents,) async {
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
  Future<List<OfferModel>> getUserOffers() async {
    try {
      final result = await _functions
          .httpsCallable('getUserOffers')
          .call();

      final data = result.data;

      final List offers = data['userOffers'];

      return offers.map((offer) {
        return OfferModel(
          id: offer['id'],
          tokenTicker: offer['tokenName'],
          price: offer['priceCents'] / 100,
          orderType: offer['type'] == 'buy'
              ? 'Ordem de compra'
              : 'Ordem de venda',
          quantity: offer['quantity'],
        );
      }).toList();
    } catch (e) {
      throw Exception('Erro ao carregar ofertas: $e');
    }
  }
  Future<List<TokenModel>> getTokensListByUser() async {
    try {
      final result = await _functions
          .httpsCallable('getTokensListByUser')
          .call();

      final List tokenList = result.data['tokenList'];

      return tokenList.map((token) {
        return TokenModel(
          startupId: token['startupId'],
          startupName: token['startupName'],
          tokenName: token['tokenName'],
          quantity: token['quantity'],
        );
      }).toList();
    } catch (e) {
      throw Exception('Erro ao carregar tokens: $e');
    }
  }
    Future<void> cancelOrder({required String orderId}) async {
      try {
        final callable = _functions.httpsCallable(
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
    
Future<List<TransactionModel>> getTransactionHistory() async {
  try {
    final result = await _functions
        .httpsCallable(
          'getUserTradesHistory',
        )
        .call();
    final List transactions = result.data['transactions'];
    return transactions.map((transaction) {
      return TransactionModel.fromJson(
        Map<String, dynamic>.from(
          transaction,
        ),
      );
    }).toList();
  } on FirebaseFunctionsException catch (e) {
    throw Exception(
      e.message ??
      'Erro ao carregar histórico',
    );
  }
}
}


/*Autor: Gabriela Sichiroli Ferrari - RA: 25013763 */


// HISTÓRICO DE ALTERAÇÕES
// 02/11/2026 — Gabriela Sichiroli Ferrari (RA 25013763): refatoração estrutural e correções de manutenção.
import 'package:cloud_functions/cloud_functions.dart';
import 'package:mescla_invest_app/core/services/cloud_functions_client.dart';
import 'package:mescla_invest_app/core/utils/cloud_function_data.dart';
import 'package:mescla_invest_app/features/wallet/data/models/offer_model.dart';
import 'package:mescla_invest_app/features/wallet/data/models/token_model.dart';
import 'package:mescla_invest_app/features/wallet/data/models/transaction_model.dart';
import '../models/wallet_model.dart';

// Repositório responsável pela comunicação entre o aplicativo
// e as Firebase Functions relacionadas à carteira.
class WalletRepository {

  // Instância padrão para as telas existentes. Também aceita injeção nos testes.
  WalletRepository({CloudFunctionsClient? functions})
      : _functions = functions ?? CloudFunctionsClient();

  static final WalletRepository instance = WalletRepository();

  final CloudFunctionsClient _functions;

  // Obtém os dados da carteira do usuário.
  Future<WalletDetails> getWalletData() async {
    try {
      final callable = _functions.callable(
        'getUserBalance',
      );

      final result = await callable.call();

      final data = cloudFunctionDataMap(result.data);

      // Nunca interpretar resposta malformada como saldo zero.
      final int balanceAvailableCents =
          requiredIntegerField(data, 'balanceAvailableCents');

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
    if (amountCents <= 0) {
      throw ArgumentError.value(amountCents, 'amountCents', 'Valor precisa ser positivo.');
    }
    try {
      final callable = _functions.callable(
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
          .callable(
            'getUserOffers',
          )
          .call();

      final data = cloudFunctionDataMap(result.data);
      final List offers = (data['userOffers'] as List?) ?? [];

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
          .callable(
            'getTokensListByUser',
          )
          .call();

      final data = cloudFunctionDataMap(result.data);
      final List tokenList = (data['tokenList'] as List?) ?? [];

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
          .callable(
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
          .callable(
            'getUserTradesHistory',
          )
          .call();

      final data = cloudFunctionDataMap(result.data);
      final List transactions = (data['transactions'] as List?) ?? [];

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
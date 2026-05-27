/* Autor: livia (Refatorado para Cloud Functions) */

import 'package:cloud_functions/cloud_functions.dart';
import 'package:mescla_invest_app/features/exchange/data/models/board_order_model.dart';
import 'package:mescla_invest_app/features/exchange/data/models/exchange_model.dart';

class ExchangeService {
  
  // ---------------------------------------------------------
  // 1. OBTENÇÃO DO BALCÃO GERAL
  // ---------------------------------------------------------
  Future<Map<String, List<BoardOrderModel>>> buscarQuadroBalcao() async {
    final result = await FirebaseFunctions.instanceFor(
      region: 'southamerica-east1',
    ).httpsCallable('getExchangeBoard').call();

    final resultData = Map<String, dynamic>.from(result.data);
    final data = resultData['data'] is Map ? Map<String, dynamic>.from(resultData['data']) : resultData;

    final sellRaw = (data['sellOrders'] ?? []) as List;
    final buyRaw = (data['buyOrders'] ?? []) as List;

    return {
      'sellOrders': sellRaw.map((item) => BoardOrderModel.fromMap(Map<String, dynamic>.from(item))).toList(),
      'buyOrders': buyRaw.map((item) => BoardOrderModel.fromMap(Map<String, dynamic>.from(item))).toList(),
    };
  }

  // ---------------------------------------------------------
  // 2. BUSCA DE STARTUPS PARA FORMULÁRIO
  // ---------------------------------------------------------
  Future<List<StartupExchangeOption>> buscarStartupsParaOrdem({
    required TipoOrdem tipo,
  }) async {
    if (tipo == TipoOrdem.venda) {
      // Usa a Function que mapeia a carteira do usuário (Apenas startups que ele possui tokens)
      final callable = FirebaseFunctions.instanceFor(region: 'southamerica-east1')
          .httpsCallable('getStartupsForSellOrders');
      final response = await callable.call();
      
      final data = Map<String, dynamic>.from(response.data);
      final responseData = data['data'] is Map ? Map<String, dynamic>.from(data['data']) : data;
      
      final listRaw = (responseData['startupsForSellOrders'] ?? []) as List;

      return listRaw.map((item) {
        final map = Map<String, dynamic>.from(item);
        return StartupExchangeOption(
          id: map['id']?.toString() ?? '',
          nome: map['name']?.toString() ?? '',
          simbolo: map['tokenName']?.toString() ?? '',
          valorToken: 0.0, // Ordem de venda não exige preço predefinido
        );
      }).toList();

    } else {
      // Usa a Function que mapeia startups disponíveis no mercado global
      final callable = FirebaseFunctions.instanceFor(region: 'southamerica-east1')
          .httpsCallable('getStartupsForBuyOrders');
      final response = await callable.call();
      
      final data = Map<String, dynamic>.from(response.data);
      final responseData = data['data'] is Map ? Map<String, dynamic>.from(data['data']) : data;

      final listRaw = (responseData['startupsForBuyOrders'] ?? []) as List;

      return listRaw.map((item) {
        final map = Map<String, dynamic>.from(item);
        // O back-end manda em centavos. Convertendo para double no Flutter:
        final priceCents = _toInt(map['currentTokenPriceCents']);
        
        return StartupExchangeOption(
          id: map['id']?.toString() ?? '',
          nome: map['name']?.toString() ?? '',
          simbolo: map['tokenName']?.toString() ?? '',
          valorToken: priceCents / 100.0,
        );
      }).toList();
    }
  }

  // ---------------------------------------------------------
  // 3. CONSULTA PROATIVA DE SALDO
  // ---------------------------------------------------------
  Future<double> obterSaldoDisponivel() async {
    final callable = FirebaseFunctions.instanceFor(region: 'southamerica-east1')
        .httpsCallable('getUserBalance');
    final response = await callable.call();
    
    final data = Map<String, dynamic>.from(response.data);
    final responseData = data['data'] is Map ? Map<String, dynamic>.from(data['data']) : data;

    final cents = _toInt(responseData['balanceAvailableCents']);
    return cents / 100.0;
  }

  // ---------------------------------------------------------
  // 4. MÉTODOS DE ABERTURA E CANCELAMENTO
  // ---------------------------------------------------------
  Future<String> abrirOrdem({
    required String startupId,
    required String startupNome,
    required String simbolo,
    required TipoOrdem tipo,
    required ModoOrdem modo,
    required int quantidadeTokens,
    required double precoUnitario,
  }) async {
    late final HttpsCallable callable;
    late final Map<String, dynamic> payload;

    if (tipo == TipoOrdem.compra && modo == ModoOrdem.mercado) {
      callable = FirebaseFunctions.instanceFor(region: 'southamerica-east1')
          .httpsCallable('buyFromStartupMarket');
      payload = {
        'startupId': startupId,
        'quantity': quantidadeTokens,
      };
    } else if (tipo == TipoOrdem.compra) {
      callable = FirebaseFunctions.instanceFor(region: 'southamerica-east1')
          .httpsCallable('createBuyOrder');
      payload = {
        'startupId': startupId,
        'priceCents': (precoUnitario * 100).round(),
        'quantity': quantidadeTokens,
      };
    } else {
      callable = FirebaseFunctions.instanceFor(region: 'southamerica-east1')
          .httpsCallable('createSellOrder');
      payload = {
        'startupId': startupId,
        'priceCents': (precoUnitario * 100).round(),
        'quantity': quantidadeTokens,
      };
    }

    final response = await callable.call(payload);
    final data = Map<String, dynamic>.from(response.data);
    final responseData = data['data'] is Map ? Map<String, dynamic>.from(data['data']) : data;

    return responseData['id']?.toString() ?? responseData['orderId']?.toString() ?? '';
  }

  Future<void> cancelarOrdem(String ordemId) async {
    final callable = FirebaseFunctions.instanceFor(region: 'southamerica-east1')
        .httpsCallable('cancelOrder');
    await callable.call({'orderId': ordemId});
  }

  // Métodos Utilitários Internos
  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }
}

class StartupExchangeOption {
  final String id;
  final String nome;
  final String simbolo;
  final double valorToken;

  const StartupExchangeOption({
    required this.id,
    required this.nome,
    required this.simbolo,
    required this.valorToken,
  });
}
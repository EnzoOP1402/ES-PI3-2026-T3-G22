/* Autor: livia */

// Imports necessários para chamadas das Firebase Functions e modelos utilizados
import 'package:cloud_functions/cloud_functions.dart';
import 'package:mescla_invest_app/features/exchange/data/models/board_order_model.dart';
import 'package:mescla_invest_app/features/exchange/data/models/exchange_model.dart';

// Serviço responsável por toda a comunicação entre a tela de Exchange e o backend
class ExchangeService {

  // Busca todas as ordens abertas de compra e venda do marketplace
  Future<Map<String, List<BoardOrderModel>>> buscarQuadroBalcao() async {
    final result = await FirebaseFunctions.instanceFor(
      region: 'southamerica-east1',
    ).httpsCallable('getExchangeBoard').call();

    // Converte a resposta para Map
    final resultData = Map<String, dynamic>.from(result.data);

    final data = resultData['data'] is Map
        ? Map<String, dynamic>.from(resultData['data'])
        : resultData;

    // Lista de ordens de venda
    final sellRaw = (data['sellOrders'] ?? []) as List;

    // Lista de ordens de compra
    final buyRaw = (data['buyOrders'] ?? []) as List;

    // Retorna as listas convertidas para objetos BoardOrderModel
    return {
      'sellOrders': sellRaw
          .map(
            (item) => BoardOrderModel.fromMap(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),

      'buyOrders': buyRaw
          .map(
            (item) => BoardOrderModel.fromMap(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
    };
  }

  // Busca as startups disponíveis para criação de ordens
  Future<List<StartupExchangeOption>> buscarStartupsParaOrdem({
    required TipoOrdem tipo,
  }) async {
    // Caso seja uma ordem de venda
    if (tipo == TipoOrdem.venda) {
      // Busca apenas startups que o usuário possui na carteira
      final callable = FirebaseFunctions.instanceFor(
        region: 'southamerica-east1',
      ).httpsCallable('getStartupsForSellOrders');

      final response = await callable.call();

      final data = Map<String, dynamic>.from(response.data);

      final responseData = data['data'] is Map
          ? Map<String, dynamic>.from(data['data'])
          : data;

      final listRaw =
          (responseData['startupsForSellOrders'] ?? []) as List;

      return listRaw.map((item) {
        final map = Map<String, dynamic>.from(item);

        return StartupExchangeOption(
          id: map['id']?.toString() ?? '',
          nome: map['name']?.toString() ?? '',
          simbolo: map['tokenName']?.toString() ?? '',

          // Venda não exige valor pré-definido
          valorToken: 0.0,
        );
      }).toList();
    } else {
      // Busca startups disponíveis para compra
      final callable = FirebaseFunctions.instanceFor(
        region: 'southamerica-east1',
      ).httpsCallable('getStartupsForBuyOrders');

      final response = await callable.call();

      final data = Map<String, dynamic>.from(response.data);

      final responseData = data['data'] is Map
          ? Map<String, dynamic>.from(data['data'])
          : data;

      final listRaw =
          (responseData['startupsForBuyOrders'] ?? []) as List;

      return listRaw.map((item) {
        final map = Map<String, dynamic>.from(item);

        // Valor recebido em centavos
        final priceCents =
            _toInt(map['currentTokenPriceCents']);

        return StartupExchangeOption(
          id: map['id']?.toString() ?? '',
          nome: map['name']?.toString() ?? '',
          simbolo: map['tokenName']?.toString() ?? '',

          // Conversão para reais
          valorToken: priceCents / 100.0,
        );
      }).toList();
    }
  }

  // Obtém o saldo disponível do usuário
  Future<double> obterSaldoDisponivel() async {
    final callable = FirebaseFunctions.instanceFor(
      region: 'southamerica-east1',
    ).httpsCallable('getUserBalance');

    final response = await callable.call();

    final data = Map<String, dynamic>.from(response.data);

    final responseData = data['data'] is Map
        ? Map<String, dynamic>.from(data['data'])
        : data;

    // Saldo recebido em centavos
    final cents =
        _toInt(responseData['balanceAvailableCents']);

    // Conversão para reais
    return cents / 100.0;
  }

  // Cria uma nova ordem de compra ou venda
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

    // Compra a mercado
    if (tipo == TipoOrdem.compra &&
        modo == ModoOrdem.mercado) {
      callable = FirebaseFunctions.instanceFor(
        region: 'southamerica-east1',
      ).httpsCallable('buyFromStartupMarket');

      payload = {
        'startupId': startupId,
        'quantity': quantidadeTokens,
      };

      // Compra limitada
    } else if (tipo == TipoOrdem.compra) {
      callable = FirebaseFunctions.instanceFor(
        region: 'southamerica-east1',
      ).httpsCallable('createBuyOrder');

      payload = {
        'startupId': startupId,
        'priceCents': (precoUnitario * 100).round(),
        'quantity': quantidadeTokens,
      };

      // Ordem de venda
    } else {
      callable = FirebaseFunctions.instanceFor(
        region: 'southamerica-east1',
      ).httpsCallable('createSellOrder');

      payload = {
        'startupId': startupId,
        'priceCents': (precoUnitario * 100).round(),
        'quantity': quantidadeTokens,
      };
    }

    final response = await callable.call(payload);

    final data = Map<String, dynamic>.from(response.data);

    final responseData = data['data'] is Map
        ? Map<String, dynamic>.from(data['data'])
        : data;

    // Retorna o ID da ordem criada
    return responseData['id']?.toString() ??
        responseData['orderId']?.toString() ??
        '';
  }

  // Cancela uma ordem existente
  Future<void> cancelarOrdem(String ordemId) async {
    final callable = FirebaseFunctions.instanceFor(
      region: 'southamerica-east1',
    ).httpsCallable('cancelOrder');

    await callable.call({
      'orderId': ordemId,
    });
  }

  // Converte valores dinâmicos para inteiro
  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value.toString()) ?? 0;
  }
}

// Modelo utilizado para preencher os campos de seleção de startups
class StartupExchangeOption {
  // Identificador da startup
  final String id;

  // Nome da startup
  final String nome;

  // Símbolo do token
  final String simbolo;

  // Valor atual do token
  final double valorToken;

  const StartupExchangeOption({
    required this.id,
    required this.nome,
    required this.simbolo,
    required this.valorToken,
  });
}
/* Autor: livia */


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:mescla_invest_app/features/exchange/data/models/board_order_model.dart';
import 'package:mescla_invest_app/features/exchange/widgets/exchange_model.dart';

class ExchangeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _startupsCollection {
    return _firestore.collection('Startups');
  }

  CollectionReference<Map<String, dynamic>> get _usuariosCollection {
    return _firestore.collection('usuarios');
  }

  Future<Map<String, List<BoardOrderModel>>> buscarQuadroBalcao() async {
    final result = await FirebaseFunctions.instanceFor(
      region: 'southamerica-east1',
    ).httpsCallable('getExchangeBoard').call();

    final resultData = Map<String, dynamic>.from(result.data);

    final data = resultData['data'] is Map
        ? Map<String, dynamic>.from(resultData['data'])
        : resultData;

    final sellRaw = (data['sellOrders'] ?? []) as List;
    final buyRaw = (data['buyOrders'] ?? []) as List;

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

  Stream<List<StartupExchangeOption>> buscarStartupsParaOrdem({
    required TipoOrdem tipo,
  }) {
    if (tipo == TipoOrdem.venda) {
      return _buscarStartupsQueUsuarioPossuiTokens();
    }

    return _buscarTodasStartups();
  }

  Stream<List<StartupExchangeOption>> _buscarTodasStartups() {
    return _startupsCollection.snapshots().map((snapshot) {
      final startups = snapshot.docs.map(_startupFromDoc).toList();
      startups.sort((a, b) => a.nome.compareTo(b.nome));
      return startups;
    });
  }

  Stream<List<StartupExchangeOption>> _buscarStartupsQueUsuarioPossuiTokens() {
    final usuarioAtual = _auth.currentUser;

    if (usuarioAtual == null) {
      return Stream.value([]);
    }

    final usuarioRef = _usuariosCollection.doc(usuarioAtual.uid);

    return usuarioRef.snapshots().asyncMap((usuarioSnapshot) async {
      final Set<String> startupIdsComTokens = {};
      final usuarioData = usuarioSnapshot.data();
      final tokensMap = usuarioData?['tokens'];

      if (tokensMap is Map) {
        tokensMap.forEach((startupId, quantidade) {
          final qtd = _toDouble(quantidade);
          if (qtd > 0) {
            startupIdsComTokens.add(startupId.toString());
          }
        });
      }

      final ativosSnapshot = await usuarioRef.collection('ativos').get();

      for (final ativoDoc in ativosSnapshot.docs) {
        final ativoData = ativoDoc.data();

        final quantidadeTokens = _toDouble(
          ativoData['quantidadeTokens'] ??
              ativoData['quantidade'] ??
              ativoData['tokens'] ??
              0,
        );

        if (quantidadeTokens > 0) {
          startupIdsComTokens.add(ativoDoc.id);
        }
      }

      if (startupIdsComTokens.isEmpty) {
        return <StartupExchangeOption>[];
      }

      final startupsSnapshot = await _startupsCollection.get();

      final startups = startupsSnapshot.docs
          .where((doc) => startupIdsComTokens.contains(doc.id))
          .map(_startupFromDoc)
          .toList();

      startups.sort((a, b) => a.nome.compareTo(b.nome));

      return startups;
    });
  }

  StartupExchangeOption _startupFromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    final String nome = _pegarTextoStartup(
      data,
      [
        'name',
        'nome',
        'title',
        'startupNome',
        'razaoSocial',
      ],
      valorPadrao: 'Startup sem nome',
    );

    final String simbolo = _pegarTextoStartup(
      data,
      [
        'tokenName',
        'simbolo',
        'ticker',
        'tag',
        'symbol',
      ],
      valorPadrao: _gerarSimbolo(nome),
    ).toUpperCase();

    final double valorToken = _pegarValorToken(data);

    return StartupExchangeOption(
      id: doc.id,
      nome: nome,
      simbolo: simbolo,
      valorToken: valorToken,
    );
  }

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
      callable = FirebaseFunctions.instanceFor(
        region: 'southamerica-east1',
      ).httpsCallable('buyFromStartupMarket');

      payload = {
        'startupId': startupId,
        'quantity': quantidadeTokens,
      };
    } else if (tipo == TipoOrdem.compra) {
      callable = FirebaseFunctions.instanceFor(
        region: 'southamerica-east1',
      ).httpsCallable('createBuyOrder');

      payload = {
        'startupId': startupId,
        'priceCents': (precoUnitario * 100).round(),
        'quantity': quantidadeTokens,
      };
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

    return responseData['id']?.toString() ??
        responseData['orderId']?.toString() ??
        responseData['ordemId']?.toString() ??
        '';
  }

  Future<void> cancelarOrdem(String ordemId) async {
    final callable = FirebaseFunctions.instanceFor(
      region: 'southamerica-east1',
    ).httpsCallable('cancelOrder');

    await callable.call({
      'orderId': ordemId,
    });
  }

  double _pegarValorToken(Map<String, dynamic> data) {
    final valorEmCentavos = data['currentTokenPriceCents'];

    if (valorEmCentavos is num && valorEmCentavos > 0) {
      return valorEmCentavos / 100;
    }

    final valorDireto = _pegarNumeroStartup(
      data,
      [
        'valorToken',
        'valorFixoTokens',
        'tokenValue',
        'precoToken',
        'precoUnitario',
        'valorAtualToken',
        'valorAtualDeUmToken',
        'valorAtualUmToken',
        'valorUnitarioToken',
        'currentTokenValue',
        'tokenPrice',
      ],
    );

    if (valorDireto > 0) {
      return valorDireto;
    }

    final double tokensEmitidos = _pegarNumeroStartup(
      data,
      [
        'tokensEmitidos',
        'totalTokensEmitidos',
        'tokensIssued',
        'totalTokensIssued',
        'issuedTokens',
        'totalTokens',
        'tokens',
      ],
    );

    final double capitalAportado = _pegarNumeroStartup(
      data,
      [
        'capitalAportado',
        'capitalInvestido',
        'capitalInvested',
        'investedCapital',
        'capitalRaised',
        'volumeCaptado',
        'simulatedCapital',
        'capital',
      ],
    );

    if (tokensEmitidos > 0 && capitalAportado > 0) {
      return capitalAportado / tokensEmitidos;
    }

    return 0;
  }

  String _pegarTextoStartup(
    Map<String, dynamic> data,
    List<String> campos, {
    required String valorPadrao,
  }) {
    for (final campo in campos) {
      final valor = data[campo];

      if (valor != null && valor.toString().trim().isNotEmpty) {
        return valor.toString().trim();
      }
    }

    return valorPadrao;
  }

  double _pegarNumeroStartup(
    Map<String, dynamic> data,
    List<String> campos,
  ) {
    for (final campo in campos) {
      final numero = _toDouble(data[campo]);

      if (numero > 0) {
        return numero;
      }
    }

    return 0;
  }

  String _gerarSimbolo(String nome) {
    final partes = nome
        .trim()
        .split(' ')
        .where((parte) => parte.trim().isNotEmpty)
        .toList();

    if (partes.isEmpty) {
      return 'STP';
    }

    if (partes.length == 1) {
      final palavra = partes.first.toUpperCase();

      if (palavra.length >= 3) {
        return palavra.substring(0, 3);
      }

      return palavra;
    }

    return partes
        .take(3)
        .map((parte) => parte[0])
        .join()
        .toUpperCase();
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();

    var texto = value.toString().trim();

    if (texto.isEmpty) return 0;

    texto = texto
        .replaceAll('R\$', '')
        .replaceAll('r\$', '')
        .replaceAll(' ', '')
        .trim();

    if (texto.contains(',') && texto.contains('.')) {
      texto = texto.replaceAll('.', '').replaceAll(',', '.');
    } else if (texto.contains(',')) {
      texto = texto.replaceAll(',', '.');
    }

    return double.tryParse(texto) ?? 0;
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
/* Autor: livia */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mescla_invest_app/features/exchange/widgets/exchange_model.dart';

class ExchangeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _ofertasCollection {
    return _firestore.collection('balcao_ofertas');
  }

  CollectionReference<Map<String, dynamic>> get _startupsCollection {
    return _firestore.collection('Startups');
  }

  CollectionReference<Map<String, dynamic>> get _usuariosCollection {
    return _firestore.collection('usuarios');
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

  double _pegarValorToken(Map<String, dynamic> data) {
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

    final mapasPossiveis = [
      data['financialPanel'],
      data['painelFinanceiro'],
      data['financeiro'],
      data['financial'],
      data['dadosFinanceiros'],
      data['finances'],
    ];

    for (final mapa in mapasPossiveis) {
      if (mapa is Map) {
        final valorDiretoNoMapa = _pegarNumeroEmMap(
          mapa,
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

        if (valorDiretoNoMapa > 0) {
          return valorDiretoNoMapa;
        }

        final tokensEmitidosNoMapa = _pegarNumeroEmMap(
          mapa,
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

        final capitalAportadoNoMapa = _pegarNumeroEmMap(
          mapa,
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

        if (tokensEmitidosNoMapa > 0 && capitalAportadoNoMapa > 0) {
          return capitalAportadoNoMapa / tokensEmitidosNoMapa;
        }
      }
    }

    return 0;
  }

  Stream<List<OfertaBalcao>> buscarOrdensDeVenda() {
    return _buscarOfertasPorTipo(TipoOrdem.venda);
  }

  Stream<List<OfertaBalcao>> buscarOrdensDeCompra() {
    return _buscarOfertasPorTipo(TipoOrdem.compra);
  }

  Stream<List<OfertaBalcao>> _buscarOfertasPorTipo(TipoOrdem tipo) {
    return _ofertasCollection
        .where('tipo', isEqualTo: tipo.value)
        .where('status', isEqualTo: 'aberta')
        .snapshots()
        .map((snapshot) {
      final ofertas = snapshot.docs.map((doc) {
        final data = doc.data();

        return OfertaBalcao.fromMap({
          ...data,
          'id': doc.id,
        });
      }).toList();

      ofertas.sort((a, b) {
        final dataA = a.criadaEm ?? DateTime(2000);
        final dataB = b.criadaEm ?? DateTime(2000);

        return dataB.compareTo(dataA);
      });

      return ofertas;
    });
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
    final callable = _functions.httpsCallable('abrirOrdemBalcao');

    final response = await callable.call({
      'startupId': startupId,
      'startupNome': startupNome,
      'simbolo': simbolo,
      'tipo': tipo.value,
      'modo': modo.value,
      'quantidadeTokens': quantidadeTokens,
      'precoUnitario': precoUnitario,
    });

    final data = Map<String, dynamic>.from(response.data);

    return data['ordemId']?.toString() ?? '';
  }

  Future<void> cancelarOrdem(String ordemId) async {
    final callable = _functions.httpsCallable('cancelarOrdemBalcao');

    await callable.call({
      'ordemId': ordemId,
    });
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

  double _pegarNumeroEmMap(
    Map<dynamic, dynamic> data,
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
    if (value == null) {
      return 0;
    }

    if (value is double) {
      return value;
    }

    if (value is int) {
      return value.toDouble();
    }

    if (value is num) {
      return value.toDouble();
    }

    var texto = value.toString().trim();

    if (texto.isEmpty) {
      return 0;
    }

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
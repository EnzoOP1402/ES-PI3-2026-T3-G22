/* Autor: livia */

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../presentation/widgets/balcao/balcao_model.dart';

class BalcaoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _ofertasCollection {
    return _firestore.collection('balcao_ofertas');
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

  Future<void> criarOrdem({
    required String startupId,
    required String startupNome,
    required String simbolo,
    required TipoOrdem tipo,
    required int quantidadeTokens,
    required double precoUnitario,
  }) async {
    await _ofertasCollection.add({
      'startupId': startupId,
      'startupNome': startupNome,
      'simbolo': simbolo,
      'tipo': tipo.value,
      'status': 'aberta',
      'quantidadeTokens': quantidadeTokens,
      'precoUnitario': precoUnitario,
      'variacaoPercentual': 0,
      'criadaEm': FieldValue.serverTimestamp(),
    });
  }

  Future<void> cancelarOrdem(String ordemId) async {
    await _ofertasCollection.doc(ordemId).update({
      'status': 'cancelada',
    });
  }
}
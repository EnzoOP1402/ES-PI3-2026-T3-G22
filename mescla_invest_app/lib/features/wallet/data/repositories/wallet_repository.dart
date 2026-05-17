import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mescla_invest_app/features/auth/data/repositories/auth_repository.dart';
import '../models/wallet_model.dart';

class WalletRepository {
  static final WalletRepository _instance = WalletRepository._internal();
  static WalletRepository get instance => _instance;
  WalletRepository._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Função para buscar o saldo e os tokens do usuário logado de forma combinada
  Future<WalletDetails> getWalletData() async {
    // Recupera o UID do usuário logado dinamicamente do AuthRepository
    final uid = AuthRepository.instance.currentUser?.uid;
    if (uid == null) throw Exception("Usuário não autenticado.");

    // 1. Busca o saldo do usuário na coleção principal de usuários
    final userDoc = await _db.collection('users').doc(uid).get();
    final userData = userDoc.data() ?? {};
    final int balanceCents = userData['balanceCents'] ?? 0;
    final double balance = balanceCents / 100; // Converte centavos para Real

    // 2. Busca a lista de tokens adquiridos na subcoleção do usuário
    final tokensSnapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('tokens')
        .get();

    final List<UserTokenModel> tokens = tokensSnapshot.docs.map((doc) {
      return UserTokenModel.fromMap(doc.id, doc.data());
    }).toList();

    return WalletDetails(balance: balance, tokens: tokens);
  }
}

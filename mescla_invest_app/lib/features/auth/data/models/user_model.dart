/* Autor: Enzo Olivato Pazian */

// Classe com o o modelo de dados dos usuários cadastrados
// Aqui definimos os atributos e métodos relacionados à padronização das
// informações dos usuários investidores conforme manda o escopo

// Importação das dependências
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  // Declarando os atributos da classe/usuário
  final String uid;
  final String fullName;
  final String email;
  final String cpf;
  final String phone;
  // final bool twoFAOn;
  final Timestamp? createdAt;
  final double balance;

  // Definindo o construtor da classe com parâmetros nomeados
  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.cpf,
    required this.phone,
    // required this.twoFAOn,
    required this.createdAt,
    required this.balance,
  });

  /// Método toMap() - Retorna um Map/objeto contendo as informações de um usuário
  Map<String, dynamic> toMap(){
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'cpf': cpf,
      'phone': phone,
      'createdAt': createdAt,
      'balance': balance,
    };
  }

  // Criando um construtor factory para converter os dados do map criado pelo método toMap()
  /// factory fromMap() - converte o [map] que o Firestore devolve em um objeto UserModel
  /// com dados devidamente tratados, fazendo com que, se seus dados forem inexistentes/nulos,
  /// ele os substitui por Strings vazias ou campos nulos sem precisar criar uma nova instância para isso.
  factory UserModel.fromMap(Map<String, dynamic> map) {
  return UserModel(
    uid: map['uid'] ?? '',
    fullName: map['fullName'] ?? '',
    email: map['email'] ?? '',
    cpf: map['cpf'] ?? '',
    phone: map['phone'] ?? '',
    createdAt: map['createdAt'] as Timestamp?,
    balance: (map['balance'] ?? 0.0).toDouble(),
  );
}

  /// Método copyWith() - Cria uma cópia de um usuário criado para atribuir o UID do usuário
  /// que é retornado após a criação de uma conta para o usuário no Firebase Authentication
  UserModel copyWith({
    String? uid,
    String? fullName,
    String? email,
    String? cpf,
    String? phone,
    Timestamp? createdAt,
    double? balance,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      cpf: cpf ?? this.cpf,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      balance: balance ?? this.balance,
    );
  }
}
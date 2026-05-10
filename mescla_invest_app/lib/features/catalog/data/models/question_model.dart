/* Autor: Enzo Olivato Pazian */

// Classe com o o modelo de dados das perguntas feitas às startups
// Aqui definimos os atributos e métodos relacionados à padronização das
// informações das perguntas

// Importação das dependências
import 'package:cloud_firestore/cloud_firestore.dart';

// Definindo o enum que representa o tipo de visibilidade das perguntas
enum QuestionVisibility {
  publica,
  privada;

  // Helper para converter a String do Firestore de volta para Enum
  static QuestionVisibility fromString(String value) {
    return QuestionVisibility.values.firstWhere(
      (e) => e.name == value,
      orElse: () => QuestionVisibility.publica,
    );
  }
}

class QuestionModel {
  // Declarando os atributos da classe/pergunta
  final String authorId;
  final String? authorEmail;
  final String text;
  final QuestionVisibility visibility;
  final String? answer;
  final Timestamp? answeredAt;
  final Timestamp createdAt;

  // Definindo o construtor da classe com parâmetros nomeados
  QuestionModel({
    required this.authorId,
    this.authorEmail,
    required this.text,
    required this.visibility,
    this.answer,
    this.answeredAt,
    required this.createdAt
  });

  /// Método toMap() - Retorna um Map/objeto contendo as informações de uma pergunta
  Map<String, dynamic> toMap(){
    // Criando um map com os campos obrigatórios
    final map = <String, dynamic>{
      'authorId': authorId,
      'text': text,
      // .name converte o Enum para "publica" ou "privada"
      'visibility': visibility.name,
      'createdAt': createdAt,
    };

    // Se os campos adicionais não forem nulos, são adicionados ao map
    // (isso evita que o Firestore receba campos com dados vazios)
    if (authorEmail != null) map['authorEmail'] = authorEmail;
    if (answer != null) map['answer'] = answer;
    if (answeredAt != null) map['answeredAt'] = answeredAt;

    return map;
  }

  /// Retorna apenas os dados necessários para a chamada HTTPS Callable.
  /// Remove campos que o servidor gera sozinho (como datas).
  Map<String, dynamic> toCallableMap() {
    return {
      'text': text,
      'visibility': visibility.name,
    };
  }
  
  // Criando um construtor factory para converter os dados do map criado pelo método toMap()
  /// factory fromMap() - converte o [map] que o Firestore devolve em um objeto UserModel
  /// com dados devidamente tratados, fazendo com que, se seus dados forem inexistentes/nulos,
  /// ele os substitui por Strings vazias ou campos nulos sem precisar criar uma nova instância para isso.
  factory QuestionModel.fromMap(Map<String, dynamic> map) {
    return QuestionModel(
      authorId: map['authorId'] ?? '',
      authorEmail: map['authorEmail'] ?? '',
      text: map['text'] ?? '',
      // Usando o helper para converter a String que vem do banco para o Enum
      visibility: QuestionVisibility.fromString(map['visibility'] ?? 'publica'),
      answer: map['answer'] ?? '',
      answeredAt: map['answeredAt'] as Timestamp?,
      createdAt: map['createdAt'] as Timestamp
    );
  }
}
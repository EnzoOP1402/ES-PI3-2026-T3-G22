/* Autor: Enzo Olivato Pazian */

// Arquivo contendo as exceções autorais do projeto

// Um arquivo simples chamado app_exception.dart ou dentro do repositório
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}
/* Autor: Enzo Olivato Pazian - 25001654 */

// Exceção para problemas de autenticação
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}
// RESPONSÁVEL: Gabriela Sichiroli Ferrari (RA 25013763)
// HISTÓRICO DE ALTERAÇÕES
// 02/11/2026 — Criação: valida e normaliza o envelope dos retornos de Cloud Functions.

/// Aceita {campo: valor} e {data: {campo: valor}}.
/// Retorno malformado gera erro explícito, nunca saldo fictício.
Map<String, dynamic> cloudFunctionDataMap(dynamic raw) {
  if (raw is! Map) {
    throw const FormatException('Resposta inválida da API: era esperado um objeto.');
  }
  final topLevel = Map<String, dynamic>.from(raw);
  final nested = topLevel['data'];
  if (nested is Map) return Map<String, dynamic>.from(nested);
  return topLevel;
}

int requiredIntegerField(Map<String, dynamic> data, String field) {
  final value = data[field];
  if (value is int) return value;
  if (value is num && value.isFinite && value == value.roundToDouble()) {
    return value.toInt();
  }
  if (value is String) {
    final parsed = int.tryParse(value);
    if (parsed != null) return parsed;
  }
  throw FormatException('Campo obrigatório inválido: $field');
}

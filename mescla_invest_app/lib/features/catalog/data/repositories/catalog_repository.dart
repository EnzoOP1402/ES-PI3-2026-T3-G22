// RESPONSÁVEL: Gabriela Sichiroli Ferrari (RA 25013763)
// HISTÓRICO DE ALTERAÇÕES
// 02/11/2026 — Criação: API do catálogo centralizada e injetável.
import 'package:mescla_invest_app/core/services/cloud_functions_client.dart';

class CatalogRepository {
  CatalogRepository({CloudFunctionsClient? functions})
      : _functions = functions ?? CloudFunctionsClient();

  final CloudFunctionsClient _functions;

  Future<dynamic> listStartups(Map<String, dynamic> filters) async {
    final result = await _functions.callable('listStartups').call(filters);
    return result.data;
  }

  Future<dynamic> getStartupDetails(String id) async {
    final result = await _functions.callable('getStartupDetails').call({'id': id});
    return result.data;
  }

  Future<void> createStartupQuestion(Map<String, dynamic> payload) async {
    await _functions.callable('createStartupQuestion').call(payload);
  }
}

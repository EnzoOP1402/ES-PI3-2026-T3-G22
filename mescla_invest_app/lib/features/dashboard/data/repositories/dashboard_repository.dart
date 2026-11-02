// RESPONSÁVEL: Gabriela Sichiroli Ferrari (RA 25013763)
// HISTÓRICO DE ALTERAÇÕES
// 02/11/2026 — Criação: extrai chamadas Firebase da tela, permitindo teste com cliente injetado.
import 'package:mescla_invest_app/core/services/cloud_functions_client.dart';

class DashboardRepository {
  DashboardRepository({CloudFunctionsClient? functions})
      : _functions = functions ?? CloudFunctionsClient();

  final CloudFunctionsClient _functions;

  Future<List<dynamic>> getDashboard({
    required String period,
    required String searchQuery,
  }) async {
    final result = await _functions.callable('getUserDashboardData').call({
      'period': period,
      'searchQuery': searchQuery,
    });
    final raw = result.data;
    if (raw is List) return raw;
    if (raw is Map && raw['data'] is List) {
      return raw['data'] as List;
    }
    throw const FormatException('Formato inválido no retorno do dashboard.');
  }

  // A autorização também deve ser validada pela Cloud Function no servidor.
  Future<void> seedHistoricalData() async {
    await _functions.callable('seedHistoricalData').call();
  }
}

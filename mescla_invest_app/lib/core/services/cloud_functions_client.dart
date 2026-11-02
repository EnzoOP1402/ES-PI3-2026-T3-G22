// RESPONSÁVEL: Gabriela Sichiroli Ferrari (RA 25013763)
// HISTÓRICO DE ALTERAÇÕES
// 02/11/2026 — Criação: encapsula a região das Cloud Functions e permite injeção para testes.
import 'package:cloud_functions/cloud_functions.dart';
import 'package:mescla_invest_app/core/config/app_config.dart';

class CloudFunctionsClient {
  CloudFunctionsClient({FirebaseFunctions? functions})
      : _functions = functions ?? FirebaseFunctions.instanceFor(
          region: AppConfig.functionsRegion,
        );

  final FirebaseFunctions _functions;

  HttpsCallable callable(String functionName) =>
      _functions.httpsCallable(functionName);
}

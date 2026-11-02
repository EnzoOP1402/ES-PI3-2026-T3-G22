// RESPONSÁVEL: Gabriela Sichiroli Ferrari (RA 25013763)
// 02/11/2026 — Testes unitários para contratos de resposta e campos monetários.
import 'package:flutter_test/flutter_test.dart';
import 'package:mescla_invest_app/core/utils/cloud_function_data.dart';

void main() {
  group('cloudFunctionDataMap', () {
    test('preserva um objeto sem envelope', () {
      expect(cloudFunctionDataMap({'balanceAvailableCents': 400}),
          {'balanceAvailableCents': 400});
    });
    test('extrai o envelope data', () {
      expect(cloudFunctionDataMap({'data': {'balanceAvailableCents': 400}}),
          {'balanceAvailableCents': 400});
    });
    test('rejeita corpo malformado', () {
      expect(() => cloudFunctionDataMap('erro'), throwsFormatException);
    });
  });

  group('requiredIntegerField', () {
    test('aceita saldo zero legítimo', () {
      expect(requiredIntegerField({'balance': 0}, 'balance'), 0);
    });
    test('aceita representação textual inteira', () {
      expect(requiredIntegerField({'balance': '305'}, 'balance'), 305);
    });
    test('não inventa saldo quando o campo está ausente', () {
      expect(() => requiredIntegerField({}, 'balance'), throwsFormatException);
    });
    test('rejeita centavos fracionários', () {
      expect(() => requiredIntegerField({'balance': 2.75}, 'balance'),
          throwsFormatException);
    });
  });
}

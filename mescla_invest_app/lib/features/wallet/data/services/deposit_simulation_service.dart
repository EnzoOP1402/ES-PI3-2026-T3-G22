// HISTÓRICO: 02/11/2026 — Gabriela Sichiroli Ferrari: confirmação explícita e teste por injeção.
// APENAS AMBIENTE DEMO: um app de produção NUNCA deve creditar via clique do usuário.
// Usar webhook de pagamento verificado no servidor, confirmação e idempotência.
import 'package:mescla_invest_app/features/wallet/data/repositories/wallet_repository.dart';

typedef CreditBalance = Future<void> Function(int amountCents);

class DepositSimulationService {
  DepositSimulationService({CreditBalance? credit})
      : _credit = credit ?? WalletRepository.instance.addBalance;
  final CreditBalance _credit;

  Future<void> confirmDemoPayment(int amountCents) async {
    if (amountCents <= 0) throw ArgumentError.value(amountCents, 'amountCents');
    await _credit(amountCents);
  }
}

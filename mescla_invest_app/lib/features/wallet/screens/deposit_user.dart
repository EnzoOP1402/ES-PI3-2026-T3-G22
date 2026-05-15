import 'package:flutter/material.dart';
import 'package:mescla_invest_app/features/catalog/presentation/screens/startup_catalog_screen.dart';
import 'package:mescla_invest_app/features/wallet/screens/write_value.dart';
import 'package:mescla_invest_app/features/wallet/theme/background_wallet.dart';

class WalletUser extends StatefulWidget {
  final String valor;

  const WalletUser({super.key, required this.valor});

  @override
  State<WalletUser> createState() => _WalletUserState();
}

class _WalletUserState extends State<WalletUser> {
  int? _selectedPayment;

  @override
  Widget build(BuildContext context) {
    return BackgroundWallet(
      onBackPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                width: 320,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFDEDEDE),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cancelar investimento',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Se você sair, todos os dados preenchidos serão perdidos.',
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tem certeza que deseja sair?',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.end, // Alinha os botões à direita
                      children: [
                        // Botão "Sim"
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const Catalogo(),
                              ),
                            );
                          },
                          child: Container(
                            width: 90,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(
                                color: const Color(0xFF353988),
                                width: 3,
                              ),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: const Center(
                              child: Text(
                                'Sim',
                                style: TextStyle(
                                  color: Color(0xFF353988),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 12,
                        ), // Espaço cirúrgico entre os dois botões
                        // Botão "Não"
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 90,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFDB0065),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: const Center(
                              child: Text(
                                'Não',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Escolha a forma de\npagamento',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 45),

            // PIX
            GestureDetector(
              onTap: () => setState(() => _selectedPayment = 1),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFCCCCCC),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: _selectedPayment == 1
                        ? const Color(0xFF353988)
                        : Colors.transparent,
                    width: 2.5,
                  ),
                ),
                child: Row(
                  children: [
                    Image.asset('images/pix_logo.png', width: 40),
                    const SizedBox(width: 14),
                    const Expanded(child: Text("Pix powered by Banco Central")),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // TED
            GestureDetector(
              onTap: () => setState(() => _selectedPayment = 2),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFCCCCCC),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: _selectedPayment == 2
                        ? const Color(0xFF353988)
                        : Colors.transparent,
                    width: 2.5,
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.compare_arrows_rounded, size: 34),
                    SizedBox(width: 14),
                    Expanded(
                      child: Text("Transferência Eletrônica Disponível"),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 38),

            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: _selectedPayment == null
                    ? null
                    : () {
                        if (_selectedPayment == 1) {
                          // PIX
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const WriteValue(selectedPayment: 1),
                            ),
                          );
                        } else if (_selectedPayment == 2) {
                          // TED
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const WriteValue(selectedPayment: 2),
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedPayment == null
                      ? Colors.grey
                      : const Color(0xFF353988),
                ),
                child: const Text(
                  'Escolher',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

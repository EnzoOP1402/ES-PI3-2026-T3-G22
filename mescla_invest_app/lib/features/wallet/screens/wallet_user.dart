import 'package:mescla_invest_app/features/wallet/theme/background_wallet.dart';
import 'package:flutter/material.dart';
import 'package:mescla_invest_app/features/catalog/presentation/screens/startup_catalog_screen.dart';

class MesclaInvest extends StatelessWidget {
  // Construtor da aplicação (herda o atributo key de sua superclasse)
  const MesclaInvest({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(debugShowCheckedModeBanner: false);
  }
}

class WalletUser extends StatefulWidget {
  const WalletUser({super.key});

  @override
  State<WalletUser> createState() => _WalletUserState();
}

class _WalletUserState extends State<WalletUser> {
  int? _selectedPayment; // 1 = Pix | 2 = TED

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
                width: 260,
                height: 240,
                decoration: BoxDecoration(
                  color: Color(0xFFDEDEDE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Deseja cancelar seu\ndepósito?',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.black87),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context); // fecha dialog
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Catalogo(),
                              ),
                            );
                          },
                          child: Container(
                            width: 100,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Color(0xFFDEDEDE),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Center(
                              child: Text(
                                'Sim',
                                style: TextStyle(
                                  color: Color(0xFFDB0065),
                                  fontSize: 22,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: 100,
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFF353988),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Center(
                              child: Text(
                                'Não',
                                style: TextStyle(
                                  color: Color(0xFFDEDEDE),
                                  fontSize: 22,
                                  fontWeight: FontWeight.w400,
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
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 45),

            // PIX
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPayment = 1;
                });
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: Color(0xFFCCCCCC),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: _selectedPayment == 1
                        ? Color(0xFF353988)
                        : Colors.transparent,
                    width: 2.5,
                  ),
                ),
                child: Row(
                  children: [
                    Image.asset('images/pix_logo.png', width: 40, height: 40),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        'Pix powered by Banco Central',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // TED
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPayment = 2;
                });
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: Color(0xFFCCCCCC),
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
                    Icon(
                      Icons.compare_arrows_rounded,
                      size: 34,
                      color: Color(0xFF353988),
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Transferência Eletrônica Disponível',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 38),

            // BOTÃO ESCOLHER
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: _selectedPayment == null
                    ? null
                    : () {
                        if (_selectedPayment == 1) {
                          // Pix
                        } else if (_selectedPayment == 2) {
                          // TED
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedPayment == null
                      ? Colors.grey
                      : const Color(0xFF353988),
                  disabledBackgroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text(
                  'Escolher',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

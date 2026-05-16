import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mescla_invest_app/features/catalog/presentation/screens/startup_catalog_screen.dart';
import 'package:mescla_invest_app/features/wallet/theme/background_wallet.dart';
import 'package:mescla_invest_app/features/wallet/screens/ted_pay.dart';
import 'package:mescla_invest_app/features/wallet/screens/qrcode_pix.dart';

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
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
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

                        const SizedBox(width: 12),

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Escolha a forma de pagamento',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.w900,
                color: Color(0xFF353988),
              ),
            ),

            const SizedBox(height: 45),

            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPayment = 1;
                });
              },
              child: SizedBox(
                height: 90,
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
                      const Expanded(
                        child: Text("Pix powered by Banco Central"),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPayment = 2;
                });
              },
              child: SizedBox(
                height: 90,
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
            ),

            const SizedBox(height: 38),

            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: _selectedPayment == null
                    ? null
                    : () {
                        _showValueModal();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedPayment == null
                      ? Colors.grey
                      : const Color(0xFF353988),
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

  void _showValueModal() {
    final TextEditingController valueController = TextEditingController();

    void formatCurrency(String value) {
      final numbersOnly = value.replaceAll(RegExp(r'[^0-9]'), '');

      if (numbersOnly.isEmpty) {
        valueController.value = const TextEditingValue(
          text: '',
          selection: TextSelection.collapsed(offset: 0),
        );
        return;
      }

      final number = double.parse(numbersOnly) / 100;

      final formatted = number.toStringAsFixed(2).replaceAll('.', ',');

      valueController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(modalContext).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            decoration: const BoxDecoration(
              color: Color(0xFFE2E2E2),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                const SizedBox(height: 22),

                Text(
                  _selectedPayment == 1
                      ? 'Digite o valor do PIX'
                      : 'Digite o valor da TED',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF353988),
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  _selectedPayment == 1
                      ? 'Informe quanto deseja depositar via PIX'
                      : 'Informe quanto deseja depositar via TED',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, color: Colors.black54),
                ),

                const SizedBox(height: 28),

                TextField(
                  controller: valueController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF000000),
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(
                        left: 18,
                        right: 15,
                        top: 0,
                        bottom: 0,
                      ),
                      child: Center(
                        widthFactor: 1.0,
                        child: Text(
                          'R\$ |',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 0,
                      minHeight: 0,
                    ),
                    hintText: '0,00',
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 34,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: formatCurrency,
                ),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: () {
                      final valor = valueController.text.trim();

                      if (valor.isEmpty || valor == '0,00') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Digite um valor válido para depósito',
                            ),
                            backgroundColor: Color(0xFFCF0000),
                          ),
                        );
                        return;
                      }

                      Navigator.pop(modalContext);

                      if (_selectedPayment == 1) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => Qrcode(valor: valor),
                          ),
                        );
                      } else if (_selectedPayment == 2) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => Tedpay(valor: valor),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF353988),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      'Continuar',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }
}

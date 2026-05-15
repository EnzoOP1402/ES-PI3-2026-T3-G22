import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mescla_invest_app/features/wallet/screens/ted_pay.dart';
import 'package:mescla_invest_app/features/wallet/screens/qrcode_pix.dart';
import 'package:mescla_invest_app/features/catalog/presentation/screens/startup_catalog_screen.dart';
import 'package:mescla_invest_app/features/wallet/theme/background_wallet.dart';

class WriteValue extends StatefulWidget {
  final int selectedPayment;

  const WriteValue({super.key, required this.selectedPayment});

  @override
  State<WriteValue> createState() => _WriteValueState();
}

class _WriteValueState extends State<WriteValue> {
  final TextEditingController _valueController = TextEditingController();

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  /// Ex: 1000 -> 10,00
  void _formatCurrency(String value) {
    final numbersOnly = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (numbersOnly.isEmpty) {
      _valueController.value = const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
      return;
    }

    final number = double.parse(numbersOnly) / 100;

    final formatted = number.toStringAsFixed(2).replaceAll('.', ',');

    _valueController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  void _confirmValue() {
    final valor = _valueController.text.trim();

    if (valor.isEmpty || valor == '0,00') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite um valor válido para depósito')),
      );
      return;
    }

    /// PIX
    if (widget.selectedPayment == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => Qrcode(valor: valor)),
      );
      return;
    }

    /// TED
    if (widget.selectedPayment == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => Tedpay(valor: valor)),
      );
      return;
    }
  }

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
              'Quanto você deseja depositar?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 40),

            TextField(
              controller: _valueController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Color(0xFF353988),
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: '0,00',
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 34),
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
              onChanged: _formatCurrency,
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: _confirmValue,
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
          ],
        ),
      ),
    );
  }
}

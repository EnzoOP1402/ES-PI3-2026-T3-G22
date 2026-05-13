import 'package:flutter/material.dart';
import 'package:mescla_invest_app/features/wallet/theme/background_wallet.dart';
import 'package:mescla_invest_app/features/wallet/screens/qrcode_pay.dart';
import 'package:mescla_invest_app/features/catalog/presentation/screens/startup_catalog_screen.dart';

class WriteValue extends StatefulWidget {
  const WriteValue({super.key});

  @override
  State<WriteValue> createState() => _WriteValueState();
}

class _WriteValueState extends State<WriteValue> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void mostrarDialogCancelar() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 260,
            height: 240,
            decoration: BoxDecoration(
              color: const Color(0xFFDEDEDE),
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
                        Navigator.pop(context);

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
                          color: const Color(0xFFDEDEDE),
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
                          color: Color(0xFF353988),
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
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWallet(
      onBackPressed: mostrarDialogCancelar,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Digite aqui o valor para depositar:',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 30),

                // CAMPO DE VALOR
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDEDED),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.grey, width: 2),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'R\$ |',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: TextField(
                          controller: _controller,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Valor desejado',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 140),

                // BOTÃO QR CODE
                SizedBox(
                  width: 230,
                  height: 70,
                  child: ElevatedButton(
                    onPressed: () {
                      String valor = _controller.text.replaceAll(',', '.');

                      if (valor.isNotEmpty && double.tryParse(valor) != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                Qrcode(valor: _controller.text),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Digite um valor numérico válido'),
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
                      'Gerar QR Code',
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

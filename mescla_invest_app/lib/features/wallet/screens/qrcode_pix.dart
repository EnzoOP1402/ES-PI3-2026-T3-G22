import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mescla_invest_app/features/wallet/theme/background_wallet.dart';
import 'package:mescla_invest_app/features/wallet/screens/pix_pay.dart';
import 'package:mescla_invest_app/features/catalog/presentation/screens/startup_catalog_screen.dart';

class Qrcode extends StatefulWidget {
  final String valor;

  const Qrcode({super.key, required this.valor});

  @override
  State<Qrcode> createState() => _QrcodeState();
}

class _QrcodeState extends State<Qrcode> {
  int tempoRestante = 600; // 10 minutos
  late Timer timer;
  int qrVersion = 1;

  String get chavePix => '000.000.000.0$qrVersion';

  String get qrData => 'PIX|VALOR:${widget.valor}|CHAVE:$chavePix';

  @override
  void initState() {
    super.initState();
    iniciarTimer();
  }

  void iniciarTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (tempoRestante > 0) {
        setState(() {
          tempoRestante--;
        });
      } else {
        gerarNovoQrCode();
      }
    });
  }

  void gerarNovoQrCode() {
    setState(() {
      qrVersion++;
      tempoRestante = 600;
    });
  }

  String formatarTempo(int segundos) {
    int minutos = segundos ~/ 60;
    int secs = segundos % 60;

    return '$minutos:${secs.toString().padLeft(2, '0')}';
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
                        timer.cancel();

                        Navigator.pop(context);

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Catalogo(),
                          ),
                          (route) => false,
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
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWallet(
      onBackPressed: mostrarDialogCancelar,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              children: [
                const SizedBox(height: 30),

                Text(
                  'Valor Total: R\$${widget.valor}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                const Text(
                  'Escaneie o QR Code para acessar a chave pix do seu saldo:',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),

                const SizedBox(height: 25),

                // QR CODE
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(12),
                  child: GestureDetector(
                    onTap: () async {
                      // Pausa timer
                      timer.cancel();

                      // Tela branca
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TelaBranca(valor: widget.valor),
                        ),
                      );

                      // Novo QR após pagamento
                      gerarNovoQrCode();

                      // Reinicia timer
                      iniciarTimer();
                    },
                    child: QrImageView(data: qrData, size: 200),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  'Chave Pix: $chavePix',
                  style: const TextStyle(fontSize: 16),
                ),

                const SizedBox(height: 35),

                Text(
                  'Tempo para o pagamento: ${formatarTempo(tempoRestante)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 20),

                // TROQUE apenas isso no final do código:
                GestureDetector(
                  onTap: mostrarDialogCancelar,
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.red, fontSize: 24),
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

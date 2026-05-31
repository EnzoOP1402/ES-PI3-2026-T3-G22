/* Autor: Bernardo Castro Brandão de Oliveira */
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mescla_invest_app/core/widgets/confirm_exit_dialog.dart';
import 'package:mescla_invest_app/core/widgets/custom_app_bar.dart';
import 'package:mescla_invest_app/features/wallet/presentation/screens/confirm.dart';
import 'package:mescla_invest_app/routes/app_routes.dart';
import 'package:qr_flutter/qr_flutter.dart';

class Qrcode extends StatefulWidget {
  final String valor;
  const Qrcode({super.key, required this.valor});
  @override
  State<Qrcode> createState() => _QrcodeState();
}

class _QrcodeState extends State<Qrcode> {
  int tempoRestante = 600; 
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
  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      appBar: CustomAppBar(
      title: 'Carteira',
      // Função executada ao clicar no botão de voltar.
      onBackPressed: () {
      showDialog(
        context: context,
        builder: (_) {
        return ConfirmExitDialog(
          title: 'Cancelar depósito',
          message:'Se você sair, todos os dados preenchidos serão perdidos.',
          question: 'Tem certeza que deseja sair?',
            onConfirm: () {
            Navigator.pop(context);
            Navigator.pushNamed(
            context,
            AppRoutes.wallet,
              );
            },
          );
        },
      );
    },
  ),
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

                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(12),
                  child: GestureDetector(
                    onTap: () async {
                      timer.cancel();
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SuccessScreen(valor: widget.valor),
                        ),
                      );
                      gerarNovoQrCode();
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

                SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => ConfirmExitDialog(
                          title: 'Cancelar depósito',
                          message:
                              'Se você sair, todos os dados preenchidos serão perdidos.',
                          question: 'Tem certeza que deseja sair?',
                          onConfirm: () {
                            Navigator.pop(context);

                            Navigator.pushNamed(
                              context,
                              AppRoutes.wallet,
                            );
                          },
                        ),
                      );
                    },
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 24,
                      ),
                    ),
                  ),
              ]
        ),
      ),
    )
    )
    );
  }
}

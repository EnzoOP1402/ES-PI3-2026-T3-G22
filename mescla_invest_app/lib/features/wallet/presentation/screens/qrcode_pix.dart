/* Autor: Bernardo Castro Brandão de Oliveira - RA: 25014953*/

// Importação da biblioteca responsável pelo gerenciamento de temporizadores
import 'dart:async';

// Importação do pacote principal do Flutter para construção da interface gráfica
import 'package:flutter/material.dart';

// Importação do diálogo de confirmação utilizado ao cancelar operações
import 'package:mescla_invest_app/core/widgets/confirm_exit_dialog.dart';

// Importação da AppBar personalizada utilizada no projeto
import 'package:mescla_invest_app/core/widgets/custom_app_bar.dart';

// Importação da tela de confirmação de depósito
import 'package:mescla_invest_app/features/wallet/presentation/screens/confirm.dart';

// Importação das rotas da aplicação
import 'package:mescla_invest_app/routes/app_routes.dart';

// Importação da biblioteca responsável pela geração de QR Codes
import 'package:qr_flutter/qr_flutter.dart';

// Tela responsável pela exibição do QR Code PIX
class Qrcode extends StatefulWidget {
  // Valor informado pelo usuário para depósito
  final String valor;

  // Construtor da tela
  const Qrcode({super.key, required this.valor});

  // Cria o estado associado ao widget
  @override
  State<Qrcode> createState() => _QrcodeState();
}

// Classe responsável pelo gerenciamento dos estados da tela
class _QrcodeState extends State<Qrcode> {
  // Tempo restante para validade do QR Code em segundos
  int tempoRestante = 600;

  // Temporizador responsável pela contagem regressiva
  late Timer timer;

  // Controla a versão atual do QR Code gerado
  int qrVersion = 1;

  // Chave PIX simulada utilizada para compor os dados do QR Code
  String get chavePix => '000.000.000.0$qrVersion';

  // Dados codificados dentro do QR Code
  String get qrData => 'PIX|VALOR:${widget.valor}|CHAVE:$chavePix';

  // Método executado automaticamente quando a tela é criada
  @override
  void initState() {
    super.initState();

    // Inicia a contagem regressiva do QR Code
    iniciarTimer();
  }

  // Método responsável por iniciar o temporizador
  void iniciarTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Enquanto houver tempo disponível, reduz um segundo
      if (tempoRestante > 0) {
        setState(() {
          tempoRestante--;
        });
      } else {
        // Quando o tempo expira, gera um novo QR Code
        gerarNovoQrCode();
      }
    });
  }

  // Método responsável por gerar uma nova versão do QR Code
  void gerarNovoQrCode() {
    setState(() {
      // Incrementa a versão da chave PIX
      qrVersion++;

      // Reinicia o contador de validade
      tempoRestante = 600;
    });
  }

  // Método responsável por converter segundos para o formato MM:SS
  String formatarTempo(int segundos) {
    int minutos = segundos ~/ 60;
    int secs = segundos % 60;

    return '$minutos:${secs.toString().padLeft(2, '0')}';
  }

  // Método executado quando o widget é removido da árvore de widgets
  @override
  void dispose() {
    // Cancela o temporizador para evitar consumo desnecessário de recursos
    timer.cancel();
    super.dispose();
  }

  // Método responsável pela construção da interface gráfica
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Cor de fundo da tela
      backgroundColor: const Color(0xFFF3F3F3),
      appBar: CustomAppBar(
        title: 'Carteira',
        // Função executada ao clicar no botão de voltar.
        onBackPressed: () {
          showDialog(
            context: context,
            builder: (_) {
              return ConfirmExitDialog(
                // Título do diálogo
                title: 'Cancelar depósito',

                // Mensagem informativa
                message:
                    'Se você sair, todos os dados preenchidos serão perdidos.',

                // Pergunta de confirmação
                question: 'Tem certeza que deseja sair?',

                // Ação executada ao confirmar
                onConfirm: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.wallet);
                },
              );
            },
          );
        },
      ),

      // Conteúdo principal da tela
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              children: [
                const SizedBox(height: 30),

                // Exibe o valor total do depósito
                Text(
                  'Valor Total: R\$${widget.valor}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                // Instrução para utilização do QR Code
                const Text(
                  'Escaneie o QR Code para acessar a chave pix do seu saldo:',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),

                const SizedBox(height: 25),

                // Container responsável pela exibição do QR Code
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(12),
                  child: GestureDetector(
                    // Simula a confirmação do pagamento ao tocar no QR Code
                    onTap: () async {
                      // Interrompe a contagem regressiva
                      timer.cancel();

                      // Navega para a tela de sucesso
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SuccessScreen(valor: widget.valor),
                        ),
                      );

                      // Gera um novo QR Code ao retornar
                      gerarNovoQrCode();

                      // Reinicia o temporizador
                      iniciarTimer();
                    },

                    // Widget responsável pela renderização do QR Code
                    child: QrImageView(data: qrData, size: 200),
                  ),
                ),

                const SizedBox(height: 20),

                // Exibe a chave PIX associada ao QR Code
                Text(
                  'Chave Pix: $chavePix',
                  style: const TextStyle(fontSize: 16),
                ),

                const SizedBox(height: 35),

                // Exibe o tempo restante de validade do QR Code
                Text(
                  'Tempo para o pagamento: ${formatarTempo(tempoRestante)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                SizedBox(height: 20),

                // Botão responsável por cancelar a operação
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => ConfirmExitDialog(
                        // Título exibido no diálogo
                        title: 'Cancelar depósito',

                        // Mensagem informativa
                        message:
                            'Se você sair, todos os dados preenchidos serão perdidos.',

                        // Pergunta de confirmação
                        question: 'Tem certeza que deseja sair?',

                        // Ação executada ao confirmar o cancelamento
                        onConfirm: () {
                          Navigator.pop(context);

                          Navigator.pushNamed(context, AppRoutes.wallet);
                        },
                      ),
                    );
                  },
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

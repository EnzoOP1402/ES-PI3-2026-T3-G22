import 'package:flutter/material.dart';
import 'package:mescla_invest_app/features/wallet/screens/confirm.dart';
import 'package:mescla_invest_app/features/wallet/theme/background_wallet.dart';
import 'package:mescla_invest_app/features/catalog/presentation/screens/startup_catalog_screen.dart';

class Tedpay extends StatefulWidget {
  final String valor;

  const Tedpay({super.key, required this.valor});

  @override
  State<Tedpay> createState() => _TedpayState();
}

class _TedpayState extends State<Tedpay> {
  final TextEditingController _comprovanteController = TextEditingController();

  @override
  void dispose() {
    _comprovanteController.dispose();
    super.dispose();
  }

  void _confirmarTed() {
    // Aqui depois você pode integrar com Firebase Function
    // criarDepositoTED(valor, comprovante)

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SuccessScreen(valor: widget.valor),
      ),
    );
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

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            const Text(
              'Transfira o valor para a conta abaixo:',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 28),

            // Dados bancários
            _infoCard(titulo: 'Banco', valor: '237 - Bradesco'),

            _infoCard(titulo: 'Agência', valor: '1234'),

            _infoCard(titulo: 'Conta', valor: '56789-0'),

            _infoCard(titulo: 'CNPJ', valor: '12.345.678/0001-99'),

            _infoCard(titulo: 'Valor da TED', valor: 'R\$ ${widget.valor}'),

            const SizedBox(height: 30),

            const Text(
              'Após realizar a TED no seu banco, informe o comprovante para agilizar a validação.',
              style: TextStyle(color: Colors.black87, fontSize: 13),
            ),
            // Comprovante
            TextField(
              controller: _comprovanteController,
              decoration: InputDecoration(
                labelText: 'Código / comprovante da TED (opcional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 14),

            const SizedBox(height: 35),

            // Botão confirmar
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _confirmarTed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF353988),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Confirmar TED',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard({required String titulo, required String valor}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEAEAEA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            valor,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

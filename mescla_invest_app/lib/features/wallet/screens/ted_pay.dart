/* Autor: Bernardo Castro Brandão de Oliveira */

import 'package:flutter/material.dart';
import 'package:mescla_invest_app/features/wallet/screens/confirm.dart';
import 'package:mescla_invest_app/features/wallet/theme/background_wallet.dart';
import 'package:mescla_invest_app/features/catalog/presentation/screens/startup_catalog_screen.dart';
import 'package:flutter/services.dart';

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

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Transfira o valor para a conta abaixo:',
              style: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.w900,
                color: Color(0xFF353988),
              ),
            ),

            const SizedBox(height: 28),

            _infoCard(titulo: 'Banco', valor: '237 - Bradesco'),

            _infoCard(titulo: 'Agência', valor: '1234'),

            _infoCard(titulo: 'Conta', valor: '56789-0'),

            _infoCard(titulo: 'CNPJ', valor: '12.345.678/0001-99'),

            _infoCard(titulo: 'Valor da TED', valor: 'R\$ ${widget.valor}'),

            const SizedBox(height: 30),

            const Text(
              'Após realizar a TED no seu banco, informe o comprovante para agilizar a validação:',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _comprovanteController,
              decoration: InputDecoration(
                labelText: 'Código / comprovante da TED (opcional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                filled: true,
                fillColor: Color(0xFFF4F4F4),
              ),
            ),

            const SizedBox(height: 14),

            const SizedBox(height: 35),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5B5FEF),Color(0xFF353988)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ElevatedButton(
                  onPressed: _confirmarTed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
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
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8E8E8E),
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: valor));

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$titulo copiado (a) com sucesso!'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.copy_rounded, color: Color(0xFF353988)),
            tooltip: 'Copiar $titulo',
          ),
        ],
      ),
    );
  }
}

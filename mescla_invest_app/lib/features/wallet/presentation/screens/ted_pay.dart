/* Autor: Bernardo Castro Brandão de Oliveira */

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mescla_invest_app/core/widgets/confirm_exit_dialog.dart';
import 'package:mescla_invest_app/core/widgets/custom_app_bar.dart';
import 'package:mescla_invest_app/features/wallet/presentation/screens/confirm.dart';
import 'package:flutter/services.dart';
import 'package:mescla_invest_app/routes/app_routes.dart';

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
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transfira o valor para a conta abaixo:',
              style: GoogleFonts.montserrat(
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
            Text(
              'Após realizar a TED no seu banco, informe o comprovante para agilizar a validação:',
              style: GoogleFonts.montserrat(
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
                  child: Text(
                    'Confirmar TED',
                    style: GoogleFonts.montserrat(fontSize: 18, color: Colors.white),
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
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: Color(0xFF8E8E8E),
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  valor,
                  style: GoogleFonts.montserrat(
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

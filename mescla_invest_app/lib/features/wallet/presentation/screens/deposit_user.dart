/* Autor: Bernardo Castro Brandão de Oliveira - RA: 25014953*/

// Importa o pacote principal do Flutter com widgets visuais(Text, Collumn, etc)
import 'package:flutter/material.dart';

// Importa formatadores de entrada de texto, usado para verificar se o
//usuario digitou números no campo de valor a ser deposistado.
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mescla_invest_app/core/utils/snackbar_utils.dart';
import 'package:mescla_invest_app/core/widgets/custom_app_bar.dart';
// Importa a tela de pagamento via TED.
import 'package:mescla_invest_app/features/wallet/presentation/screens/ted_pay.dart';

// Importa a tela de pagamento via QR Code PIX.
import 'package:mescla_invest_app/features/wallet/presentation/screens/qrcode_pix.dart';

import 'package:mescla_invest_app/features/wallet/data/repositories/wallet_repository.dart';
import 'package:mescla_invest_app/core/widgets/confirm_exit_dialog.dart';
import 'package:mescla_invest_app/routes/app_routes.dart';

// StatefulWidget porque a interface muda dinamicamente
class WalletUser extends StatefulWidget {
  // Valor recebido da tela anterior.
  final String valor;

  // Construtor exigindo valor obrigatório.
  const WalletUser({super.key, required this.valor});

  // Liga o widget à sua classe de estado mutável.
  @override
  State<WalletUser> createState() => _WalletUserState();
}

// Classe de estado da tela WalletUser.
class _WalletUserState extends State<WalletUser> {
  // Armazena qual método de pagamento foi escolhido (Pix ou Ted)
  int? _selectedPayment;

  // Método principal que constrói a interface.
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
                message:
                    'Se você sair, todos os dados preenchidos serão perdidos.',
                question: 'Tem certeza que deseja sair?',
                onConfirm: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.wallet);
                },
              );
            },
          );
        },
      ),
      // Conteúdo principal da tela.
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // Título principal
            Text(
              'Escolha a forma de pagamento',
              style: GoogleFonts.montserrat(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF353988),
              ),
            ),

            const SizedBox(height: 45),

            // Opção PIX
            GestureDetector(
              onTap: () {
                // Atualiza visualmente a opção selecionada.
                setState(() {
                  _selectedPayment = 1;
                });
              },

              child: SizedBox(
                width: 380,
                height: 90,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                    // Borda aparece se selecionado.
                    border: Border.all(
                      color: _selectedPayment == 1
                          ? const Color(0xFF353988)
                          : Colors.transparent,
                      width: 2.5,
                    ),
                  ),

                  child: Row(
                    children: [
                      // Logo do PIX
                      Image.asset('assets/images/pix_logo.png', width: 50),
                      const SizedBox(width: 10),

                      // Texto expansível
                      Expanded(
                        child: Text(
                          "Pix powered by Banco Central",
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Opção TED
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: _selectedPayment == 2
                          ? const Color(0xFF353988)
                          : Colors.transparent,
                      width: 2.5,
                    ),
                  ),

                  child: Row(
                    children: [
                      // Ícone de transferência
                      Icon(Icons.compare_arrows_rounded, size: 34),
                      SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          "Transferência Eletrônica Disponível",
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 38),

            //Botão Escolher
            SizedBox(
              width: double.infinity,
              height: 58,

              child: Container(
                // Gradiente só aparece se houver seleção.
                decoration: BoxDecoration(
                  gradient: _selectedPayment == null
                      ? null
                      : const LinearGradient(
                          colors: [Color(0xFF5B5FEF), Color(0xFF353988)],
                        ),

                  borderRadius: BorderRadius.circular(16),
                ),

                child: ElevatedButton(
                  // Desabilita se nada foi escolhido.
                  onPressed: _selectedPayment == null
                      ? null
                      : () {
                          _showValueModal();
                        },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),

                  child: Text(
                    'Escolher',
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Modal para digitar o valor a ser depositado
  void _showValueModal() {
    // Controla texto digitado.
    final TextEditingController valueController = TextEditingController();

    // Função que verifica se é número.

    void formatCurrency(String value) {
      // Remove tudo que não for número.
      final numbersOnly = value.replaceAll(RegExp(r'[^0-9]'), '');

      // Se vazio, limpa.
      if (numbersOnly.isEmpty) {
        valueController.value = const TextEditingValue(
          text: '',
          selection: TextSelection.collapsed(offset: 0),
        );
        return;
      }

      // Divide por 100 para centavos.
      final number = double.parse(numbersOnly) / 100;

      // Formata decimal.
      final formatted = number.toStringAsFixed(2).replaceAll('.', ',');

      // Atualiza campo.
      valueController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }

    //Estilo do modal
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
            color: Color(0xFFE2E2E2),

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

                //Mecanismo que muda o texto do modal
                Text(
                  _selectedPayment == 1
                      //Texto ser for PIX
                      ? 'Digite o valor do PIX'
                      //Texto ser for TED
                      : 'Digite o valor da TED',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF353988),
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  _selectedPayment == 1
                      //Texto ser for PIX
                      ? 'Informe quanto deseja depositar via PIX'
                      //Texto ser for TED
                      : 'Informe quanto deseja depositar via TED',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 28),
                //Estilo do campo de texto (valor)
                TextField(
                  controller: valueController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.left,
                  style: GoogleFonts.montserrat(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF000000),
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    prefixIcon: Padding(
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
                          style: GoogleFonts.montserrat(
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
                    hintStyle: GoogleFonts.montserrat(
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
                  child: Container(
                    //Inclusão do Gradiente para estilo do texto
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF5B5FEF), Color(0xFF353988)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        final valor = valueController.text.trim();
                        if (valor.isEmpty || valor == '0,00') {
                          showErrorSnackBar(
                            context,
                            'Digite um valor válido para depósito',
                          );
                          return;
                        }

                        try {
                          final double valorDigitado =
                              double.tryParse(
                                valor.replaceAll('.', '').replaceAll(',', '.'),
                              ) ??
                              0.0;

                          final int amountCents = (valorDigitado * 100).round();
                          await WalletRepository.instance.addBalance(
                            amountCents,
                          );

                          if (!mounted) return;

                          Navigator.pop(modalContext);

                          showSuccessSnackBar(
                            context,
                            'Saldo adicionado com sucesso!',
                          );

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
                        } catch (e) {
                          if (!mounted) return;

                          showErrorSnackBar(context, e.toString());
                        }
                      },
                      //Botão Continuar
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(
                        'Continuar',
                        style: GoogleFonts.montserrat(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
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

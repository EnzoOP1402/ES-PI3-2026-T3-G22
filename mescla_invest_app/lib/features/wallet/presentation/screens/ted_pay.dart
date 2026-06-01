/* Autor: Bernardo Castro Brandão de Oliveira - RA: 25014953*/

// Importação do pacote principal do Flutter para construção da interface gráfica
import 'package:flutter/material.dart';

// Importação da biblioteca de fontes personalizadas
import 'package:google_fonts/google_fonts.dart';

// Importação do diálogo de confirmação utilizado ao sair da tela
import 'package:mescla_invest_app/core/widgets/confirm_exit_dialog.dart';

// Importação da AppBar personalizada utilizada no projeto
import 'package:mescla_invest_app/core/widgets/custom_app_bar.dart';

// Importação da tela de confirmação de depósito
import 'package:mescla_invest_app/features/wallet/presentation/screens/confirm.dart';

// Importação utilizada para acesso à área de transferência (Clipboard)
import 'package:flutter/services.dart';

// Importação das rotas da aplicação
import 'package:mescla_invest_app/routes/app_routes.dart';

// Tela responsável pela exibição dos dados bancários para depósito via TED
class Tedpay extends StatefulWidget {
  // Valor informado pelo usuário na tela anterior
  final String valor;

  // Construtor da tela
  const Tedpay({super.key, required this.valor});

  // Cria o estado associado ao widget
  @override
  State<Tedpay> createState() => _TedpayState();
}

// Classe responsável pelo gerenciamento dos estados da tela
class _TedpayState extends State<Tedpay> {
  // Controlador responsável pelo campo de comprovante da TED
  final TextEditingController _comprovanteController = TextEditingController();

  // Método chamado quando o widget é removido da árvore de widgets
  // Responsável por liberar recursos utilizados pela tela
  @override
  void dispose() {
    // Libera o controlador do campo de comprovante
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

  // Método responsável pela construção da interface gráfica
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Cor de fundo da tela
      backgroundColor: const Color(0xFFF3F3F3),

      // Barra superior personalizada
      appBar: CustomAppBar(
        title: 'Carteira',
        // Função executada ao clicar no botão de voltar.
        onBackPressed: () {
          showDialog(
            context: context,
            builder: (_) {
              return ConfirmExitDialog(
                // Título exibido no diálogo
                title: 'Cancelar depósito',

                // Mensagem informativa
                message:
                    'Se você sair, todos os dados preenchidos serão perdidos.',

                // Pergunta de confirmação
                question: 'Tem certeza que deseja sair?',

                // Ação executada caso o usuário confirme a saída
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
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título principal da página
            Text(
              'Transfira o valor para a conta abaixo:',
              style: GoogleFonts.montserrat(
                fontSize: 35,
                fontWeight: FontWeight.w900,
                color: Color(0xFF353988),
              ),
            ),

            const SizedBox(height: 28),

            // Cartão contendo o banco destinatário
            _infoCard(titulo: 'Banco', valor: '237 - Bradesco'),

            // Cartão contendo a agência bancária
            _infoCard(titulo: 'Agência', valor: '1234'),

            // Cartão contendo a conta bancária
            _infoCard(titulo: 'Conta', valor: '56789-0'),

            // Cartão contendo o CNPJ do destinatário
            _infoCard(titulo: 'CNPJ', valor: '12.345.678/0001-99'),

            // Cartão contendo o valor informado pelo usuário
            _infoCard(titulo: 'Valor da TED', valor: 'R\$ ${widget.valor}'),
            const SizedBox(height: 30),

            // Texto explicativo sobre o envio do comprovante
            Text(
              'Após realizar a TED no seu banco, informe o comprovante para agilizar a validação:',
              style: GoogleFonts.montserrat(
                color: Colors.black87,
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 20),

            // Campo opcional para informar o comprovante da TED
            TextField(
              controller: _comprovanteController,
              decoration: InputDecoration(
                // Texto exibido dentro do campo
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

            // Botão responsável por confirmar a TED
            SizedBox(
              width: double.infinity,
              height: 56,
              child: Container(
                // Gradiente utilizado no botão
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5B5FEF), Color(0xFF353988)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ElevatedButton(
                  // Executa a confirmação da TED
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
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      color: Colors.white,
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

  // Widget reutilizável responsável por exibir
  // informações bancárias em formato de cartão
  Widget _infoCard({required String titulo, required String valor}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          // Sombra utilizada para destacar o cartão
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
                // Título da informação exibida
                Text(
                  titulo,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: Color(0xFF8E8E8E),
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 4),

                // Valor correspondente à informação
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

          // Botão responsável por copiar a informação
          // para a área de transferência
          IconButton(
            onPressed: () {
              // Copia o valor para o Clipboard
              Clipboard.setData(ClipboardData(text: valor));

              // Exibe mensagem de confirmação
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

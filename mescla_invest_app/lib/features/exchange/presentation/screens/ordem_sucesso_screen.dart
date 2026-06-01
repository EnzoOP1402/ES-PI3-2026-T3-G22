/* Autor: livia */

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mescla_invest_app/core/widgets/app_bottom_navigation.dart';
import 'package:mescla_invest_app/core/widgets/custom_app_bar.dart';
import 'package:mescla_invest_app/routes/app_routes.dart';

import '../../data/models/exchange_model.dart';

/// Tela de confirmação exibida após a abertura bem-sucedida de uma ordem
/// de compra ou venda. Mostra mensagens contextuais e botões de navegação
/// conforme o tipo e modo da ordem realizada.
class OrdemSucessoScreen extends StatelessWidget {
  const OrdemSucessoScreen({super.key});

  // --- Paleta de cores da tela ---
  static const Color _primaryColor = Color(0xFF353988);    // Azul escuro principal
  static const Color _backgroundColor = Color(0xFFDEDEDE); // Fundo geral da tela

  @override
  Widget build(BuildContext context) {
    // Lê e converte os argumentos de rota para o objeto tipado [_SucessoArgs].
    final args = _SucessoArgs.fromRoute(context);

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: const CustomAppBar(
        title: 'Balcão',
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ícone de sucesso: círculo verde com checkmark.
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Color(0xFF008A17),
                      width: 5,
                    ),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Color(0xFF008A17),
                    size: 62,
                  ),
                ),

                const SizedBox(height: 18),

                // Título fixo de sucesso.
                Text(
                  'Tudo certo!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    color: _primaryColor,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),

                const SizedBox(height: 8),

                // Mensagem principal: varia conforme tipo e modo da ordem.
                Text(
                  args.mensagemPrincipal,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    color: Colors.black87,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 10),

                // Mensagem secundária: instrução adicional ao usuário.
                Text(
                  args.mensagemSecundaria,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    color: Colors.black54,
                    fontSize: 11,
                    height: 1.25,
                  ),
                ),

                const SizedBox(height: 24),

                // Botão "Ir para a carteira": exibido apenas em ordens de compra.
                if (args.tipo == TipoOrdem.compra)
                  SizedBox(
                    width: 170,
                    height: 38,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                      onPressed: () {
                        // Remove toda a pilha de rotas e navega direto para a carteira.
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.wallet,
                          (route) => false,
                        );
                      },
                      child: Text(
                        'Ir para a carteira',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),

                // Espaçamento entre botões, presente apenas quando há dois botões.
                if (args.tipo == TipoOrdem.compra)
                  const SizedBox(height: 10),

                // Botão "Voltar ao balcão": sempre visível, limpa a pilha de navegação.
                SizedBox(
                  width: 170,
                  height: 38,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                    onPressed: () {
                      // Remove toda a pilha de rotas e navega direto para o balcão.
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.exchange,
                        (route) => false,
                      );
                    },
                    child: Text(
                      'Voltar ao balcão',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavigation(
        selectedIndex: 2,
      ),
    );
  }
}

/// Objeto de dados que encapsula os argumentos de rota da tela de sucesso.
/// Responsável também por calcular as mensagens exibidas com base no contexto da ordem.
class _SucessoArgs {
  /// Tipo da ordem realizada (compra ou venda).
  final TipoOrdem tipo;

  /// Modo da ordem realizada (mercado ou limitada).
  final ModoOrdem modo;

  /// Nome da startup envolvida na ordem.
  final String startupNome;

  /// Valor total da operação realizada.
  final double valorTotal;

  const _SucessoArgs({
    required this.tipo,
    required this.modo,
    required this.startupNome,
    required this.valorTotal,
  });

  /// Retorna a mensagem principal exibida na tela,
  /// variando conforme o tipo e modo da ordem.
  String get mensagemPrincipal {
    if (tipo == TipoOrdem.venda) {
      return 'Sua ordem de venda foi aberta com sucesso.';
    }

    if (modo == ModoOrdem.mercado) {
      return 'Sua compra foi efetuada com sucesso.';
    }

    return 'Sua ordem de compra foi aberta com sucesso.';
  }

  /// Retorna a mensagem secundária (instrução adicional),
  /// variando conforme o tipo e modo da ordem.
  String get mensagemSecundaria {
    if (tipo == TipoOrdem.venda) {
      return 'Você receberá uma notificação assim que sua ordem for realizada.';
    }

    if (modo == ModoOrdem.mercado) {
      return 'Você pode conferir os resultados na sua carteira.';
    }

    return 'Você receberá uma notificação assim que sua ordem for realizada.';
  }

  /// Factory que lê os argumentos da rota atual e retorna um [_SucessoArgs] populado.
  /// Caso os argumentos sejam inválidos ou ausentes, retorna um objeto com valores padrão.
  factory _SucessoArgs.fromRoute(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map<String, dynamic>) {
      return _SucessoArgs(
        tipo: TipoOrdemExtension.fromString(
          args['tipo']?.toString() ?? 'compra',
        ),
        modo: ModoOrdemExtension.fromString(
          args['modo']?.toString() ?? 'mercado',
        ),
        startupNome: args['startupNome']?.toString() ?? '',
        valorTotal: _toDouble(args['valorTotal']),
      );
    }

    // Fallback seguro quando nenhum argumento é recebido.
    return const _SucessoArgs(
      tipo: TipoOrdem.compra,
      modo: ModoOrdem.mercado,
      startupNome: '',
      valorTotal: 0,
    );
  }
}

/// Converte um valor dinâmico para [double] de forma segura.
/// Suporta [double], [int], [String] (com vírgula ou ponto) e nulos.
double _toDouble(dynamic value) {
  if (value == null) {
    return 0;
  }

  if (value is double) {
    return value;
  }

  if (value is int) {
    return value.toDouble();
  }

  // Tenta parsear string substituindo vírgula por ponto.
  return double.tryParse(
        value.toString().replaceAll(',', '.'),
      ) ??
      0;
}
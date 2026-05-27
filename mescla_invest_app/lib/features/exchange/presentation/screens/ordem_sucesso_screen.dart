/* Autor: livia */

import 'package:flutter/material.dart';
import 'package:mescla_invest_app/core/widgets/app_bottom_navigation.dart';
import 'package:mescla_invest_app/core/widgets/custom_app_bar.dart';
import 'package:mescla_invest_app/routes/app_routes.dart';

import '../../data/models/exchange_model.dart';

class OrdemSucessoScreen extends StatelessWidget {
  const OrdemSucessoScreen({super.key});

  static const Color _primaryColor = Color(0xFF353988);
  static const Color _backgroundColor = Color(0xFFDEDEDE);

  @override
  Widget build(BuildContext context) {
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

                const Text(
                  'Tudo certo!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _primaryColor,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  args.mensagemPrincipal,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  args.mensagemSecundaria,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 11,
                    height: 1.25,
                  ),
                ),

                const SizedBox(height: 24),

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
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.wallet,
                          (route) => false,
                        );
                      },
                      child: const Text(
                        'Ir para a carteira',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),

                if (args.tipo == TipoOrdem.compra)
                  const SizedBox(height: 10),

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
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.exchange,
                        (route) => false,
                      );
                    },
                    child: const Text(
                      'Voltar ao balcão',
                      style: TextStyle(
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

class _SucessoArgs {
  final TipoOrdem tipo;
  final ModoOrdem modo;
  final String startupNome;
  final double valorTotal;

  const _SucessoArgs({
    required this.tipo,
    required this.modo,
    required this.startupNome,
    required this.valorTotal,
  });

  String get mensagemPrincipal {
    if (tipo == TipoOrdem.venda) {
      return 'Sua ordem de venda foi aberta com sucesso.';
    }

    if (modo == ModoOrdem.mercado) {
      return 'Sua ordem de compra foi aberta com sucesso.';
    }

    return 'Sua ordem de compra limitada foi aberta com sucesso.';
  }

  String get mensagemSecundaria {
    if (tipo == TipoOrdem.venda) {
      return 'Você receberá uma notificação assim que sua ordem for realizada.';
    }

    if (modo == ModoOrdem.mercado) {
      return 'Você pode conferir os resultados na sua carteira.';
    }

    return 'Você receberá uma notificação assim que sua ordem for realizada.';
  }

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

    return const _SucessoArgs(
      tipo: TipoOrdem.compra,
      modo: ModoOrdem.mercado,
      startupNome: '',
      valorTotal: 0,
    );
  }
}

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

  return double.tryParse(
        value.toString().replaceAll(',', '.'),
      ) ??
      0;
}
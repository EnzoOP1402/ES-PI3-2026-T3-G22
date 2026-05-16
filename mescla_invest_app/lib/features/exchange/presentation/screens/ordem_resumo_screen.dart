/* Autor: livia */

import 'package:flutter/material.dart';
import 'package:mescla_invest_app/core/widgets/app_bottom_navigation.dart';
import 'package:mescla_invest_app/core/widgets/custom_app_bar.dart';
import 'package:mescla_invest_app/routes/app_routes.dart';

import '../../data/services/exchange_service.dart';
import '../../widgets/exchange_model.dart';

class OrdemResumoScreen extends StatefulWidget {
  const OrdemResumoScreen({super.key});

  @override
  State<OrdemResumoScreen> createState() => _OrdemResumoScreenState();
}

class _OrdemResumoScreenState extends State<OrdemResumoScreen> {
  final ExchangeService _exchangeService = ExchangeService();

  static const Color _primaryColor = Color(0xFF353988);
  static const Color _accentColor = Color(0xFFDB0065);
  static const Color _backgroundColor = Color(0xFFE8E9EB);

  bool _carregando = false;

  String _formatarMoeda(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  Future<void> _abrirOrdem(_ResumoOrdemArgs args) async {
    setState(() {
      _carregando = true;
    });

    try {
      await _exchangeService.abrirOrdem(
        startupId: args.startupId,
        startupNome: args.startupNome,
        simbolo: args.simbolo,
        tipo: args.tipo,
        modo: args.modo,
        quantidadeTokens: args.quantidadeTokens,
        precoUnitario: args.precoUnitario,
      );

      if (!mounted) return;

      Navigator.pushReplacementNamed(
        context,
        AppRoutes.ordemSucesso,
        arguments: {
          'tipo': args.tipo.value,
          'modo': args.modo.value,
          'startupNome': args.startupNome,
          'valorTotal': args.valorTotal,
        },
      );
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao abrir ordem: $erro'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = _ResumoOrdemArgs.fromRoute(context);

    return Scaffold(
      backgroundColor: _backgroundColor,

      appBar: const CustomAppBar(
        title: 'Balcão',
      ),

      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                args.tituloTela,
                style: const TextStyle(
                  color: _primaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                'Revise os dados da ordem antes de confirmar a operação.',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 11,
                  height: 1.25,
                ),
              ),

              const SizedBox(height: 18),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(
                    color: Colors.black26,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: _primaryColor,
                          size: 26,
                        ),

                        SizedBox(width: 8),

                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                'Resumo da ordem',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _primaryColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),

                              SizedBox(height: 2),

                              Text(
                                'Revise com atenção antes de prosseguir',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    _linhaResumo(
                      titulo: 'Tipo de ordem',
                      valor: args.tipo.label,
                    ),

                    _linhaResumo(
                      titulo: 'Modo da ordem',
                      valor: args.modo.label,
                    ),

                    _linhaResumo(
                      titulo: 'Startup selecionada',
                      valor: args.startupNome,
                    ),

                    _linhaResumo(
                      titulo: 'Símbolo',
                      valor: args.simbolo,
                    ),

                    _linhaResumo(
                      titulo: 'Quantidade de tokens escolhida',
                      valor: '${args.quantidadeTokens} tokens',
                    ),

                    _linhaResumo(
                      titulo: 'Valor unitário de cada token',
                      valor: _formatarMoeda(args.precoUnitario),
                    ),

                    _linhaResumo(
                      titulo: args.tipo == TipoOrdem.compra
                          ? 'Valor total a ser investido'
                          : 'Valor total a ser arrecadado',
                      valor: _formatarMoeda(args.valorTotal),
                    ),

                    _linhaResumo(
                      titulo: 'Status inicial da ordem',
                      valor: 'Aberta',
                    ),

                    const SizedBox(height: 18),

                    SizedBox(
                      width: 160,
                      height: 42,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                        onPressed: _carregando
                            ? null
                            : () {
                                _abrirOrdem(args);
                              },
                        child: _carregando
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Abrir ordem',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Voltar e editar dados',
                    style: TextStyle(
                      color: _accentColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: const AppBottomNavigation(
        selectedIndex: 2,
      ),
    );
  }

  Widget _linhaResumo({
    required String titulo,
    required String valor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 7),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.black26,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            valor,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResumoOrdemArgs {
  final TipoOrdem tipo;
  final ModoOrdem modo;
  final String startupId;
  final String startupNome;
  final String simbolo;
  final int quantidadeTokens;
  final double precoUnitario;

  const _ResumoOrdemArgs({
    required this.tipo,
    required this.modo,
    required this.startupId,
    required this.startupNome,
    required this.simbolo,
    required this.quantidadeTokens,
    required this.precoUnitario,
  });

  double get valorTotal {
    return quantidadeTokens * precoUnitario;
  }

  String get tituloTela {
    if (tipo == TipoOrdem.venda) {
      return 'Abertura de Ordem de Venda';
    }

    if (modo == ModoOrdem.mercado) {
      return 'Abertura de Ordem de Compra a Mercado';
    }

    return 'Abertura de Ordem de Compra Limitada';
  }

  factory _ResumoOrdemArgs.fromRoute(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map<String, dynamic>) {
      return _ResumoOrdemArgs(
        tipo: TipoOrdemExtension.fromString(
          args['tipo']?.toString() ?? 'compra',
        ),
        modo: ModoOrdemExtension.fromString(
          args['modo']?.toString() ?? 'mercado',
        ),
        startupId: args['startupId']?.toString() ?? '',
        startupNome: args['startupNome']?.toString() ?? '',
        simbolo: args['simbolo']?.toString() ?? '',
        quantidadeTokens: _toInt(args['quantidadeTokens']),
        precoUnitario: _toDouble(args['precoUnitario']),
      );
    }

    return const _ResumoOrdemArgs(
      tipo: TipoOrdem.compra,
      modo: ModoOrdem.mercado,
      startupId: '',
      startupNome: '',
      simbolo: '',
      quantidadeTokens: 0,
      precoUnitario: 0,
    );
  }
}

int _toInt(dynamic value) {
  if (value == null) return 0;

  if (value is int) {
    return value;
  }

  if (value is double) {
    return value.toInt();
  }

  return int.tryParse(value.toString()) ?? 0;
}

double _toDouble(dynamic value) {
  if (value == null) return 0;

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
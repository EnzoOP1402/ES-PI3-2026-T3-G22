/* Autor: livia */

import 'package:flutter/material.dart';
import 'package:mescla_invest_app/core/widgets/app_bottom_navigation.dart';
import 'package:mescla_invest_app/core/widgets/custom_app_bar.dart';
import 'package:mescla_invest_app/routes/app_routes.dart';

import '../../data/services/exchange_service.dart';
import '../../widgets/exchange_model.dart';

class OrdemFormScreen extends StatefulWidget {
  const OrdemFormScreen({super.key});

  @override
  State<OrdemFormScreen> createState() => _OrdemFormScreenState();
}

class _OrdemFormScreenState extends State<OrdemFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _precoController = TextEditingController();
  final TextEditingController _quantidadeController = TextEditingController();

  final ExchangeService _exchangeService = ExchangeService();

  static const Color _primaryColor = Color(0xFF353988);
  static const Color _backgroundColor = Color(0xFFE8E9EB);

  TipoOrdem _tipo = TipoOrdem.compra;
  ModoOrdem _modo = ModoOrdem.mercado;

  StartupExchangeOption? _startupSelecionada;

  bool get _isOrdemMercado {
    return _modo == ModoOrdem.mercado;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map<String, dynamic>) {
      _tipo = TipoOrdemExtension.fromString(
        args['tipo']?.toString() ?? 'compra',
      );

      _modo = ModoOrdemExtension.fromString(
        args['modo']?.toString() ?? 'mercado',
      );
    }
  }

  @override
  void dispose() {
    _precoController.dispose();
    _quantidadeController.dispose();
    super.dispose();
  }

  String get _tituloTela {
    if (_tipo == TipoOrdem.venda) {
      return 'Abertura de Ordem de Venda';
    }

    if (_modo == ModoOrdem.mercado) {
      return 'Abertura de Ordem de Compra a Mercado';
    }

    return 'Abertura de Ordem de Compra Limitada';
  }

  String get _descricaoTela {
    if (_tipo == TipoOrdem.venda) {
      return 'Preencha os dados necessários para cadastrar uma oferta de venda de tokens.';
    }

    if (_modo == ModoOrdem.mercado) {
      return 'O valor unitário será definido automaticamente pelo preço do token cadastrado pela startup.';
    }

    return 'Preencha os dados necessários para prosseguir com a criação da oferta de compra de tokens.';
  }

  String get _textoSelecaoStartup {
    if (_tipo == TipoOrdem.venda) {
      return 'Selecione uma startup que você possui tokens para vender.';
    }

    return 'Você deseja abrir uma ordem para qual startup?';
  }

  String get _textoCampoPreco {
    if (_isOrdemMercado) {
      return 'Valor unitário definido pela startup';
    }

    return 'Informe o valor unitário de cada token';
  }

  double _converterPreco(String valor) {
    final texto = valor.replaceAll('R\$', '').trim();

    if (texto.contains(',')) {
      return double.tryParse(
            texto.replaceAll('.', '').replaceAll(',', '.'),
          ) ??
          0;
    }

    return double.tryParse(texto) ?? 0;
  }

  int _converterQuantidade(String valor) {
    return int.tryParse(valor.trim()) ?? 0;
  }

  String _formatarPrecoInput(double valor) {
    return valor.toStringAsFixed(2).replaceAll('.', ',');
  }

  void _atualizarPrecoMercado() {
    if (!_isOrdemMercado) {
      return;
    }

    final startup = _startupSelecionada;

    if (startup == null || startup.valorToken <= 0) {
      _precoController.clear();
      return;
    }

    _precoController.text = _formatarPrecoInput(startup.valorToken);
  }

  StartupExchangeOption? _buscarStartupSelecionadaNaLista(
    List<StartupExchangeOption> startups,
  ) {
    if (_startupSelecionada == null) {
      return null;
    }

    for (final startup in startups) {
      if (startup.id == _startupSelecionada!.id) {
        return startup;
      }
    }

    return null;
  }

  void _avancarParaResumo() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startupSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione uma startup para continuar.'),
        ),
      );
      return;
    }

    final int quantidade = _converterQuantidade(_quantidadeController.text);

    final double preco = _isOrdemMercado
        ? _startupSelecionada!.valorToken
        : _converterPreco(_precoController.text);

    if (preco <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Essa startup ainda não possui um valor de token cadastrado.',
          ),
        ),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      AppRoutes.ordemResumo,
      arguments: {
        'tipo': _tipo.value,
        'modo': _modo.value,
        'startupId': _startupSelecionada!.id,
        'startupNome': _startupSelecionada!.nome,
        'simbolo': _startupSelecionada!.simbolo,
        'precoUnitario': preco,
        'quantidadeTokens': quantidade,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,

      appBar: const CustomAppBar(
        title: 'Balcão',
      ),

      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _tituloTela,
                  style: const TextStyle(
                    color: _primaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  _descricaoTela,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 11,
                    height: 1.25,
                  ),
                ),

                const SizedBox(height: 18),

                Text(
                  _textoSelecaoStartup,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 6),

                StreamBuilder<List<StartupExchangeOption>>(
                  stream: _exchangeService.buscarStartupsParaOrdem(
                    tipo: _tipo,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: _primaryColor,
                          ),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Text(
                        'Erro ao carregar startups: ${snapshot.error}',
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }

                    final startups = snapshot.data ?? [];

                    if (startups.isEmpty) {
                      return Text(
                        _tipo == TipoOrdem.venda
                            ? 'Você ainda não possui tokens de nenhuma startup para vender.'
                            : 'Nenhuma startup cadastrada no momento.',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      );
                    }

                    final startupSelecionadaAtual =
                        _buscarStartupSelecionadaNaLista(startups);

                    return DropdownButtonFormField<StartupExchangeOption>(
                      value: startupSelecionadaAtual,
                      isExpanded: true,
                      decoration: _inputDecoration(),
                      hint: const Text(
                        'Selecione uma startup',
                        style: TextStyle(fontSize: 12),
                      ),
                      items: startups.map((startup) {
                        final precoTexto = startup.valorToken > 0
                            ? 'R\$ ${_formatarPrecoInput(startup.valorToken)}'
                            : 'sem preço';

                        return DropdownMenuItem<StartupExchangeOption>(
                          value: startup,
                          child: Text(
                            '${startup.nome} (${startup.simbolo}) - $precoTexto',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _startupSelecionada = value;
                          _atualizarPrecoMercado();
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Selecione uma startup.';
                        }

                        return null;
                      },
                    );
                  },
                ),

                const SizedBox(height: 14),

                Text(
                  _textoCampoPreco,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 6),

                TextFormField(
                  controller: _precoController,
                  readOnly: _isOrdemMercado,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: _inputDecoration(
                    hintText: _isOrdemMercado
                        ? 'Selecione uma startup'
                        : 'R\$',
                    suffixIcon: _isOrdemMercado
                        ? const Icon(
                            Icons.lock_outline_rounded,
                            size: 18,
                            color: Colors.black45,
                          )
                        : null,
                  ),
                  validator: (value) {
                    final double preco = _isOrdemMercado
                        ? (_startupSelecionada?.valorToken ?? 0)
                        : _converterPreco(value ?? '');

                    if (preco <= 0) {
                      return _isOrdemMercado
                          ? 'A startup não possui valor de token cadastrado.'
                          : 'Informe um valor válido.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 14),

                const Text(
                  'Informe a quantidade de tokens',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 6),

                TextFormField(
                  controller: _quantidadeController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration(
                    hintText: 'Ex: 1, 100, 1000...',
                  ),
                  validator: (value) {
                    final int quantidade = _converterQuantidade(value ?? '');

                    if (quantidade <= 0) {
                      return 'Informe uma quantidade válida.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 28),

                Center(
                  child: SizedBox(
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
                      onPressed: _avancarParaResumo,
                      child: const Text(
                        'Avançar',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
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

  InputDecoration _inputDecoration({
    String? hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      suffixIcon: suffixIcon,
      hintStyle: const TextStyle(
        color: Colors.black38,
        fontSize: 11,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: BorderSide.none,
      ),
      errorStyle: const TextStyle(
        fontSize: 10,
      ),
    );
  }
}
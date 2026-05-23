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

  Stream<List<StartupExchangeOption>>? _startupsStream;
  bool _argumentosCarregados = false;

  static const Color _primaryColor = Color(0xFF353988);
  static const Color _accentColor = Color(0xFFDB0065);
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

    if (_argumentosCarregados) {
      return;
    }

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map<String, dynamic>) {
      _tipo = TipoOrdemExtension.fromString(
        args['tipo']?.toString() ?? 'compra',
      );

      _modo = ModoOrdemExtension.fromString(
        args['modo']?.toString() ?? 'mercado',
      );
    }

    _startupsStream = _exchangeService.buscarStartupsParaOrdem(
      tipo: _tipo,
    );

    _argumentosCarregados = true;
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

  bool _erroPodeSerTratadoComoSemTokensParaVenda(Object? erro) {
    if (erro == null) {
      return false;
    }

    final texto = erro.toString().toLowerCase();

    return texto.contains('permission-denied') ||
        texto.contains('missing or insufficient permissions') ||
        texto.contains('insufficient permissions') ||
        texto.contains('not-found') ||
        texto.contains('não possui tokens') ||
        texto.contains('nao possui tokens');
  }

  Future<void> _abrirOrdemCompra() async {
    await Navigator.pushReplacementNamed(
      context,
      AppRoutes.ordemForm,
      arguments: {
        'tipo': TipoOrdem.compra.value,
        'modo': ModoOrdem.mercado.value,
      },
    );
  }

  void _acessarCatalogo() {
    Navigator.pushNamed(
      context,
      AppRoutes.catalog,
    );
  }

  Future<void> _avancarParaResumo() async {
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

    final resultado = await Navigator.pushNamed(
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

    if (!mounted) return;

    if (resultado == 'saldo_insuficiente') {
      Navigator.pop(context, 'saldo_insuficiente');
      return;
    }

    if (resultado == true || resultado == 'ordem_criada') {
      Navigator.pop(context, resultado);
      return;
    }
  }

  Widget _buildEstadoSemTokensParaVenda() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.black.withOpacity(0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              color: _accentColor.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              color: _accentColor,
              size: 32,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Você ainda não possui tokens de nenhuma startup.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _primaryColor,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Deseja começar a investir?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Abra uma ordem de compra ou acesse o catálogo para conhecer as startups disponíveis.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black54,
              fontSize: 11.5,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
              onPressed: _abrirOrdemCompra,
              child: const Text(
                'Abrir ordem de compra',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: _primaryColor,
                side: BorderSide(
                  color: _primaryColor.withOpacity(0.25),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
              onPressed: _acessarCatalogo,
              child: const Text(
                'Acessar catálogo',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadoSemStartupsCompra() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.black.withOpacity(0.06),
        ),
      ),
      child: const Text(
        'Nenhuma startup cadastrada no momento.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.black54,
          fontSize: 12,
        ),
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

  Widget _buildFormularioComStartups(
    List<StartupExchangeOption> startups,
  ) {
    final startupSelecionadaAtual =
        _buscarStartupSelecionadaNaLista(startups);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<StartupExchangeOption>(
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
            hintText: _isOrdemMercado ? 'Selecione uma startup' : 'R\$',
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
    );
  }

  Widget _buildConteudoStartups() {
    return StreamBuilder<List<StartupExchangeOption>>(
      stream: _startupsStream,
      builder: (context, snapshot) {
        if (_startupsStream == null ||
            snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 28),
            child: Center(
              child: CircularProgressIndicator(
                color: _primaryColor,
              ),
            ),
          );
        }

        final startups = snapshot.data ?? [];

        final bool semTokensParaVenda = _tipo == TipoOrdem.venda &&
            ((snapshot.hasError &&
                    _erroPodeSerTratadoComoSemTokensParaVenda(
                      snapshot.error,
                    )) ||
                (!snapshot.hasError && startups.isEmpty));

        if (semTokensParaVenda) {
          return _buildEstadoSemTokensParaVenda();
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Erro ao carregar startups: ${snapshot.error}',
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }

        if (startups.isEmpty) {
          return _buildEstadoSemStartupsCompra();
        }

        return _buildFormularioComStartups(startups);
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
                _buildConteudoStartups(),
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
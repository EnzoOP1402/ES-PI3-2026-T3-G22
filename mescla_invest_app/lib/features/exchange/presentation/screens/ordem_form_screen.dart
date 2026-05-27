/* Autor: livia */

import 'package:flutter/material.dart';
import 'package:mescla_invest_app/core/utils/snackbar_utils.dart';
import 'package:mescla_invest_app/core/widgets/app_bottom_navigation.dart';
import 'package:mescla_invest_app/core/widgets/custom_app_bar.dart';
import 'package:mescla_invest_app/features/exchange/widgets/order_confirmation_modal.dart';
import 'package:mescla_invest_app/routes/app_routes.dart';

import '../../data/services/exchange_service.dart';
import '../../data/models/exchange_model.dart';

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

  Future<List<StartupExchangeOption>>? _startupsFuture;
  bool _argumentosCarregados = false;
  bool _verificandoSaldo = false; // Novo estado de loading para botão de avançar

  static const Color _primaryColor = Color(0xFF353988);
  static const Color _accentColor = Color(0xFFDB0065);
  static const Color _backgroundColor = Color(0xFFE8E9EB);

  TipoOrdem _tipo = TipoOrdem.compra;
  ModoOrdem _modo = ModoOrdem.mercado;

  StartupExchangeOption? _startupSelecionada;

  bool get _isOrdemMercado => _modo == ModoOrdem.mercado;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_argumentosCarregados) return;

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map<String, dynamic>) {
      _tipo = TipoOrdemExtension.fromString(args['tipo']?.toString() ?? 'compra');
      _modo = ModoOrdemExtension.fromString(args['modo']?.toString() ?? 'mercado');
    }

    _startupsFuture = _exchangeService.buscarStartupsParaOrdem(tipo: _tipo);
    _argumentosCarregados = true;
  }

  @override
  void dispose() {
    _precoController.dispose();
    _quantidadeController.dispose();
    super.dispose();
  }

  String get _tituloTela {
    if (_tipo == TipoOrdem.venda) return 'Abertura de Ordem de Venda';
    if (_modo == ModoOrdem.mercado) return 'Abertura de Ordem de Compra a Mercado';
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
    if (_isOrdemMercado) return 'Valor unitário definido pela startup';
    return 'Informe o valor unitário de cada token';
  }

  double _converterPreco(String valor) {
    final texto = valor.replaceAll('R\$', '').trim();
    if (texto.contains(',')) {
      return double.tryParse(texto.replaceAll('.', '').replaceAll(',', '.')) ?? 0;
    }
    return double.tryParse(texto) ?? 0;
  }

  int _converterQuantidade(String valor) => int.tryParse(valor.trim()) ?? 0;

  String _formatarPrecoInput(double valor) => valor.toStringAsFixed(2).replaceAll('.', ',');

  void _atualizarPrecoMercado() {
    if (!_isOrdemMercado) return;
    
    if (_startupSelecionada == null || _startupSelecionada!.valorToken <= 0) {
      _precoController.clear();
      return;
    }
    _precoController.text = _formatarPrecoInput(_startupSelecionada!.valorToken);
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

  void _acessarCatalogo() => Navigator.pushNamed(context, AppRoutes.catalog);

  Future<void> _avancarParaResumo() async {
    if (!_formKey.currentState!.validate()) return;

    if (_startupSelecionada == null) {
      showErrorSnackBar(context, 'Selecione uma startup para continuar.');
      return;
    }

    final int quantidade = _converterQuantidade(_quantidadeController.text);
    final double preco = _isOrdemMercado ? _startupSelecionada!.valorToken : _converterPreco(_precoController.text);

    if (preco <= 0) {
      showErrorSnackBar(context, 'Essa startup ainda não possui um valor de token cadastrado.');
      return;
    }

    if (_tipo == TipoOrdem.compra) {
      setState(() => _verificandoSaldo = true);
      try {
        final saldoDisponivel = await _exchangeService.obterSaldoDisponivel();
        final custoEstimado = preco * quantidade;

        if (custoEstimado > saldoDisponivel) {
          if (!mounted) return;
          // Retorna a flag para a tela anterior disparar o pop-up sem precisar estourar a function na nuvem
          Navigator.pop(context, 'saldo_insuficiente'); 
          return;
        }
      } catch (e) {
        // Se a verificação falhar, deixamos passar para que o próprio Trigger/Function no backend trave a ordem (camada extra de proteção).
      } finally {
        if (mounted) setState(() => _verificandoSaldo = false);
      }
    }

    if (_formKey.currentState!.validate()) {

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => OrderConfirmationModal(
          tipo: _tipo,
          modo: _modo,
          startupId: _startupSelecionada!.id,
          startupNome: _startupSelecionada!.nome,
          simbolo: _startupSelecionada!.simbolo,
          quantidadeTokens: int.parse(_quantidadeController.text),
          precoUnitario: double.parse(_precoController.text.replaceAll(',', '.')),
        ),
      );
    }

    if (!mounted) return;
  }

  Widget _buildEstadoSemTokensParaVenda() {
     return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        children: [
          Container(
            width: 66, height: 66,
            decoration: BoxDecoration(color: _accentColor.withOpacity(0.10), shape: BoxShape.circle),
            child: const Icon(Icons.account_balance_wallet_outlined, color: _accentColor, size: 32),
          ),
          const SizedBox(height: 14),
          const Text('Você ainda não possui tokens.', textAlign: TextAlign.center, style: TextStyle(color: _primaryColor, fontSize: 17, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text('Deseja começar a investir?', textAlign: TextAlign.center, style: TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w700)),
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
                  borderRadius: BorderRadius.circular(9)
                )
              ),
              onPressed: _abrirOrdemCompra,
              child: const Text('Abrir ordem de compra',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800)
              )
            )
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: _primaryColor,
                side: BorderSide(
                  color: _primaryColor.withOpacity(0.25)
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9)
                )
              ), onPressed: _acessarCatalogo,
              child: const Text('Acessar catálogo',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700
              )
             )
            )
          ),
        ],
      ),
    );
  }

  Widget _buildEstadoSemStartupsCompra() {
    return Container(
      width: double.infinity, margin: const EdgeInsets.only(top: 8), padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.black.withOpacity(0.06))),
      child: const Text('Nenhuma startup cadastrada no momento.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54, fontSize: 12)),
    );
  }

  InputDecoration _inputDecoration({String? hintText, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hintText, suffixIcon: suffixIcon,
      hintStyle: const TextStyle(color: Colors.black38, fontSize: 11),
      filled: true, fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(7), borderSide: BorderSide.none),
    );
  }

  Widget _buildFormularioComStartups(List<StartupExchangeOption> startups) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<StartupExchangeOption>(
          value: _startupSelecionada,
          isExpanded: true,
          decoration: _inputDecoration(),
          hint: const Text('Selecione uma startup', style: TextStyle(fontSize: 12)),
          items: startups.map((startup) {
            final precoTexto = startup.valorToken > 0 ? 'R\$ ${_formatarPrecoInput(startup.valorToken)}' : 'sem preço';
            return DropdownMenuItem<StartupExchangeOption>(
              value: startup,
              child: Text('${startup.nome} (${startup.simbolo}) - $precoTexto', overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
            );
          }).toList(),
          onChanged: (value) {
            setState(() { _startupSelecionada = value; _atualizarPrecoMercado(); });
          },
          validator: (value) => value == null ? 'Selecione uma startup.' : null,
        ),
        const SizedBox(height: 14),
        Text(_textoCampoPreco, style: const TextStyle(color: Colors.black87, fontSize: 11, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        TextFormField(
          controller: _precoController,
          readOnly: _isOrdemMercado,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: _inputDecoration(
            hintText: _isOrdemMercado ? 'Selecione uma startup' : 'R\$',
            suffixIcon: _isOrdemMercado ? const Icon(Icons.lock_outline_rounded, size: 18, color: Colors.black45) : null,
          ),
          validator: (value) {
            final double preco = _isOrdemMercado ? (_startupSelecionada?.valorToken ?? 0) : _converterPreco(value ?? '');
            if (preco <= 0) return _isOrdemMercado ? 'A startup não possui valor de token.' : 'Informe um valor válido.';
            return null;
          },
        ),
        const SizedBox(height: 14),
        const Text('Informe a quantidade de tokens', style: TextStyle(color: Colors.black87, fontSize: 11, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        TextFormField(
          controller: _quantidadeController,
          keyboardType: TextInputType.number,
          decoration: _inputDecoration(hintText: 'Ex: 1, 100, 1000...'),
          validator: (value) {
            if (_converterQuantidade(value ?? '') <= 0) return 'Informe uma quantidade válida.';
            return null;
          },
        ),
        const SizedBox(height: 28),
        Center(
          child: SizedBox(
            width: 160, height: 42,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _primaryColor, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7))),
              onPressed: _verificandoSaldo ? null : _avancarParaResumo,
              child: _verificandoSaldo 
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Avançar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConteudoStartups() {
    return FutureBuilder<List<StartupExchangeOption>>( // Mudança para consumir o Future
      future: _startupsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(padding: EdgeInsets.symmetric(vertical: 28), child: Center(child: CircularProgressIndicator(color: _primaryColor)));
        }

        if (snapshot.hasError) {
          return Padding(padding: const EdgeInsets.only(top: 6), child: Text('Erro ao carregar startups: ${snapshot.error}', style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w600)));
        }

        final startups = snapshot.data ?? [];

        // Sem mais 'try/catches' nas mensagens de erro do Firestore! A function manda a lista vazia se for o caso.
        if (_tipo == TipoOrdem.venda && startups.isEmpty) {
          return _buildEstadoSemTokensParaVenda();
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
      appBar: const CustomAppBar(title: 'Balcão'),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_tituloTela, style: const TextStyle(color: _primaryColor, fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(_descricaoTela, style: const TextStyle(color: Colors.black87, fontSize: 11, height: 1.25)),
                const SizedBox(height: 18),
                Text(_textoSelecaoStartup, style: const TextStyle(color: Colors.black87, fontSize: 11, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                _buildConteudoStartups(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavigation(selectedIndex: 2),
    );
  }
}
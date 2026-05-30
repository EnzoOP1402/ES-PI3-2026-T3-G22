/* Autor: livia */

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mescla_invest_app/core/utils/snackbar_utils.dart';
import 'package:mescla_invest_app/core/widgets/app_bottom_navigation.dart';
import 'package:mescla_invest_app/core/widgets/custom_app_bar.dart';
import 'package:mescla_invest_app/features/catalog/presentation/widgets/startup_detail/detailed_catalog_modal_layout.dart';
import 'package:mescla_invest_app/features/exchange/widgets/opcao_investimento_radio.dart';
import 'package:mescla_invest_app/routes/app_routes.dart';

import '../../data/models/board_order_model.dart';
import '../../data/services/exchange_service.dart';
import '../../data/models/exchange_model.dart';

class ExchangeScreen extends StatefulWidget {
  const ExchangeScreen({super.key});

  @override
  State<ExchangeScreen> createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends State<ExchangeScreen> {
  final ExchangeService _exchangeService = ExchangeService();

  Future<Map<String, List<BoardOrderModel>>>? _boardFuture;

  String? _startupFiltroId;
  String? _startupFiltroNome;
  bool _argumentosCarregados = false;

  static const Color _primaryColor = Color(0xFF353988);
  static const Color _accentColor = Color(0xFFDB0065);
  static const Color _backgroundColor = Color(0xFFE8E9EB);
  static const Color _sectionBackground = Color(0xFFE8E9EB);
  static const Color _cardBackground = Color(0xFFF4F4F4);

  @override
  void initState() {
    super.initState();
    _boardFuture = _exchangeService.buscarQuadroBalcao();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _carregarArgumentosFiltro();
  }

  void _carregarArgumentosFiltro() {
    if (_argumentosCarregados) return;

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map<String, dynamic>) {
      _startupFiltroId = args['startupId']?.toString();
      _startupFiltroNome = args['startupName']?.toString();

      final startupData = args['startupData'];

      if ((_startupFiltroNome == null || _startupFiltroNome!.trim().isEmpty) &&
          startupData is Map<String, dynamic>) {
        _startupFiltroNome = startupData['name']?.toString();
      }
    }

    _argumentosCarregados = true;
  }

  String _normalizarTexto(String? valor) {
    if (valor == null) return '';

    return valor
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  String _normalizarParaComparacao(String? valor) {
    return _normalizarTexto(valor).replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  List<BoardOrderModel> _filtrarOrdensPorStartup(
    List<BoardOrderModel> orders,
  ) {
    final filtroId = _startupFiltroId?.trim();
    final filtroNome = _startupFiltroNome?.trim();

    final temFiltroId = filtroId != null && filtroId.isNotEmpty;
    final temFiltroNome = filtroNome != null && filtroNome.isNotEmpty;

    if (!temFiltroId && !temFiltroNome) {
      return orders;
    }

    final filtroIdNormalizado = _normalizarTexto(filtroId);
    final filtroNomeNormalizado = _normalizarTexto(filtroNome);
    final filtroNomeComparacao = _normalizarParaComparacao(filtroNome);

    return orders.where((order) {
      final orderStartupIdNormalizado = _normalizarTexto(order.startupId);
      final orderStartupNameNormalizado = _normalizarTexto(order.startupName);
      final orderStartupNameComparacao =
          _normalizarParaComparacao(order.startupName);

      final idConfere = temFiltroId &&
          orderStartupIdNormalizado == filtroIdNormalizado;

      final nomeConfere = temFiltroNome &&
          orderStartupNameNormalizado == filtroNomeNormalizado;

      final nomeConfereSemEspacos = temFiltroNome &&
          orderStartupNameComparacao == filtroNomeComparacao;

      return idConfere || nomeConfere || nomeConfereSemEspacos;
    }).toList();
  }

  Future<void> _recarregarBalcao() async {
    setState(() {
      _boardFuture = _exchangeService.buscarQuadroBalcao();
    });

    await _boardFuture;
  }

  void _mostrarMensagemSaldoInsuficiente() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(
              maxWidth: 420,
            ),
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.20),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: _accentColor.withOpacity(0.10),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _accentColor.withOpacity(0.25),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.wallet,
                    color: _accentColor,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Saldo insuficiente',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    color: _primaryColor,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  'Você não possui saldo suficiente para abrir esta ordem no momento.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    color: Colors.black87,
                    fontSize: 12.5,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Abra sua carteira para adicionar fundos e tentar novamente.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    color: Colors.black54,
                    fontSize: 11.5,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _primaryColor,
                          side: BorderSide(
                            color: _primaryColor.withOpacity(0.25),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                        },
                        child: Text(
                          'Agora não',
                          style: GoogleFonts.montserrat(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(dialogContext).pop();

                          if (!mounted) return;

                          Navigator.pushNamed(
                            context,
                            AppRoutes.wallet,
                          );
                        },
                        child: Text(
                          'Abrir carteira',
                          style: GoogleFonts.montserrat(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
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
  }

  bool _erroEhSaldoInsuficiente(Object erro) {
    final textoErro = erro.toString().toLowerCase();

    if (erro is FirebaseFunctionsException) {
      final codigo = erro.code.toLowerCase();
      final mensagem = erro.message?.toLowerCase() ?? '';

      return codigo == 'failed-precondition' &&
          (mensagem.contains('saldo insuficiente') ||
              mensagem.contains('saldo suficiente') ||
              mensagem.contains('saldo_insuficiente') ||
              mensagem.contains('insufficient balance') ||
              textoErro.contains('saldo insuficiente') ||
              textoErro.contains('saldo suficiente') ||
              textoErro.contains('saldo_insuficiente') ||
              textoErro.contains('insufficient balance'));
    }

    return textoErro.contains('failed-precondition') &&
        (textoErro.contains('saldo insuficiente') ||
            textoErro.contains('saldo suficiente') ||
            textoErro.contains('saldo_insuficiente') ||
            textoErro.contains('insufficient balance'));
  }

  Future<void> _abrirFormularioOrdem({
    required TipoOrdem tipo,
    required ModoOrdem modo,
  }) async {
    try {
      final resultado = await Navigator.pushNamed(
        context,
        AppRoutes.ordemForm,
        arguments: {
          'tipo': tipo.value,
          'modo': modo.value,
        },
      );

      if (!mounted) return;

      if (resultado == 'saldo_insuficiente') {
        _mostrarMensagemSaldoInsuficiente();
        return;
      }

      await _recarregarBalcao();
    } catch (erro) {
      if (!mounted) return;

      if (_erroEhSaldoInsuficiente(erro)) {
        _mostrarMensagemSaldoInsuficiente();
        return;
      }

      ScaffoldMessenger.of(context).clearSnackBars();

      showErrorSnackBar(context, 'Não foi possível abrir a ordem. Tente novamente.');
    }
  }

  void _abrirModalTipoInvestimento() {
    ModoOrdem modoSelecionado = ModoOrdem.mercado;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DetailedCatalogModalLayout(
              title: "Como você quer investir?",
              subtitle: "Selecione a opção desejada",
              height: 4,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      OpcaoInvestimentoRadio(
                        titulo: 'Ordem a mercado',
                        descricao:
                            'Compre tokens pelo preço anunciado pela startup',
                        value: ModoOrdem.mercado,
                        groupValue: modoSelecionado,
                        onChanged: (value) {
                          setModalState(() {
                            modoSelecionado = value;
                          });
                        },
                      ),
                      OpcaoInvestimentoRadio(
                        titulo: 'Ordem limitada',
                        descricao:
                            'Faça sua oferta e negocie com outros investidores da plataforma',
                        value: ModoOrdem.limitada,
                        groupValue: modoSelecionado,
                        onChanged: (value) {
                          setModalState(() {
                            modoSelecionado = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: 180,
                        height: 42,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);

                            _abrirFormularioOrdem(
                              tipo: TipoOrdem.compra,
                              modo: modoSelecionado,
                            );
                          },
                          child: Text(
                            'Avançar',
                            style: GoogleFonts.montserrat(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _formatarPrecoCentavos(int priceCents) {
    final valor = priceCents / 100;
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')} / token';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: const CustomAppBar(title: 'Balcão'),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<Map<String, List<BoardOrderModel>>>(
                future: _boardFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: _primaryColor),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: Text(
                          'Erro ao carregar ordens: ${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            color: Colors.red,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  }

                  final todasSellOrders = snapshot.data?['sellOrders'] ?? [];
                  final todasBuyOrders = snapshot.data?['buyOrders'] ?? [];

                  final sellOrders = _filtrarOrdensPorStartup(
                    todasSellOrders,
                  );

                  final buyOrders = _filtrarOrdensPorStartup(
                    todasBuyOrders,
                  );

                  return RefreshIndicator(
                    color: _primaryColor,
                    onRefresh: _recarregarBalcao,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
                      children: [
                        _buildSecaoOrdens(
                          titulo: 'Ordens de Venda',
                          descricao:
                              'Confira todas as ofertas de venda de tokens disponíveis atualmente no MesclaInvest.',
                          hint: 'Ordens de compra são ofertas criadas pelos usuários para vender seus tokens para outros usuários que criem ordens de compra compatíveis.',
                          orders: sellOrders,
                          isVenda: true,
                        ),
                        const SizedBox(height: 16),
                        _buildSecaoOrdens(
                          titulo: 'Ordens de Compra',
                          descricao:
                              'Confira todas as ofertas de compra de tokens disponíveis atualmente no MesclaInvest.',
                          hint: 'Ordens de compra são ofertas criadas pelos usuários para comprar tokens de outros usuários que criem ordens de venda compatíveis.',
                          orders: buyOrders,
                          isVenda: false,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 22, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: _buildBotaoAcao(
                      texto: 'Investir',
                      cor: _primaryColor,
                      onPressed: _abrirModalTipoInvestimento,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildBotaoAcao(
                      texto: 'Vender',
                      cor: _accentColor,
                      onPressed: () {
                        _abrirFormularioOrdem(
                          tipo: TipoOrdem.venda,
                          modo: ModoOrdem.limitada,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ) 
      ),
      bottomNavigationBar: const AppBottomNavigation(selectedIndex: 2),
    );
  }

  Widget _buildSecaoOrdens({
    required String titulo,
    required String descricao,
    required String hint,
    required List<BoardOrderModel> orders,
    required bool isVenda,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: _sectionBackground,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.black.withOpacity(0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                titulo,
                style: GoogleFonts.montserrat(
                  color: _primaryColor,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
              IconButton(
                onPressed: () async {
                  await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text("Info: Ordem de ${isVenda ? 'venda' : 'compra'}"),
                      content: Text(hint),
                      actions: [
                        TextButton(
                          onPressed: () {
                            // Fecha o diálogo
                            Navigator.pop(context);
                          },
                          child: const Text("OK"),
                        ),
                      ],
                    ),
                  );
                },
                icon: Icon(Icons.info_outline_rounded),
                color: _primaryColor,
              )
            ],
          ),
          const SizedBox(height: 5),
          Text(
            descricao,
            style: GoogleFonts.montserrat(
              color: Colors.black87,
              fontSize: 14,
              height: 1.18,
              fontWeight: .w500
            ),
          ),
          const SizedBox(height: 12),
          orders.isEmpty
            ? Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  'Nenhuma ordem disponível no momento.',
                  style: GoogleFonts.montserrat(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              )
            : SizedBox(
                height: 220, 
                child: ListView.builder(
                  shrinkWrap: true,
                  // Garante que a rolagem interna funcione perfeitamente mesmo dentro de outro scroll
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: orders.length,
                  padding: EdgeInsets.zero, // Remove paddings padrões do ListView
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return _buildCardOferta(
                      order,
                      isVenda: isVenda,
                    );
                  },
                ),
              ),
        ],
      ),
    );
  }

Widget _buildCardOferta(
  BoardOrderModel order, {
  required bool isVenda,
}) {
  final bool isAlta = order.appreciated;
  final String priceTrend = order.priceTrend;
  final Color indicatorColor =
      !isAlta ? Color(0xFFD70000) : priceTrend == "equal" ? Color(0xFF757575) : Color(0xFF008A01);

  return Container(
    margin: const EdgeInsets.only(bottom: 9),
    decoration: BoxDecoration(
      color: _cardBackground,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.12),
          blurRadius: 5,
          offset: const Offset(0, 2),
        ),
      ],
      border: Border.all(
        color: Colors.black.withOpacity(0.04),
      ),
    ),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      dense: true,
      
      // Ícone lateral esquerdo
      leading: const Icon(
        Icons.attach_money_rounded,
        color: Colors.black,
        size: 24,
      ),

      // Título Principal
      title: Text(
        order.startupName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.montserrat(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),

      // Subtítulo descritivo
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(
          '${order.remainingQuantity} tokens • ${order.tokenName}',
          style: GoogleFonts.montserrat(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Lado direito: Preço e Indicador de tendência juntos
      trailing: Row(
        mainAxisSize: MainAxisSize.min, // Impede que a Row ocupe todo o espaço horizontal
        children: [
          Text(
            _formatarPrecoCentavos(order.priceCents),
            style: GoogleFonts.montserrat(
              color: indicatorColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 3),
          Icon(
            priceTrend == "up"
              ? Icons.arrow_upward_rounded
              : priceTrend == "down"
              ? Icons.arrow_downward_rounded
              : null,
            color: indicatorColor,
            size: 24,
          ),
        ],
      ),
    ),
  );
}

  Widget _buildBotaoAcao({
    required String texto,
    required Color cor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 42,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: cor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          texto,
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

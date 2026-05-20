/* Autor: livia */

import 'package:flutter/material.dart';
import 'package:mescla_invest_app/core/widgets/app_bottom_navigation.dart';
import 'package:mescla_invest_app/core/widgets/custom_app_bar.dart';
import 'package:mescla_invest_app/routes/app_routes.dart';

import '../../data/models/board_order_model.dart';
import '../../data/services/exchange_service.dart';
import '../../widgets/exchange_model.dart';

class ExchangeScreen extends StatefulWidget {
  const ExchangeScreen({super.key});

  @override
  State<ExchangeScreen> createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends State<ExchangeScreen> {
  final ExchangeService _exchangeService = ExchangeService();

  Future<Map<String, List<BoardOrderModel>>>? _boardFuture;

  static const Color _primaryColor = Color(0xFF353988);
  static const Color _accentColor = Color(0xFFDB0065);
  static const Color _backgroundColor = Color(0xFFE8E9EB);
  static const Color _sectionBackground = Color(0xFFD7D7D7);
  static const Color _cardBackground = Color(0xFFF7F7F7);

  @override
  void initState() {
    super.initState();
    _boardFuture = _exchangeService.buscarQuadroBalcao();
  }

  Future<void> _recarregarBalcao() async {
    setState(() {
      _boardFuture = _exchangeService.buscarQuadroBalcao();
    });

    await _boardFuture;
  }

  Future<void> _abrirFormularioOrdem({
    required TipoOrdem tipo,
    required ModoOrdem modo,
  }) async {
    try {
      await Navigator.pushNamed(
        context,
        AppRoutes.ordemForm,
        arguments: {
          'tipo': tipo.value,
          'modo': modo.value,
        },
      );

      await _recarregarBalcao();
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Rota ${AppRoutes.ordemForm} ainda não configurada no main.dart.',
          ),
        ),
      );
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
            return Container(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
              decoration: const BoxDecoration(
                color: _backgroundColor,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    const Text(
                      'Como você quer investir?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _primaryColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Selecione a opção desejada',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: Colors.black12),
                    const SizedBox(height: 10),
                    _OpcaoInvestimentoRadio(
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
                    _OpcaoInvestimentoRadio(
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
                        child: const Text(
                          'Avançar',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            }

            final sellOrders = snapshot.data?['sellOrders'] ?? [];
            final buyOrders = snapshot.data?['buyOrders'] ?? [];

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
                    orders: sellOrders,
                  ),
                  const SizedBox(height: 16),
                  _buildSecaoOrdens(
                    titulo: 'Ordens de Compra',
                    descricao:
                        'Confira todas as ofertas de compra de tokens disponíveis atualmente no MesclaInvest.',
                    orders: buyOrders,
                  ),
                  const SizedBox(height: 22),
                  Row(
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
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const AppBottomNavigation(selectedIndex: 2),
    );
  }

  Widget _buildSecaoOrdens({
    required String titulo,
    required String descricao,
    required List<BoardOrderModel> orders,
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
          Text(
            titulo,
            style: const TextStyle(
              color: _primaryColor,
              fontSize: 19,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            descricao,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 11,
              height: 1.18,
            ),
          ),
          const SizedBox(height: 12),
          orders.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    'Nenhuma ordem disponível no momento.',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                )
              : Column(
                  children: orders.map(_buildCardOferta).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildCardOferta(BoardOrderModel order) {
    final bool isAlta = order.appreciated;
    final Color indicatorColor =
        isAlta ? Colors.green.shade700 : Colors.red.shade700;

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
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
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              order.type == 'sell'
                  ? Icons.sell_rounded
                  : Icons.shopping_cart_rounded,
              color: Colors.black,
              size: 19,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.startupName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${order.remainingQuantity} tokens • ${order.tokenName}',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _formatarPrecoCentavos(order.priceCents),
            style: TextStyle(
              color: indicatorColor,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 3),
          Icon(
            isAlta
                ? Icons.arrow_upward_rounded
                : Icons.arrow_downward_rounded,
            color: indicatorColor,
            size: 16,
          ),
        ],
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
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _OpcaoInvestimentoRadio extends StatelessWidget {
  final String titulo;
  final String descricao;
  final ModoOrdem value;
  final ModoOrdem groupValue;
  final ValueChanged<ModoOrdem> onChanged;

  const _OpcaoInvestimentoRadio({
    required this.titulo,
    required this.descricao,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool selecionado = value == groupValue;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => onChanged(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Radio<ModoOrdem>(
              value: value,
              groupValue: groupValue,
              activeColor: const Color(0xFFDB0065),
              visualDensity: VisualDensity.compact,
              onChanged: (value) {
                if (value != null) {
                  onChanged(value);
                }
              },
            ),
            const SizedBox(width: 2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 13,
                      fontWeight:
                          selecionado ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    descricao,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 11,
                      height: 1.15,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
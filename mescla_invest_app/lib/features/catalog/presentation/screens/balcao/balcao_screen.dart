/* Autor: livia */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mescla_invest_app/features/catalog/presentation/widgets/startup_catalog/bottom_catalog_navigation.dart';

import '../../widgets/balcao/balcao_model.dart';

class BalcaoScreen extends StatefulWidget {
  const BalcaoScreen({super.key});

  @override
  State<BalcaoScreen> createState() => _BalcaoScreenState();
}

class _BalcaoScreenState extends State<BalcaoScreen> {
  final CollectionReference<Map<String, dynamic>> _ofertasCollection =
      FirebaseFirestore.instance.collection('balcao_ofertas');

  static const Color _primaryColor = Color(0xFF34368D);
  static const Color _accentColor = Color(0xFFE80070);
  static const Color _backgroundColor = Color(0xFFE6E6E6);
  static const Color _cardBackground = Color(0xFFF7F7F7);

  Stream<List<OfertaBalcao>> _buscarOfertasPorTipo(TipoOrdem tipo) {
    return _ofertasCollection
        .where('tipo', isEqualTo: tipo.value)
        .where('status', isEqualTo: 'aberta')
        .snapshots()
        .map((snapshot) {
      final ofertas = snapshot.docs.map((doc) {
        return OfertaBalcao.fromMap({
          ...doc.data(),
          'id': doc.id,
        });
      }).toList();

      ofertas.sort((a, b) {
        final dataA = a.criadaEm ?? DateTime(2000);
        final dataB = b.criadaEm ?? DateTime(2000);
        return dataB.compareTo(dataA);
      });

      return ofertas;
    });
  }

  Future<void> _navegarPara(String rota) async {
    try {
      await Navigator.pushReplacementNamed(context, rota);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rota $rota ainda não configurada.'),
        ),
      );
    }
  }

  void _onBottomMenuTap(int index) {
    if (index == 3) return;

    if (index == 0) {
      _navegarPara('/home');
      return;
    }

    if (index == 1) {
      _navegarPara('/catalogo');
      return;
    }

    if (index == 2) {
      _navegarPara('/dashboard');
      return;
    }

    if (index == 4) {
      _navegarPara('/wallet');
      return;
    }
  }

  Future<void> _abrirFormularioOrdem({
    required TipoOrdem tipo,
    required ModoOrdem modo,
  }) async {
    try {
      await Navigator.pushNamed(
        context,
        '/ordem-form',
        arguments: {
          'tipo': tipo.value,
          'modo': modo.value,
        },
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Rota /ordem-form ainda não configurada no main.dart.',
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
                    const Row(
                      children: [
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: _primaryColor,
                          size: 28,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Como você quer investir?',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _primaryColor,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Selecione a opção desejada',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  String _formatarPreco(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')} / token';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _primaryColor,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 64,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () {
            _navegarPara('/catalogo');
          },
        ),
        title: const Text(
          'Balcão',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(
              Icons.account_circle_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
          children: [
            _buildSecaoOrdens(
              titulo: 'Ordens de Venda',
              descricao:
                  'Confira todas as ofertas de venda de tokens disponíveis atualmente no MesclaInvest.',
              stream: _buscarOfertasPorTipo(TipoOrdem.venda),
            ),
            const SizedBox(height: 16),
            _buildSecaoOrdens(
              titulo: 'Ordens de Compra',
              descricao:
                  'Confira todas as ofertas de compra de tokens disponíveis atualmente no MesclaInvest.',
              stream: _buscarOfertasPorTipo(TipoOrdem.compra),
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
      ),
      bottomNavigationBar: BottomCatalogNavigation(
        selectedIndex: 3,
        onTap: _onBottomMenuTap,
      ),
    );
  }

  Widget _buildSecaoOrdens({
    required String titulo,
    required String descricao,
    required Stream<List<OfertaBalcao>> stream,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFD7D7D7),
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
          StreamBuilder<List<OfertaBalcao>>(
            stream: stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: _primaryColor,
                    ),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    'Erro ao carregar ordens: ${snapshot.error}',
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }

              final ofertas = snapshot.data ?? [];

              if (ofertas.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    'Nenhuma ordem disponível no momento.',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                );
              }

              return Column(
                children: ofertas.map(_buildCardOferta).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCardOferta(OfertaBalcao oferta) {
    final bool isAlta = oferta.emAlta;

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
            child: const Icon(
              Icons.attach_money_rounded,
              color: Colors.black,
              size: 21,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  oferta.startupNome,
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
                  '${oferta.quantidadeTokens} tokens',
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
            _formatarPreco(oferta.precoUnitario),
            style: TextStyle(
              color: isAlta ? Colors.green.shade700 : Colors.red.shade700,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 3),
          Icon(
            isAlta
                ? Icons.arrow_upward_rounded
                : Icons.arrow_downward_rounded,
            color: isAlta ? Colors.green.shade700 : Colors.red.shade700,
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
              activeColor: const Color(0xFFE80070),
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
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

/// Tela principal do Balcão de negociações.
/// Exibe ordens de compra e venda de tokens de startups,
/// e permite ao usuário criar novas ordens de compra ou venda.
class ExchangeScreen extends StatefulWidget {
  const ExchangeScreen({super.key});

  @override
  State<ExchangeScreen> createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends State<ExchangeScreen> {
  /// Serviço responsável por buscar dados do balcão na API/Firebase.
  final ExchangeService _exchangeService = ExchangeService();

  /// Future que carrega o quadro do balcão (ordens de compra e venda).
  Future<Map<String, List<BoardOrderModel>>>? _boardFuture;

  /// ID da startup usada como filtro (passado via argumentos de rota).
  String? _startupFiltroId;

  /// Nome da startup usada como filtro (passado via argumentos de rota).
  String? _startupFiltroNome;

  /// Flag para evitar que os argumentos de rota sejam lidos mais de uma vez.
  bool _argumentosCarregados = false;

  // --- Paleta de cores da tela ---
  static const Color _primaryColor = Color(0xFF353988);     // Azul escuro principal
  static const Color _accentColor = Color(0xFFDB0065);      // Rosa/vermelho de destaque
  static const Color _backgroundColor = Color(0xFFE8E9EB);  // Fundo geral da tela
  static const Color _sectionBackground = Color(0xFFE8E9EB);// Fundo das seções de ordens
  static const Color _cardBackground = Color(0xFFF4F4F4);   // Fundo dos cards de oferta

  @override
  void initState() {
    super.initState();
    // Inicia o carregamento do quadro do balcão assim que o widget é criado.
    _boardFuture = _exchangeService.buscarQuadroBalcao();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Carrega os argumentos de filtro vindos da rota de navegação.
    _carregarArgumentosFiltro();
  }

  /// Lê os argumentos da rota atual e extrai o ID e nome da startup para filtro.
  /// Executa apenas uma vez graças ao flag [_argumentosCarregados].
  void _carregarArgumentosFiltro() {
    if (_argumentosCarregados) return;

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map<String, dynamic>) {
      _startupFiltroId = args['startupId']?.toString();
      _startupFiltroNome = args['startupName']?.toString();

      final startupData = args['startupData'];

      // Fallback: se o nome não vier direto, tenta extraí-lo do objeto startupData.
      if ((_startupFiltroNome == null || _startupFiltroNome!.trim().isEmpty) &&
          startupData is Map<String, dynamic>) {
        _startupFiltroNome = startupData['name']?.toString();
      }
    }

    _argumentosCarregados = true;
  }

  /// Normaliza uma string: remove espaços extras e converte para minúsculas.
  /// Usado para comparações case-insensitive e tolerantes a espaços.
  String _normalizarTexto(String? valor) {
    if (valor == null) return '';

    return valor
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Normaliza uma string removendo também todos os caracteres não alfanuméricos.
  /// Permite comparar nomes ignorando pontuação, acentos e espaços.
  String _normalizarParaComparacao(String? valor) {
    return _normalizarTexto(valor).replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  /// Filtra a lista de ordens pelo ID ou nome da startup definidos como filtro.
  /// Se nenhum filtro estiver ativo, retorna todas as ordens sem alteração.
  List<BoardOrderModel> _filtrarOrdensPorStartup(
    List<BoardOrderModel> orders,
  ) {
    final filtroId = _startupFiltroId?.trim();
    final filtroNome = _startupFiltroNome?.trim();

    final temFiltroId = filtroId != null && filtroId.isNotEmpty;
    final temFiltroNome = filtroNome != null && filtroNome.isNotEmpty;

    // Sem filtro ativo: retorna tudo.
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

      // Verifica correspondência por ID.
      final idConfere = temFiltroId &&
          orderStartupIdNormalizado == filtroIdNormalizado;

      // Verifica correspondência por nome (com espaços normalizados).
      final nomeConfere = temFiltroNome &&
          orderStartupNameNormalizado == filtroNomeNormalizado;

      // Verifica correspondência por nome (sem caracteres especiais).
      final nomeConfereSemEspacos = temFiltroNome &&
          orderStartupNameComparacao == filtroNomeComparacao;

      // A ordem passa no filtro se qualquer uma das comparações bater.
      return idConfere || nomeConfere || nomeConfereSemEspacos;
    }).toList();
  }

  /// Recarrega os dados do balcão do servidor e atualiza o estado da tela.
  Future<void> _recarregarBalcao() async {
    setState(() {
      _boardFuture = _exchangeService.buscarQuadroBalcao();
    });

    await _boardFuture;
  }

  /// Exibe um diálogo informando que o saldo do usuário é insuficiente
  /// para concluir a operação, com opção de ir direto à carteira.
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
                // Ícone decorativo de carteira
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
                // Botões de ação: cancelar ou ir para a carteira
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

                          // Navega para a tela de carteira.
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

  /// Verifica se um erro capturado corresponde a um erro de saldo insuficiente,
  /// seja via [FirebaseFunctionsException] ou por texto genérico da mensagem.
  bool _erroEhSaldoInsuficiente(Object erro) {
    final textoErro = erro.toString().toLowerCase();

    if (erro is FirebaseFunctionsException) {
      final codigo = erro.code.toLowerCase();
      final mensagem = erro.message?.toLowerCase() ?? '';

      // Código esperado do Firebase para pré-condição não atendida (saldo baixo).
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

    // Fallback para erros não tipados que ainda carregam a mensagem esperada.
    return textoErro.contains('failed-precondition') &&
        (textoErro.contains('saldo insuficiente') ||
            textoErro.contains('saldo suficiente') ||
            textoErro.contains('saldo_insuficiente') ||
            textoErro.contains('insufficient balance'));
  }

  /// Navega para o formulário de criação de ordem (compra ou venda),
  /// aguarda o resultado e recarrega o balcão em seguida.
  /// Caso o retorno ou erro indique saldo insuficiente, exibe o diálogo adequado.
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

      // A tela de formulário pode retornar essa string como sinal de saldo insuficiente.
      if (resultado == 'saldo_insuficiente') {
        _mostrarMensagemSaldoInsuficiente();
        return;
      }

      // Ordem criada com sucesso: recarrega o balcão.
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

  /// Exibe um bottom sheet para o usuário escolher entre
  /// "Ordem a mercado" ou "Ordem limitada" antes de investir.
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
                      // Opção 1: compra pelo preço da startup (mercado).
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
                      // Opção 2: negociação entre investidores (limitada).
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
                      // Botão de confirmação: fecha o modal e abre o formulário.
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

  /// Converte um preço em centavos para o formato monetário brasileiro.
  /// Exemplo: 15050 → "R$ 150,50 / token"
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
                  // Estado de carregamento.
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: _primaryColor),
                    );
                  }

                  // Estado de erro na requisição.
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

                  // Dados carregados: separa e filtra ordens de venda e compra.
                  final todasSellOrders = snapshot.data?['sellOrders'] ?? [];
                  final todasBuyOrders = snapshot.data?['buyOrders'] ?? [];

                  final sellOrders = _filtrarOrdensPorStartup(
                    todasSellOrders,
                  );

                  final buyOrders = _filtrarOrdensPorStartup(
                    todasBuyOrders,
                  );

                  // Lista principal com pull-to-refresh.
                  return RefreshIndicator(
                    color: _primaryColor,
                    onRefresh: _recarregarBalcao,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
                      children: [
                        // Seção de ordens de venda.
                        _buildSecaoOrdens(
                          titulo: 'Ordens de Venda',
                          descricao:
                              'Confira todas as ofertas de venda de tokens disponíveis atualmente no MesclaInvest.',
                          hint: 'Ordens de compra são ofertas criadas pelos usuários para vender seus tokens para outros usuários que criem ordens de compra compatíveis.',
                          orders: sellOrders,
                          isVenda: true,
                        ),
                        const SizedBox(height: 16),
                        // Seção de ordens de compra.
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
            // Barra de ações fixada na parte inferior: Investir e Vender.
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
                        // Venda sempre usa modo limitado.
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

  /// Constrói uma seção do balcão (venda ou compra) com título, descrição,
  /// botão de info e lista horizontal rolável de cards de ordens.
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
              // Botão de informação: abre um AlertDialog explicando o tipo de ordem.
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
          // Exibe mensagem vazia ou lista de cards dependendo da disponibilidade de ordens.
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

/// Constrói um card individual de oferta (ordem de compra ou venda).
/// Exibe nome da startup, quantidade de tokens, nome do token, preço
/// e um ícone de tendência de preço (alta, baixa ou estável).
Widget _buildCardOferta(
  BoardOrderModel order, {
  required bool isVenda,
}) {
  final bool isAlta = order.appreciated;
  final String priceTrend = order.priceTrend;

  // Define a cor do indicador de preço:
  // vermelho para queda, cinza para estável, verde para alta.
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
      
      // Ícone lateral esquerdo fixo.
      leading: const Icon(
        Icons.attach_money_rounded,
        color: Colors.black,
        size: 24,
      ),

      // Título: nome da startup truncado se muito longo.
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

      // Subtítulo: quantidade restante e nome do token.
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

      // Lado direito: preço formatado + ícone de tendência (↑ ↓ ou vazio).
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
              : null, // Sem ícone quando o preço está estável ("equal").
            color: indicatorColor,
            size: 24,
          ),
        ],
      ),
    ),
  );
}

  /// Constrói um botão de ação estilizado (Investir ou Vender)
  /// com cor, texto e callback configuráveis.
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
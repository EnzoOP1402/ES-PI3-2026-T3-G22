/* Autor: Rafael Henrique dos Santos Inácio 
RA: 25009719*/

// Importações de pacotes externos e bibliotecas padrão do Flutter
import 'package:google_fonts/google_fonts.dart';
import 'package:mescla_invest_app/core/utils/snackbar_utils.dart';
import 'package:mescla_invest_app/core/widgets/confirm_exit_dialog.dart';
import 'package:mescla_invest_app/core/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Importações dos modelos, repositórios e widgets específicos da funcionalidade de carteira
import 'package:mescla_invest_app/features/wallet/data/models/offer_model.dart';
import 'package:mescla_invest_app/features/wallet/data/repositories/wallet_repository.dart';
import 'package:mescla_invest_app/features/wallet/presentation/widgets/offers_header.dart';

// Widget Stateful principal responsável por renderizar a tela "Minhas Ofertas"
class MyOffersScreen extends StatefulWidget {
  const MyOffersScreen({super.key});
  @override
  State<MyOffersScreen> createState() => _MyOffersScreenState();
}

// Classe de estado que gerencia a lógica, as variáveis e a interface da tela de ofertas
class _MyOffersScreenState extends State<MyOffersScreen> {
  // Define a cor de fundo padrão utilizada em toda a extensão da tela
  final Color _backgroundColor = const Color(0xFFE6E6E6);

  // Lista simulada de ofertas baseada no seu protótipo
  // Variável que armazenará os dados das ofertas recebidas da API/Repositório
  List<OfferModel> _minhasOfertas = [];

  // Variável de controle de estado para alternar entre a tela de carregamento e a listagem
  bool _isLoading = true;

  // Função auxiliar para formatar valores numéricos (double) para o padrão monetário brasileiro (R$)
  String _formatCurrency(double value) {
    return NumberFormat.simpleCurrency(locale: 'pt_BR').format(value);
  }

  @override
  void initState() {
    super.initState();
    // Dispara a requisição para buscar as ofertas assim que o widget é inserido na árvore
    _loadOffers();
  }

  // Método assíncrono responsável por buscar as ofertas do usuário através do repositório
  Future<void> _loadOffers() async {
    try {
      // Comunica-se com a camada de dados para obter a lista atualizada
      final offers = await WalletRepository.instance.getUserOffers();

      // Atualiza o estado da tela com os dados recebidos e remove o indicador de carregamento
      setState(() {
        _minhasOfertas = offers;
        _isLoading = false;
      });
    } catch (e) {
      // Em caso de erro na requisição, garante que o loading seja desativado
      setState(() {
        _isLoading = false;
      });

      // Exibe uma notificação visual (SnackBar) informando a falha ao usuário
      showErrorSnackBar(context, 'Erro ao carregar ofertas.');
    }
  }

  // Exibe um modal de confirmação (Dialog) antes de permitir o cancelamento de uma oferta
  Future<bool> _confirmCancelOrder(OfferModel offer) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible:
          false, // Impede o fechamento do modal ao tocar fora dele
      builder: (_) {
        return ConfirmExitDialog(
          title: 'Cancelar oferta',
          message:
              'Você está prestes a cancelar sua oferta de ${offer.tokenTicker}.',
          question: 'Tem certeza que deseja continuar?',
          // Retorna 'true' para a chamada original caso o usuário clique em confirmar
          onConfirm: () {
            Navigator.pop(context, true);
          },
          // Retorna 'false' para a chamada original caso o usuário clique em cancelar
          onCancel: () {
            Navigator.pop(context, false);
          },
        );
      },
    );
    // Retorna o resultado da escolha do usuário ou 'false' por segurança caso seja nulo
    return result ?? false;
  }

  // Método assíncrono que processa a exclusão/cancelamento da oferta na camada de dados
  Future<bool> _cancelOffer(OfferModel offer) async {
    try {
      // Aciona o repositório para efetivar o cancelamento no backend utilizando o ID
      await WalletRepository.instance.cancelOrder(orderId: offer.id);
      return true;
    } catch (e) {
      // Se ocorrer uma falha durante o cancelamento, notifica o usuário com o erro retornado
      showErrorSnackBar(context, e.toString());
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold fornece a estrutura visual básica de layout do Material Design
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: CustomAppBar(title: 'Carteira'),

      // Operador ternário de interface: Exibe o indicador circular giratório durante a requisição,
      // caso contrário, constrói o corpo principal da página (Column)
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabeçalho da página
                OffersHeader(),

                // Lista de Ofertas com o Dismissible
                // O widget Expanded garante que a lista ocupe todo o espaço vertical restante disponível
                Expanded(
                  child: _minhasOfertas.isEmpty
                      // Exibe uma mensagem de feedback amigável caso a lista venha vazia
                      ? Center(
                          child: Text(
                            'Você não possui ofertas ativas no momento.',
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        )
                      // Constrói os itens da lista dinamicamente apenas quando são visíveis na tela
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          itemCount: _minhasOfertas.length,
                          itemBuilder: (context, index) {
                            final offer = _minhasOfertas[index];

                            return Dismissible(
                              // A Key é fundamental para o Flutter não se perder ao deletar um item da lista
                              key: Key(offer.id),

                              // Direção de arrastar: startToEnd significa "da esquerda para a direita"
                              direction: DismissDirection.startToEnd,

                              // O fundo vermelho com a lixeira que aparece ao arrastar
                              background: Container(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.red[700],
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),

                              // Função disparada quando o usuário termina de arrastar
                              // Intercepta a ação e aguarda a confirmação no modal antes de prosseguir
                              confirmDismiss: (_) async {
                                final confirmed = await _confirmCancelOrder(
                                  offer,
                                );
                                // Se o usuário desistir no modal, a ação é abortada e o item volta
                                if (!confirmed) {
                                  return false;
                                }
                                // Se confirmado, executa o método de deleção
                                return await _cancelOffer(offer);
                              },

                              // Ação executada imediatamente após o item ser removido visualmente da tela
                              onDismissed: (_) {
                                // Atualiza o estado da UI removendo a oferta cancelada da lista local
                                setState(() {
                                  _minhasOfertas.removeWhere(
                                    (item) => item.id == offer.id,
                                  );
                                });
                                // Exibe a mensagem de sucesso da operação
                                showSuccessSnackBar(
                                  context,
                                  'Oferta de ${offer.tokenTicker} cancelada.',
                                );
                              },

                              // O Card visual da oferta em si
                              // Estrutura o bloco branco contendo as informações da ordem
                              child: Card(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                elevation: 0,
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                  child: Row(
                                    children: [
                                      // Sigla do Token (ex: BTC, ETH)
                                      SizedBox(
                                        width: 60,
                                        child: Text(
                                          offer.tokenTicker,
                                          style: GoogleFonts.montserrat(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),

                                      // Preço e Tipo de Ordem
                                      // O Expanded cria flexibilidade, empurrando a coluna "Quantidade" para o extremo direito
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _formatCurrency(offer.price),
                                              style: GoogleFonts.montserrat(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              offer.orderType,
                                              style: GoogleFonts.montserrat(
                                                color: Colors.grey[600],
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Quantidade de tokens oferecidos
                                      Text(
                                        '${offer.quantity} tokens',
                                        style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

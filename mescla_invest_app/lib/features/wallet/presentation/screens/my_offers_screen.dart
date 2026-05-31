/* Autor: Rafael Henrique dos Santos Inácio */
import 'package:google_fonts/google_fonts.dart';
import 'package:mescla_invest_app/core/utils/snackbar_utils.dart';
import 'package:mescla_invest_app/core/widgets/confirm_exit_dialog.dart';
import 'package:mescla_invest_app/core/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mescla_invest_app/features/wallet/data/models/offer_model.dart';
import 'package:mescla_invest_app/features/wallet/data/repositories/wallet_repository.dart';
import 'package:mescla_invest_app/features/wallet/presentation/widgets/offers_header.dart';

class MyOffersScreen extends StatefulWidget {
  const MyOffersScreen({super.key});

  @override
  State<MyOffersScreen> createState() => _MyOffersScreenState();
}

class _MyOffersScreenState extends State<MyOffersScreen> {
  final Color _backgroundColor = const Color(0xFFE6E6E6);

  // Lista simulada de ofertas baseada no seu protótipo
  List<OfferModel> _minhasOfertas = [];
  bool _isLoading = true;
  String _formatCurrency(double value) {
    return NumberFormat.simpleCurrency(locale: 'pt_BR').format(value);
  }
  @override
  void initState() {
    super.initState();
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    try {
      final offers = await WalletRepository.instance.getUserOffers();

      setState(() {
        _minhasOfertas = offers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      showErrorSnackBar(
        context,
        'Erro ao carregar ofertas.',
      );
    }
  }
  Future<bool>_confirmCancelOrder( OfferModel offer) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) {
      return ConfirmExitDialog(
        title: 'Cancelar oferta',
        message:
            'Você está prestes a cancelar sua oferta de ${offer.tokenTicker}.',
        question:
            'Tem certeza que deseja continuar?',
        onConfirm: () {
          Navigator.pop(
            context,
            true,
          );
        },
        onCancel: () {
          Navigator.pop(
            context,
            false,
          );
        },
      );
    },
  );
  return result ?? false;
}

  Future<bool> _cancelOffer( OfferModel offer,
  ) async {
  try {
    debugPrint(
      'Tentando cancelar ordem ${offer.id}',
    );

    await WalletRepository.instance.cancelOrder(
      orderId: offer.id,
    );

    debugPrint(
      'Ordem cancelada com sucesso',
    );

    return true;
  } catch (e, stackTrace) {
    debugPrint(
      'ERRO AO CANCELAR: $e',
    );

    debugPrint(
      stackTrace.toString(),
    );

    showErrorSnackBar(
      context,
      e.toString(),
    );

    return false;
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: CustomAppBar(
        title: 'Carteira',
      ),
      body:  _isLoading ? const Center(
        child: CircularProgressIndicator(),
      )
      : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho da página
          OffersHeader(),
          // Lista de Ofertas com o Dismissible
          Expanded(
            child: _minhasOfertas.isEmpty
                ? Center(
                    child: Text(
                      'Você não possui ofertas ativas no momento.',
                      style: GoogleFonts.montserrat(fontSize: 16, color: Colors.black),
                    ),
                  )
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
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(
                            Icons.delete_outline,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),

                        // Função disparada quando o usuário termina de arrastar
                        confirmDismiss: (_) async {
                            final confirmed = await _confirmCancelOrder(
                              offer,
                            );
                            if (!confirmed) {
                              return false;
                            }
                            return await _cancelOffer(
                              offer,
                            );
                          },
                          onDismissed: (_) {
                            setState(() {
                              _minhasOfertas.removeWhere(
                                (item) => item.id == offer.id,
                              );
                            });
                            showSuccessSnackBar(
                              context,
                                'Oferta de ${offer.tokenTicker} cancelada.',
                            );
                          },
                        // O Card visual da oferta em si
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
                                // Sigla do Token
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
                                // Quantidade
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
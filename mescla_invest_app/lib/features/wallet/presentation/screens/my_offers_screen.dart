/* Autor: Rafael Henrique dos Santos Inácio */
import 'package:google_fonts/google_fonts.dart';
import 'package:mescla_invest_app/core/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mescla_invest_app/features/wallet/data/models/offer_model.dart';

class MyOffersScreen extends StatefulWidget {
  const MyOffersScreen({super.key});

  @override
  State<MyOffersScreen> createState() => _MyOffersScreenState();
}

class _MyOffersScreenState extends State<MyOffersScreen> {
  final Color _primaryBlue = const Color(0xFF353988);
  final Color _backgroundColor = const Color(0xFFE6E6E6);

  // Lista simulada de ofertas baseada no seu protótipo
  final List<OfferModel> _minhasOfertas = [
    OfferModel(
      id: '1',
      tokenTicker: 'PMTK',
      price: 120.0,
      orderType: 'Ordem de compra',
      quantity: 790,
    ),
    OfferModel(
      id: '2',
      tokenTicker: 'NCTK',
      price: 180.0,
      orderType: 'Ordem de venda',
      quantity: 900,
    ),
    OfferModel(
      id: '3',
      tokenTicker: 'HVTK',
      price: 120.0,
      orderType: 'Ordem de venda',
      quantity: 800,
    ),
    OfferModel(
      id: '4',
      tokenTicker: 'MTTK',
      price: 100.0,
      orderType: 'Ordem de compra',
      quantity: 150,
    ),
    OfferModel(
      id: '5',
      tokenTicker: 'MLTK',
      price: 110.0,
      orderType: 'Ordem de venda',
      quantity: 100,
    ),
  ];

  String _formatCurrency(double value) {
    return NumberFormat.simpleCurrency(locale: 'pt_BR').format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: CustomAppBar(
        title: 'Carteira',
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho da página
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Minhas Ofertas',
                    style: GoogleFonts.montserrat(
                    color: _primaryBlue,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Confira suas ofertas ativas esperando por ser realizadas. Para cancelá-las, basta arrastá-las para a direita.',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Lista de Ofertas com o Dismissible
          Expanded(
            child: _minhasOfertas.isEmpty
                ? Center(
                    child: Text(
                      'Você não possui ofertas ativas no momento.',
                      style: GoogleFonts.montserrat(fontSize: 16, color: Colors.black54),
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
                        onDismissed: (direction) {
                          final removedOffer = offer;
                          final removedIndex = index;

                          setState(() {
                            _minhasOfertas.removeAt(index);
                          });

                          // Feedback visual usando SnackBar (igual ao exemplo do SoccerTeams)
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Oferta de ${removedOffer.tokenTicker} cancelada.',
                              ),
                              duration: const Duration(seconds: 4),
                              action: SnackBarAction(
                                label: 'Desfazer',
                                onPressed: () {
                                  setState(() {
                                    _minhasOfertas.insert(
                                      removedIndex,
                                      removedOffer,
                                    );
                                  });
                                },
                              ),
                            ),
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
/*Gabriela Sichiroli Ferrari*/

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mescla_invest_app/core/utils/currency_formatter.dart';
import '../../data/models/offer_model.dart';

// Widget responsável por exibir as informações
// de uma oferta em formato de cartão.
class OfferCard extends StatelessWidget {

  // Dados da oferta que serão exibidos no card.
  final OfferModel offer;

  const OfferCard({
    super.key,
    required this.offer,
  });

  @override
  Widget build(BuildContext context) {
    return Card(

      // Espaçamento externo entre os cards da lista.
      margin: const EdgeInsets.symmetric(
        vertical: 6,
      ),

      // Remove a sombra padrão do Card.
      elevation: 0,

      // Cor de fundo do card.
      color: Colors.white,

      // Define o arredondamento dos cantos.
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(15),
      ),

      child: Padding(

        // Espaçamento interno do conteúdo.
        padding:
            const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),

        child: Row(
          children: [

            // Exibe o ticker (sigla) do token.
            SizedBox(
              width: 60,
              child: Text(
                offer.tokenTicker,
                style:
                    GoogleFonts.montserrat(
                  fontWeight:
                      FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),

            // Área central que ocupa o espaço restante.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Exibe o preço da oferta.
                  Text(
                    'R\$ ${formatCurrency(offer.price)}',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(
                    height: 2,
                  ),

                  // Exibe o tipo da ordem
                  // (compra ou venda).
                  Text(
                    offer.orderType,
                    style: GoogleFonts.montserrat(
                      color:Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Exibe a quantidade de tokens da oferta.
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
    );
  }
}
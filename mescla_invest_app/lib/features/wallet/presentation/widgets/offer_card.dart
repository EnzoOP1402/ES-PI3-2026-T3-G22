/*Gabriela Sichiroli Ferrari*/

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/offer_model.dart';

class OfferCard extends StatelessWidget {
  final OfferModel offer;

  const OfferCard({
    super.key,
    required this.offer,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        vertical: 6,
      ),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(15),
      ),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        child: Row(
          children: [
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

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    'R\$ ${offer.price.toStringAsFixed(2)}',
                    style:
                        GoogleFonts.montserrat(
                      fontWeight:
                          FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(
                    height: 2,
                  ),

                  Text(
                    offer.orderType,
                    style:
                        GoogleFonts.montserrat(
                      color:
                          Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            Text(
              '${offer.quantity} tokens',
              style:
                  GoogleFonts.montserrat(
                fontWeight:
                    FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
/* Autor: Livia Lucizano */

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mescla_invest_app/core/utils/constants.dart';
import 'package:mescla_invest_app/features/catalog/presentation/widgets/startup_detail/detailed_catalog_card_section.dart';
import 'package:mescla_invest_app/features/catalog/presentation/widgets/startup_detail/detailed_catalog_modal_layout.dart';

class FoundersCard extends StatelessWidget {
  final List<dynamic> socios;

  const FoundersCard({
    super.key,
    required this.socios,
  });

  String _getStringField(
    Map<String, dynamic> data,
    List<String> possibleKeys,
    String fallback,
  ) {
    for (final key in possibleKeys) {
      final value = data[key];

      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }

    return fallback;
  }

  dynamic _getValueField(
    Map<String, dynamic> data,
    List<String> possibleKeys,
  ) {
    for (final key in possibleKeys) {
      final value = data[key];

      if (value != null && value.toString().trim().isNotEmpty) {
        return value;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return DetailedCatalogCardSection(
      title: 'Sócios',
      children: socios.isEmpty
          ? [
              Text(
                'Nenhum sócio cadastrado.',
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  color: Colors.black,
                ),
              ),
            ]
          : socios.map((socio) {
              final data = Map<String, dynamic>.from(socio);

              final nome = _getStringField(
                data,
                ['name'],
                'Nome não informado',
              );

              final cargo = _getStringField(
                data,
                ['role'],
                'Cargo não informado',
              );

              final bio = _getStringField(
                data,
                ['bio'],
                'Descrição não informada',
              );

              final participacao = _getValueField(
                data,
                ['equityPercent'],
              );

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color(0xFFF4F4F4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 18,
                      backgroundColor: primaryColor,
                      child: Icon(
                        Icons.person_outline,
                        color: backgroundColor,
                        size: 20,
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nome,
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),

                          const SizedBox(height: 2),

                          Text(
                            cargo,
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          if (participacao != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Participação societária: $participacao%',
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    IconButton(
                      onPressed: () {
                        showModalBottomSheet<void>(
                          isScrollControlled: true,
                          context: context,
                          builder: (BuildContext context) {
                            return StatefulBuilder(
                              builder: (BuildContext context, StateSetter setModalState) {

                                return DetailedCatalogModalLayout(
                                  title: nome,
                                  subtitle: cargo,
                                  // Conteúdo do modal
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 20),
                                      child: Expanded(
                                        // Perguntas
                                        child: Text(
                                          bio,
                                          style: GoogleFonts.montserrat(
                                            fontSize: 14,
                                            color: Colors.black,
                                          ),
                                        )
                                      ),
                                    ),
                                  ]
                                );  
                              },
                            );
                          },
                        );
                      },
                      icon: Icon(Icons.arrow_forward_ios),
                      color: primaryColor,
                    )
                  ],
                ),
              );
            }).toList(),
    );
  }
}
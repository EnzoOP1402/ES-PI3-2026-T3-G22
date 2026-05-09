/* Autor: Livia Lucizano */

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mescla_invest_app/features/catalog/presentation/widgets/detailed_catalog_card_section.dart';

class PartnersCard extends StatelessWidget {
  final List<dynamic> socios;

  const PartnersCard({
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
                  color: Colors.black87,
                ),
              ),
            ]
          : socios.map((socio) {
              final data = Map<String, dynamic>.from(socio);

              final nome = _getStringField(
                data,
                ['name', 'nome'],
                'Nome não informado',
              );

              final cargo = _getStringField(
                data,
                ['role', 'cargo'],
                'Cargo não informado',
              );

              final bio = _getStringField(
                data,
                ['bio', 'descricao', 'description'],
                '',
              );

              final participacao = _getValueField(
                data,
                ['equityPercent', 'participacao'],
              );

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 18,
                      backgroundColor: Color(0xFF353988),
                      child: Icon(
                        Icons.person_outline,
                        color: Colors.white,
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
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),

                          const SizedBox(height: 2),

                          Text(
                            cargo,
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          if (participacao != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Participação: $participacao%',
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],

                          if (bio.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              bio,
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                color: Colors.black87,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
    );
  }
}
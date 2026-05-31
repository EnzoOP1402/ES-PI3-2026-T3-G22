/* Autor: Livia Lucizano */

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mescla_invest_app/core/utils/constants.dart';
import 'package:mescla_invest_app/features/catalog/presentation/widgets/startup_detail/detailed_catalog_card_section.dart';

class ExternalMembersCard extends StatelessWidget {
  final List<dynamic> membrosExternos;

  const ExternalMembersCard({
    super.key,
    required this.membrosExternos,
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

  @override
  Widget build(BuildContext context) {
    return DetailedCatalogCardSection(
      title: 'Membros externos',
      children: membrosExternos.isEmpty
          ? [
              Text(
                'Nenhum membro externo cadastrado.',
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  color: Colors.black,
                ),
              ),
            ]
          : membrosExternos.map((membro) {
              final data = Map<String, dynamic>.from(membro);

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

              final organizacao = _getStringField(
                data,
                ['organization'],
                '',
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
                        Icons.groups_2_outlined,
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
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),

                          const SizedBox(height: 2),

                          Text(
                            cargo,
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          if (organizacao.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              organizacao,
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
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
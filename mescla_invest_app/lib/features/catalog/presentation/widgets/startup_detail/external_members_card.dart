/* Autor: Livia Lucizano */

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mescla_invest_app/features/catalog/presentation/widgets/detailed_catalog_card_section.dart';

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
                  color: Colors.black87,
                ),
              ),
            ]
          : membrosExternos.map((membro) {
              final data = Map<String, dynamic>.from(membro);

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

              final organizacao = _getStringField(
                data,
                ['organization', 'organizacao'],
                '',
              );

              final descricao = _getStringField(
                data,
                ['description', 'descricao', 'bio'],
                '',
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

                          if (organizacao.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              organizacao,
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],

                          if (descricao.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              descricao,
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
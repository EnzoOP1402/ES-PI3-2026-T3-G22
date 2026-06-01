/* Autor: Livia Lucizano RA:25017514*/

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mescla_invest_app/core/utils/constants.dart';
import 'package:mescla_invest_app/features/catalog/presentation/widgets/startup_detail/detailed_catalog_card_section.dart';
import 'package:mescla_invest_app/features/catalog/presentation/widgets/startup_detail/detailed_catalog_modal_layout.dart';

/// Card que exibe a lista de sócios de uma startup na tela de detalhes.
/// Cada sócio é renderizado como um item com avatar, nome, cargo e participação,
/// e permite abrir um modal com a bio completa ao tocar na seta.
class FoundersCard extends StatelessWidget {
  /// Lista de sócios da startup, onde cada item é um mapa de dados dinâmicos.
  final List<dynamic> socios;

  const FoundersCard({
    super.key,
    required this.socios,
  });

  /// Busca um campo de texto no [data] tentando múltiplas chaves possíveis.
  /// Retorna [fallback] se nenhuma chave produzir um valor não vazio.
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

  /// Busca um campo de valor genérico no [data] tentando múltiplas chaves possíveis.
  /// Retorna null se nenhuma chave produzir um valor não vazio.
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
      // Exibe mensagem vazia ou mapeia cada sócio para um card.
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

              // Extrai os campos do sócio com fallbacks para valores ausentes.
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

              // Participação societária é opcional: exibida apenas se presente.
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
                    // Avatar padrão com ícone de pessoa.
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
                          // Nome do sócio em destaque.
                          Text(
                            nome,
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),

                          const SizedBox(height: 2),

                          // Cargo do sócio.
                          Text(
                            cargo,
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          // Participação societária: exibida apenas se o campo existir.
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

                    // Botão de seta: abre modal com a bio completa do sócio.
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
                                  // Conteúdo do modal: bio completa do sócio.
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 20),
                                      child: Expanded(
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
/* Autor: Livia Lucizano RA:25017514 */

// Imports usados para construir a interface e aplicar estilos do projeto
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mescla_invest_app/core/utils/constants.dart';
import 'package:mescla_invest_app/features/catalog/presentation/widgets/startup_detail/detailed_catalog_card_section.dart';

// Widget responsável por exibir a lista de membros externos da startup
class ExternalMembersCard extends StatelessWidget {
  // Lista com os membros externos recebidos do backend
  final List<dynamic> membrosExternos;

  const ExternalMembersCard({
    super.key,
    required this.membrosExternos,
  });

  // Função auxiliar para buscar um texto dentro de um Map
  String _getStringField(
    Map<String, dynamic> data,
    List<String> possibleKeys,
    String fallback,
  ) {
    // Percorre possíveis nomes de campos até encontrar um valor válido
    for (final key in possibleKeys) {
      final value = data[key];

      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }

    // Retorna um texto padrão caso nenhum valor seja encontrado
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    return DetailedCatalogCardSection(
      title: 'Membros externos',

      // Se não houver membros, exibe uma mensagem informativa
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

          // Caso existam membros, cria um card para cada um
          : membrosExternos.map((membro) {
              final data = Map<String, dynamic>.from(membro);

              // Obtém o nome do membro externo
              final nome = _getStringField(
                data,
                ['name'],
                'Nome não informado',
              );

              // Obtém o cargo do membro externo
              final cargo = _getStringField(
                data,
                ['role'],
                'Cargo não informado',
              );

              // Obtém a organização, caso exista
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

                // Conteúdo visual do membro externo
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Ícone representando o membro externo
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

                    // Informações textuais do membro externo
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nome do membro
                          Text(
                            nome,
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),

                          const SizedBox(height: 2),

                          // Cargo do membro
                          Text(
                            cargo,
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          // Organização vinculada ao membro, se houver
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
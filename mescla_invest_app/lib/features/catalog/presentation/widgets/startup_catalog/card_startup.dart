/* Autor: Livia Lucizano - RA:25017514 */

// Imports necessários para construção da interface do card de startup
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mescla_invest_app/features/catalog/data/models/startup_model.dart';
import 'package:mescla_invest_app/features/catalog/presentation/widgets/startup_catalog/mini_info.dart';

// Widget responsável por exibir um card resumido de uma startup no catálogo
class CardStartup extends StatefulWidget {
  // Dados da startup que serão exibidos no card
  final StartupModel startup;

  // Função executada ao abrir os detalhes da startup
  final VoidCallback onOpenDetails;

  const CardStartup({
    super.key,
    required this.startup,
    required this.onOpenDetails,
  });

  @override
  State<CardStartup> createState() => _CardStartupState();
}

class _CardStartupState extends State<CardStartup> {
  // Controla se as informações extras estão expandidas ou recolhidas
  bool expandido = false;

  // Converte valores armazenados em centavos para formato monetário
  String _formatCurrencyFromCents(num cents) {
    final value = cents / 100;
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  Widget build(BuildContext context) {
    // Facilita o acesso aos dados da startup
    final startup = widget.startup;

    return Card(
      // Configuração visual do card
      color: const Color(0xFFF4F4F4),
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,

      child: InkWell(
        // Permite clicar em todo o card
        borderRadius: BorderRadius.circular(14),
        onTap: widget.onOpenDetails,

        child: Padding(
          padding: const EdgeInsets.all(12),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Área principal do card
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ícone padrão da startup
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.business_rounded,
                      color: Color(0xFF353988),
                      size: 24,
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Informações principais da startup
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nome da startup
                        Text(
                          startup.name,
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),

                        const SizedBox(height: 4),

                        // Breve descrição da startup
                        Text(
                          startup.shortDescription,

                          // Quando expandido mostra tudo, caso contrário limita a duas linhas
                          maxLines: expandido ? null : 2,

                          overflow: expandido
                              ? TextOverflow.visible
                              : TextOverflow.ellipsis,

                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            color: Colors.black,
                            height: 1.25,
                          ),
                        ),

                        const SizedBox(height: 6),

                        // Exibe o estágio atual da startup
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFC3C0FF),
                            borderRadius: BorderRadius.circular(7.5),
                          ),
                          child: Text(
                            StartupModel.formatStage(startup.stage),
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Botão para expandir ou recolher informações adicionais
                  IconButton(
                    icon: Icon(
                      expandido
                          ? Icons.close_fullscreen_rounded
                          : Icons.open_in_full_rounded,
                      color: Colors.black,
                      size: 20,
                    ),

                    onPressed: () {
                      setState(() {
                        expandido = !expandido;
                      });
                    },
                  ),
                ],
              ),

              // Área expandida com informações complementares
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),

                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 5),

                  child: Column(
                    children: [
                      // Indicadores financeiros resumidos
                      Row(
                        children: [
                          const SizedBox(width: 48),

                          Expanded(
                            child: MiniInfo(
                              label: 'Tokens emitidos',
                              value:
                                  '${startup.totalTokensIssued} tokens',
                              titleSize: 12,
                              contentSize: 16,
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: MiniInfo(
                              label: 'Capital aportado',
                              value: _formatCurrencyFromCents(
                                startup.capitalRaisedCents,
                              ),
                              titleSize: 12,
                              contentSize: 16,
                            ),
                          ),
                        ],
                      ),

                      // Exibe as tags da startup, caso existam
                      if (startup.tags.isNotEmpty) ...[
                        const SizedBox(height: 4),

                        Row(
                          children: [
                            SizedBox(width: 50,),

                            Align(
                              alignment: Alignment.centerLeft,

                              child: Wrap(
                                spacing: 6,
                                runSpacing: 6,

                                children: startup.tags.map((tag) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),

                                    decoration: BoxDecoration(
                                      color: Color(0xFF9FCEFF),
                                      borderRadius: BorderRadius.circular(7.5),
                                    ),

                                    child: Text(
                                      tag,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 10),
                    ],
                  ),
                ),

                // Define qual conteúdo será mostrado
                crossFadeState: expandido
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,

                // Duração da animação
                duration: const Duration(milliseconds: 250),
              ),

              // Botão para acessar a tela completa de detalhes
              Align(
                alignment: Alignment.centerRight,

                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF353988),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),

                  onPressed: widget.onOpenDetails,

                  child: Text(
                    'Ver Mais',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
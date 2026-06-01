/* Autor: Livia Lucizano RA:25017514 */

// Imports usados para montar a interface dos filtros do catálogo
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mescla_invest_app/core/utils/constants.dart';
import 'package:mescla_invest_app/features/catalog/presentation/widgets/startup_catalog/stage_chip.dart';

// Widget responsável por exibir o campo de pesquisa e os filtros por estágio
class CatalogFilters extends StatelessWidget {
  // Controla o texto digitado no campo de pesquisa
  final TextEditingController searchController;

  // Guarda qual filtro de estágio está selecionado
  final String selectedStage;

  // Função chamada ao realizar a pesquisa
  final VoidCallback onSearch;

  // Função chamada quando o texto da pesquisa muda
  final ValueChanged<String> onSearchChanged;

  // Função chamada para limpar os filtros
  final VoidCallback onClear;

  // Função chamada ao selecionar um estágio
  final ValueChanged<String> onStageChanged;

  const CatalogFilters({
    super.key,
    required this.searchController,
    required this.selectedStage,
    required this.onSearch,
    required this.onSearchChanged,
    required this.onClear,
    required this.onStageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Campo de texto usado para pesquisar startups pelo nome
        TextField(
          controller: searchController,
          textInputAction: TextInputAction.search,

          // Executa a busca enquanto o usuário digita
          onChanged: onSearchChanged,

          // Executa a busca ao apertar "pesquisar" no teclado
          onSubmitted: (_) => onSearch(),

          decoration: InputDecoration(
            hintText: 'Pesquisar Startup',
            hintStyle: GoogleFonts.montserrat(
              color: Colors.black54,
              fontSize: 13,
            ),

            // Ícone de pesquisa no início do campo
            prefixIcon: const Icon(
              Icons.search,
              color: Color(0xFF353988),
            ),

            // Ícone para limpar o texto quando houver algo digitado
            suffixIcon: searchController.text.isEmpty
                ? null
                : IconButton(
                    onPressed: onClear,
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF353988),
                    ),
                  ),

            // Estilização visual do campo
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Lista horizontal com os filtros de estágio da startup
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Filtro para exibir todas as startups
              StageChip(
                label: 'Todas',
                value: 'todos',
                selectedValue: selectedStage,
                onSelected: onStageChanged,
              ),

              filterSpacing,

              // Filtro para startups em operação
              StageChip(
                label: 'Em operação',
                value: 'em_operacao',
                selectedValue: selectedStage,
                onSelected: onStageChanged,
              ),

              filterSpacing,

              // Filtro para startups em expansão
              StageChip(
                label: 'Em expansão',
                value: 'em_expansao',
                selectedValue: selectedStage,
                onSelected: onStageChanged,
              ),

              filterSpacing,

              // Filtro para startups novas
              StageChip(
                label: 'Nova',
                value: 'nova',
                selectedValue: selectedStage,
                onSelected: onStageChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
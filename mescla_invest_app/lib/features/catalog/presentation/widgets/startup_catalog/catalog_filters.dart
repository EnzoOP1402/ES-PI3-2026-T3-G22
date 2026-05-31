/* Autor: Livia Lucizano */

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mescla_invest_app/core/utils/constants.dart';
import 'package:mescla_invest_app/features/catalog/presentation/widgets/startup_catalog/stage_chip.dart';

class CatalogFilters extends StatelessWidget {
  final TextEditingController searchController;
  final String selectedStage;
  final VoidCallback onSearch;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClear;
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
        TextField(
          controller: searchController,
          textInputAction: TextInputAction.search,
          onChanged: onSearchChanged,
          onSubmitted: (_) => onSearch(),
          decoration: InputDecoration(
            hintText: 'Pesquisar Startup',
            hintStyle: GoogleFonts.montserrat(
              color: Colors.black54,
              fontSize: 13,
            ),
            prefixIcon: const Icon(
              Icons.search,
              color: Color(0xFF353988),
            ),
            suffixIcon: searchController.text.isEmpty
                ? null
                : IconButton(
                    onPressed: onClear,
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF353988),
                    ),
                  ),
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

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              StageChip(
                label: 'Todas',
                value: 'todos',
                selectedValue: selectedStage,
                onSelected: onStageChanged,
              ),
              filterSpacing,
              StageChip(
                label: 'Em operação',
                value: 'em_operacao',
                selectedValue: selectedStage,
                onSelected: onStageChanged,
              ),
              filterSpacing,
              StageChip(
                label: 'Em expansão',
                value: 'em_expansao',
                selectedValue: selectedStage,
                onSelected: onStageChanged,
              ),
              filterSpacing,
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
/*Autor: Gabriela Sichiroli Ferrari - RA: 25013763 */

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mescla_invest_app/core/widgets/app_bottom_navigation.dart';
import 'package:mescla_invest_app/core/widgets/custom_app_bar.dart';
import 'package:mescla_invest_app/features/wallet/data/models/transaction_model.dart';
import 'package:mescla_invest_app/features/wallet/data/repositories/wallet_repository.dart';
import 'package:mescla_invest_app/features/wallet/presentation/widgets/transaction_list.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => TransactionHistoryScreenState();
}

class TransactionHistoryScreenState extends State<TransactionHistoryScreen> {

  // Future responsável por armazenar a lista de transações
  // obtida do repositório.
  late Future<List<TransactionModel>> _transactionsFuture;

  @override
  void initState() {
    super.initState();

    // Carrega o histórico de transações assim que a tela é iniciada.
    _transactionsFuture = WalletRepository.instance
        .getTransactionHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Cor de fundo da tela.
      backgroundColor: Color(0xFFE6E6E6),

      // Barra superior personalizada.
      appBar: CustomAppBar(
        title: 'Histórico de Transações',
      ),

      // Conteúdo principal da tela.
      body: Padding(
        padding: const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Título principal da página.
            Text(
              'Minhas Transações',
              style: GoogleFonts.montserrat(
                fontSize: 27,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF353988),
              ),
            ),

            const SizedBox(height: 8),

            // Texto explicativo para o usuário.
            Text(
              'Confira todas as transações realizadas por você e pelas ordens que você criou.',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 24),

            // Área que ocupa o restante da tela.
            Expanded(
              child: FutureBuilder<List<TransactionModel>>(
                future: _transactionsFuture,
                builder: (context, snapshot) {

                  // Exibe indicador de carregamento enquanto os dados
                  // estão sendo buscados.
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  // Exibe mensagem caso ocorra algum erro.
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        snapshot.error.toString(),
                      ),
                    );
                  }

                  // Exibe mensagem quando não há transações.
                  if (!snapshot.hasData ||
                      snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        'Nenhuma transação encontrada',
                        style: GoogleFonts.montserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }

                  // Exibe a lista de transações quando os dados
                  // são carregados com sucesso.
                  return TransactionList(
                    transactions: snapshot.data!,
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // Barra de navegação inferior da aplicação.
      bottomNavigationBar: const AppBottomNavigation(
        selectedIndex: 4,
      ),
    );
  }
}
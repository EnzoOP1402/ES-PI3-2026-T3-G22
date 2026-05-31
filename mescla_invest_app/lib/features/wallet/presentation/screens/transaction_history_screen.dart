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
  State<TransactionHistoryScreen> createState() =>
      TransactionHistoryScreenState();
}

class TransactionHistoryScreenState
    extends State<TransactionHistoryScreen> {

  late Future<List<TransactionModel>>
      _transactionsFuture;

  @override
  void initState() {
    super.initState();

    _transactionsFuture =
        WalletRepository.instance
            .getTransactionHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE6E6E6),
      appBar: CustomAppBar(
        title: 'Histórico de Transações',
      ),
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
            Text(
              'Minhas Transações',
              style: GoogleFonts.montserrat(
                fontSize: 27,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF353988),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Confira todas as transações realizadas por você e pelas ordens que você criou.',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 24),
            Expanded(
              child: FutureBuilder<List<TransactionModel>>(
                future: _transactionsFuture,
                builder: (context,snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        snapshot.error.toString(),
                      ),
                    );
                  }
                  if (!snapshot.hasData ||
                      snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        'Nenhuma transação encontrada',
                        style:
                          GoogleFonts.montserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }
                  return TransactionList(
                    transactions: snapshot.data!,
                  );
                },
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: const AppBottomNavigation(
        selectedIndex: 4,
      ),
    );
  }
}
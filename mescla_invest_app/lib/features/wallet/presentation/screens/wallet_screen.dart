import 'package:flutter/material.dart';
import 'package:mescla_invest_app/core/widgets/app_bottom_navigation.dart';
import 'package:mescla_invest_app/core/widgets/custom_app_bar.dart';

class WalletScreen  extends StatelessWidget {

  const WalletScreen({super.key,});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Carteira',
      ),
      body: const Center(
        child: Text(
          'Tela Carteira',
        ),
      ),
      bottomNavigationBar:
        const AppBottomNavigation(
        selectedIndex: 4,
      ),
    );
  }
}
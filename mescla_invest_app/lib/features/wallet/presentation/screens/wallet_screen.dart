import 'package:flutter/material.dart';
import 'package:mescla_invest_app/core/widgets/app_bottom_navigation.dart';

class WalletScreen  extends StatelessWidget {

  const WalletScreen({super.key,});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Carteira',
        ),
      ),
      body: const Center(
        child: Text(
          'Tela Carteira',
          style: TextStyle(fontSize: 24),
        ),
      ),
      bottomNavigationBar:
        const AppBottomNavigation(
        selectedIndex: 3,
      ),
    );
  }
}
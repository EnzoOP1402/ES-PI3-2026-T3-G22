import 'package:flutter/material.dart';
import 'package:mescla_invest_app/core/widgets/app_bottom_navigation.dart';
import 'package:mescla_invest_app/core/widgets/custom_app_bar.dart';

class ExchangeScreen extends StatelessWidget {
  const ExchangeScreen ({super.key});
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: CustomAppBar(
        title:'Balcão',
      ),

      body: const Center(
        child: Text(
          'Tela Balcão',
          style: TextStyle(fontSize: 24),
        ),
      ),
      bottomNavigationBar:
        const AppBottomNavigation(
        selectedIndex: 2,
      ),
    );
  }
}
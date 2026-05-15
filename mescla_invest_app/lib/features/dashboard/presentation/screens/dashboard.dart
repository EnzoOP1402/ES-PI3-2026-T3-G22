import 'package:flutter/material.dart';
import 'package:mescla_invest_app/core/widgets/app_bottom_navigation.dart';
import 'package:mescla_invest_app/core/widgets/custom_app_bar.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: CustomAppBar(
        title:'DashBoard',
      ),

      body: const Center(
        child: Text(
          'Tela DashBoard',
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
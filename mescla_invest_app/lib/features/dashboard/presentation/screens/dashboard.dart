import 'package:flutter/material.dart';
import 'package:mescla_invest_app/core/widgets/app_bottom_navigation.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('DashBoard'),
      ),

      body: const Center(
        child: Text(
          'Tela DashBoard',
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
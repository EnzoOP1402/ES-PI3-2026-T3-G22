import 'package:flutter/material.dart';
import 'package:mescla_invest_app/core/widgets/app_bottom_navigation.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),

      body: const Center(
        child: Text(
          'Tela Home',
          style: TextStyle(fontSize: 24),
        ),
      ),
    bottomNavigationBar:
    const AppBottomNavigation(
      selectedIndex: 0,
      ),
    );
  }
}
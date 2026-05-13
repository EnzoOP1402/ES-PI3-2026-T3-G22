import 'package:flutter/material.dart';
import 'package:mescla_invest_app/core/widgets/app_bottom_navigation.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
      ),

      body: const Center(
        child: Text(
          'Tela Perfil',
          style: TextStyle(fontSize: 24),
        ),
      ),
        bottomNavigationBar:
        const AppBottomNavigation(
        selectedIndex: 4,
      ),
    );
  }
}
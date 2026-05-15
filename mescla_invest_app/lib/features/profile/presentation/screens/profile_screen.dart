import 'package:flutter/material.dart';
import 'package:mescla_invest_app/features/auth/data/repositories/auth_repository.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
          Navigator.pop(context);
          },
        ),
        // BOTÃO LOGOUT
        actions: [
          IconButton(
          onPressed: AuthRepository.instance.logout,
          icon: const Icon(
            Icons.logout_rounded,
            color: Colors.white,
          ),
        ),
        ]
      ),
      body: const Center(
        child: Text('Tela de Perfil'),
      ),
    );
  }
}
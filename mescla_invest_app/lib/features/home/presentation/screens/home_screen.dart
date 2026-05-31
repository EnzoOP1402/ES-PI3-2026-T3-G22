import 'package:flutter/material.dart';
import 'package:mescla_invest_app/core/utils/snackbar_utils.dart';
import 'package:mescla_invest_app/core/widgets/app_bottom_navigation.dart';
import 'package:mescla_invest_app/core/widgets/custom_app_bar.dart';
import 'package:mescla_invest_app/features/auth/data/repositories/auth_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _handleLogout() async {
    try {
      // Efetua o sign out no Firebase Auth
      await AuthRepository.instance.logout();

      if (mounted) {
        // Voltando para o início da pilha (tela inicial)
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(context, 'Erro ao sair: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Home'),

      body: Center(
        child: Column(
          children: [
            const Text('Tela Home', style: TextStyle(fontSize: 24)),
            TextButton(onPressed: () async => _handleLogout(), child: const Text("Sair")),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigation(selectedIndex: 0),
    );
  }
}

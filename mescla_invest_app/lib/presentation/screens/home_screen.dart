import 'package:flutter/material.dart';
import 'package:mescla_invest_app/data/repositories/auth_repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Início'),
        actions: [
          TextButton.icon(
            onPressed: AuthRepository.instance.logout,
            label: Icon(Icons.logout)
          )
        ],
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          TextButton.icon(onPressed: AuthRepository.instance.logout, label: Icon(Icons.logout))
        ],
      ),
    );
  }
}
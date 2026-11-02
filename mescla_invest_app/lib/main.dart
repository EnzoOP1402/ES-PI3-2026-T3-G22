/* Autor original: Enzo Olivato Pazian - 25001654 */
// HISTÓRICO DE ALTERAÇÕES
// 02/11/2026 — Gabriela Sichiroli Ferrari (RA 25013763): main limitado à inicialização do Firebase e do app.
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mescla_invest_app/app/app.dart';
import 'firebase_options.dart';

// Reexporta para preservar eventuais imports antigos de main.dart.
export 'package:mescla_invest_app/app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MesclaInvest());
}

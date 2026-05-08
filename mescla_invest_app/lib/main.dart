import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';

import 'firebase_options.dart';

import 'package:mescla_invest_app/core/widgets/auth_wrapper.dart';
import 'package:mescla_invest_app/features/auth/presentation/screens/login_screen.dart';
import 'package:mescla_invest_app/features/auth/presentation/screens/register_screen.dart';
import 'package:mescla_invest_app/features/auth/presentation/screens/password_recovery_screen.dart';
import 'package:mescla_invest_app/features/catalog/presentation/screens/startup_catalog_screen.dart';
import 'package:mescla_invest_app/features/catalog/presentation/screens/startup_detail_screen.dart';
import 'package:mescla_invest_app/routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MesclaInvestApp());
}

class MesclaInvestApp extends StatelessWidget {
  const MesclaInvestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mescla Invest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.montserratTextTheme(),
      ),

      // Aqui volta para o fluxo normal do app
      home: const AuthWrapper(),

      routes: {
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.register: (context) => const RegisterScreen(),
        AppRoutes.passwordRecovery: (context) => const PasswordRecoveryScreen(),
        AppRoutes.catalog: (context) => const Catalogo(),
      },

      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.startupDetail) {
          final startupId = settings.arguments as String;

          return MaterialPageRoute(
            builder: (context) => StartupDetailScreen(
              startupId: startupId,
            ),
          );
        }

        return null;
      },
    );
  }
}
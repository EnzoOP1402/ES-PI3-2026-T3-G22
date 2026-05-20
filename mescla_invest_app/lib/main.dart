/* Autor: Enzo Olivato Pazian */

// Importação das dependências
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mescla_invest_app/core/widgets/auth_wrapper.dart';
import 'package:mescla_invest_app/features/auth/presentation/screens/welcome_screen.dart';
import 'package:mescla_invest_app/features/auth/presentation/screens/login_screen.dart';
import 'package:mescla_invest_app/features/auth/presentation/screens/password_recovery_screen.dart';
import 'package:mescla_invest_app/features/auth/presentation/screens/register_screen.dart';
import 'package:mescla_invest_app/features/dashboard/presentation/screens/dashboard.dart';
import 'package:mescla_invest_app/features/exchange/presentation/screens/exchange.dart';
import 'package:mescla_invest_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:mescla_invest_app/features/home/presentation/screens/home_screen.dart';
import 'package:mescla_invest_app/features/catalog/presentation/screens/startup_catalog_screen.dart';
import 'package:mescla_invest_app/features/wallet/presentation/screens/wallet_screen.dart';
import 'package:mescla_invest_app/routes/app_routes.dart';
import 'firebase_options.dart';

// Função principal:++ ponto de entrada da aplicação
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Função responsável por executar a aplicação
  runApp(const MesclaInvest());
}

// Widget que representa a aplicação
class MesclaInvest extends StatelessWidget {
  // Construtor da aplicação (herda o atributo key de sua superclasse)
  const MesclaInvest({super.key});

  // Raiz da aplicação
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MesclaInvest',
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.montserratTextTheme(),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            textStyle: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            textStyle: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (_) => const AuthWrapper(),
        AppRoutes.login: (_) => LoginScreen(),
        AppRoutes.register: (_) => RegisterScreen(),
        AppRoutes.recover: (_) => PasswordRecoveryScreen(),
        AppRoutes.catalog: (_) => const Catalogo(),
        AppRoutes.home: (_) => const HomeScreen(),
        AppRoutes.profile: (_) => const ProfileScreen(),
        AppRoutes.dashboard:(_) => const DashboardScreen(),
        AppRoutes.wallet:(_) => const WalletScreen(),
        AppRoutes.exchange:(_) => const ExchangeScreen(),
        } ,
    );
  }
}
/* Autor: Enzo Olivato Pazian */

// Importação das dependências
import 'package:flutter/material.dart';
import 'package:mescla_invest_app/TelaRecepcao.dart';
import 'package:mescla_invest_app/features/catalog/presentation/screens/startup_catalog_screen.dart';
import 'package:firebase_core/firebase_core.dart';
// Função principal: ponto de entrada da aplicação
void main() async{
  await Firebase.initializeApp();
  // Função responsável por executar a aplicação
  runApp(const MesclaInvest());
}

// Widget que representa a aplicação
class MesclaInvest extends StatelessWidget {
  // Construtor da aplicação (herda o atributo key de sua superclasse)
  const MesclaInvest({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TelaMenu(),
    );
  }
}

class TelaMenu extends StatefulWidget {
  const TelaMenu({super.key});

  @override
  State<TelaMenu> createState() => _TelaMenuState();
}

class _TelaMenuState extends State<TelaMenu> {
  bool mostrarSaldo = false;
  // Raiz da aplicação
  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF34379B);
    return Scaffold(
      backgroundColor: const Color(0xFFD9D9D9),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 4),
              // Card superior
              Container(
                decoration: BoxDecoration(color: Colors.grey[300]),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: const BoxDecoration(
                        color: primaryBlue,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(22),
                          topRight: Radius.circular(22),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'MesclaInvest',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    const Text(
                      'Saldo do Usuário:',
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      mostrarSaldo ? 'R\$15.670,98' : '— —',
                      style: const TextStyle(fontSize: 18, color: Colors.black),
                    ),

                    const SizedBox(height: 7),

                    GestureDetector(
                      onTap: () {
                        setState(() {
                          mostrarSaldo = !mostrarSaldo;
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            mostrarSaldo
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 18,
                            color: Colors.black54,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            mostrarSaldo ? 'Mostrar' : 'Ocultar',
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    Divider(height: 1, thickness: 1, color: Colors.black),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Explore Mais
              const Text(
                'Explore Mais:',
                style: TextStyle(
                  color: primaryBlue,
                  fontSize: 28,
                  fontWeight: FontWeight.w300,
                ),
              ),

              const SizedBox(height: 40),

              // 6 Botões
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MenuButton(
                          icon: Icons.lightbulb_outline,
                          label: 'Catálogo',
                          onTap: () {
                            Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const Catalogo(),
                                                  ),
                                                );

                          },
                        ),

                        const SizedBox(width: 10),

                        MenuButton(
                          icon: Icons.chair_alt_outlined,
                          label: 'Balcão',
                          onTap: () {},
                        ),

                        const SizedBox(width: 10),

                        MenuButton(
                          icon: Icons.account_balance_wallet_outlined,
                          label: 'Carteira',
                          onTap: () {},
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MenuButton(
                          icon: Icons.bar_chart,
                          label: 'Dashboards',
                          onTap: () {},
                        ),

                        const SizedBox(width: 10),

                        MenuButton(
                          icon: Icons.person_outline,
                          label: 'Perfil',
                          onTap: () {},
                        ),

                        const SizedBox(width: 10),

                        MenuButton(
                          icon: Icons.logout,
                          label: 'Sair da\nConta',
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  backgroundColor: Colors.transparent,
                                  child: Container(
                                    width: 260,
                                    height: 240,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF2F2F2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        // Texto
                                        const Text(
                                          'Deseja sair da sua\nconta?',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.black87,
                                          ),
                                        ),

                                        const SizedBox(height: 40),

                                        // Botões
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            // Botão SIM
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.pop(context);
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const TelaRecepcao(),
                                                  ),
                                                );

                                                // SUA LÓGICA DE LOGOUT AQUI
                                              },
                                              child: Container(
                                                width: 100,
                                                height: 50,
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFFE7E7E7,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                ),
                                                child: const Center(
                                                  child: Text(
                                                    'Sim',
                                                    style: TextStyle(
                                                      color: Colors.pink,
                                                      fontSize: 22,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),

                                            GestureDetector(
                                              onTap: () {
                                                Navigator.pop(context);

                                                // Sua lógica aqui
                                              },
                                              child: Container(
                                                width: 100,
                                                height: 50,
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFF34379B,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                ),
                                                child: const Center(
                                                  child: Text(
                                                    'Não',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 22,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const MenuButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF34379B);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: const Color(0xFFE8E9EB),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: primaryBlue, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 9, color: primaryBlue),
            ),
          ],
        ),
      ),
    );
  }
}

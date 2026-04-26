/* Autor: Bernardo Castro Brandão de Oliveira */

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mescla_invest_app/features/auth/data/repositories/auth_repository.dart';
import '../theme/background_app.dart';
import '../widgets/nav_menu.dart';
import '../widgets/pesquisar_menu.dart';

class MesclaInvest extends StatelessWidget {
  const MesclaInvest({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Catalogo(),
      theme: ThemeData(
        textTheme: GoogleFonts.montserratTextTheme(),
      ),
    );
  }
}

class CardCatalogo {
  final String nome_startup;
  final String logoImg;
  final String mini_descricao;
  final String status;
  final int tokens_emitidos;

  final List<String> socios;
  final double capital_aportado;

  CardCatalogo({
    required this.nome_startup,
    required this.logoImg,
    required this.mini_descricao,
    required this.status,
    required this.tokens_emitidos,
    required this.socios,
    required this.capital_aportado,
  });
}

class Catalogo extends StatefulWidget {
  const Catalogo({super.key});

  @override
  State<Catalogo> createState() => _CatalogoState();
}

class _CatalogoState extends State<Catalogo> {
  int paginaAtual = 0;
  final TextEditingController _buscaController = TextEditingController();
  String _textoBusca = "";

  @override
  Widget build(BuildContext context) {
    final List<CardCatalogo> startups = [
      CardCatalogo(
        nome_startup: "NotaCerta LTDA",
        logoImg: "assets/images/logo_notacerta.png",
        mini_descricao: "Plataforma de aulas de música",
        status: "Em Operação",
        tokens_emitidos: 100000,
        socios: [
          "Livia Lucizano - 50%",
          "Laura Soares - 50%",
        ],
        capital_aportado: 70000,
      ),

      CardCatalogo(
        nome_startup: "HealthVibe LTDA",
        logoImg: "assets/images/logo_healthvibe.png",
        mini_descricao: "Aplicativo de telemedicina focado em saúde mental para estudantes.",
        status: "Em Operação",
        tokens_emitidos: 1000000,
        socios: [
          "Beatriz Fernandes Costa - 100%",
        ],
        capital_aportado: 50000,
      ),

      CardCatalogo(
        nome_startup: "MetaLive LTDA",
        logoImg: "assets/images/logo_metalive.png",
        mini_descricao: "Aplicativo de integração de realidade aumentada no ambiente metaverso",
        status: "Em Operação",
        tokens_emitidos: 100000,
        socios: [
          "Moski Shimoji - 25%",
          "Abran Lincher - 25%",
          "Erick Lujahini - 15%",
          "Emay Saltgate - 15%",
          "Truham Wilson - 10%",
          "Maly Salzburg - 10%",
        ],
        capital_aportado: 89000,
      ),

      CardCatalogo(
        nome_startup: "CardVIsion LTDA",
        logoImg: "assets/images/logo_cardvision.png",
        mini_descricao: "Plataforma de valorização de cartas colecionáveis da cultura Geek",
        status: "Em Operação",
        tokens_emitidos: 500000,
        socios: [
          "Gabriela Silva - 50%",
          "Lucas Mendes - 50%",
        ],
        capital_aportado: 60000,
      ),
    ];

    final List<CardCatalogo> startupsFiltradas = startups.where((startup) {
      final busca = _textoBusca.toLowerCase();

      return startup.nome_startup.toLowerCase().contains(busca) ||
          startup.mini_descricao.toLowerCase().contains(busca) ||
          startup.status.toLowerCase().contains(busca);
    }).toList();

    final List<Widget> paginas = [
      // 0 - Início
      BackgroundContainer(
        child: Column(
        children: [
          const SizedBox(height: 45),
          BuscaStartup(controller: _buscaController, 
          onChanged: (valor) {
            setState(() {
              _textoBusca = valor;
            });
          },
        ),
          Expanded(
            child: ListView.builder(
              itemCount: startupsFiltradas.length,
              itemBuilder: (context, index) {
                final startup = startupsFiltradas[index];
                return CardStartup(s: startup);
              },
            ),
          ),
        ],
      ),
    ),

      // Criando telas para as outras abas do menu (Trocar para redirecionamento)
      // 1 - Catálogo
      const Center(child: Text("Catálogo")),

      // 2 - Dashboard
      const Center(child: Text("Dashboard")),

      // 3 - Perfil
      const Center(child: Text("Perfil")),
    ];

    return Scaffold(
      extendBodyBehindAppBar: paginaAtual==0,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text("Catálogo"),
        foregroundColor: const Color(0xFF353988),
        actions: [
          TextButton.icon(
            onPressed: AuthRepository.instance.logout,
            label: Icon(Icons.logout)
          )
        ],
      ),

      body: paginas[paginaAtual],
      bottomNavigationBar: MenuInferior(
        PaginaAtual: paginaAtual,
        onItemSelected: (index) {
          setState(() {
            paginaAtual = index;
          });
        },
      )
    );
  }
}

class BotaoIrPara extends StatelessWidget {
  final Widget pagina;
  final String texto;

  //Sugestão de mudança do nome da variavel para BotaoVerMais, 
  //para ficar mais claro o propósito do botão.
  const BotaoIrPara({
    super.key,
    required this.pagina,
    this.texto = "Ver mais",
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF353988),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => pagina),
        );
      },
      child: Text(texto),
    );
  }
}

class CardStartup extends StatefulWidget {
  final CardCatalogo s;

  const CardStartup({super.key, required this.s});

  @override
  State<CardStartup> createState() => _CardStartupState();
}

class _CardStartupState extends State<CardStartup> {
  bool expandido = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.s;

    return Card(
      color: const Color(0xFFE8E9EB),
      margin: const EdgeInsets.all(6),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage(s.logoImg),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              s.nome_startup,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          IconButton(
                            icon: Icon(
                              expandido
                                  ? Icons.close_fullscreen
                                  : Icons.open_in_full,
                            ),
                            onPressed: () {
                              setState(() {
                                expandido = !expandido;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(s.mini_descricao),

                      const SizedBox(height: 8),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDADADA),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          s.status,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      AnimatedCrossFade(
                        firstChild: const SizedBox(),
                        secondChild: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),

                            const Text(
                              "Participação (p/sócio):",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),

                            const SizedBox(height: 4),

                            ...s.socios.map((socio) => Text("• $socio")),

                            const SizedBox(height: 10),

                            const Text(
                              "Capital Aportado:",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),

                            Text("R\$ ${s.capital_aportado.toStringAsFixed(0)}"),
                          ],
                        ),
                        crossFadeState: expandido
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 300),
                      ),

                      const SizedBox(height: 10),

                      const Text("Tokens emitidos:"),
                      Text("${s.tokens_emitidos} tokens"),

                      Align(
                        alignment: Alignment.bottomRight,
                        child: BotaoIrPara(
                          pagina: const Placeholder(),
                        ),
                      ),
                    ],

                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
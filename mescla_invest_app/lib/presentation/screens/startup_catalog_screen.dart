/* Autor: Bernardo Castro Brandão de Oliveira */

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mescla_invest_app/data/repositories/auth_repository.dart';
import 'background_app.dart';

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

class Catalogo extends StatelessWidget {
  const Catalogo({super.key});

  @override
  Widget build(BuildContext context) {
    final List<CardCatalogo> startups = [
      CardCatalogo(
        nome_startup: "NotaCerta LTDA",
        logoImg: "images/logo_notacerta.png",
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
        logoImg: "images/logo_healthvibe.png",
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
        logoImg: "images/logo_metalive.png",
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
        logoImg: "images/logo_cardvision.png",
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

    return Scaffold(
      extendBodyBehindAppBar: true,
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

      body: BackgroundContainer(
        child: ListView.builder(
          itemCount: startups.length,
          itemBuilder: (context, index) {
            return CardStartup(s: startups[index]);
          },
        ),
      ),
    );
  }
}

class BotaoIrPara extends StatelessWidget {
  final Widget pagina;
  final String texto;

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


class Pesquisar extends StatefulWidget {
  const Pesquisar({super.key});

  @override
  State<Pesquisar> createState() => _PesquisarState();
}

class _PesquisarState extends State<Pesquisar> {
  final TextEditingController _controller = TextEditingController();

  String resultado = "";

  void _buscar() {
    setState(() {
      resultado = _controller.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pesquisar Startup')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: "Nome da startup",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _buscar,
              child: const Text("Pesquisar"),
            ),
            const SizedBox(height: 20),
            Text("Resultado: $resultado"),
          ],
        ),
      ),
    );
  }
}
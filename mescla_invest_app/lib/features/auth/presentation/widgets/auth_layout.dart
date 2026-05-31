/* Autor: Gabriela Sichiroli Ferrari */

import 'package:flutter/material.dart';

// Layout base reutilizável para as telas de autenticação.
// Define a estrutura visual padrão utilizada em login,
// cadastro e recuperação de senha.
class AuthLayout extends StatelessWidget {

  // Título principal exibido no topo da tela.
  final String title;

  // Texto complementar exibido abaixo do título.
  final String subtitle;

  // Conteúdo principal da tela (formulário).
  final Widget child;

  const AuthLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // Ajusta a tela automaticamente quando o teclado é aberto.
      resizeToAvoidBottomInset: true,

      // Permite que o conteúdo fique atrás da AppBar.
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,

        // Exibe o logo da aplicação no canto superior direito.
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Image.asset(
              'assets/images/logo_app.png',
              width: 25,
              height: 25,
            ),
          ],
        ),
      ),

      body: GestureDetector(

        // Fecha o teclado ao tocar fora dos campos de texto.
        onTap: () =>
            FocusScope.of(context).unfocus(),

        child: Stack(
          children: [

            // Fundo com gradiente utilizado em todas
            // as telas de autenticação.
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF353988),
                    Color(0xFFDB0065),
                  ],
                  stops: [0.75, 1.0],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topLeft,
                ),
              ),
            ),

            // Conteúdo principal da tela.
            SafeArea(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  // Área superior contendo título e subtítulo.
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      40,
                      40,
                      20,
                      20,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [

                        // Título da tela.
                        Text(
                          title,
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Subtítulo da tela.
                        Text(
                          subtitle,
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Container que recebe o formulário
                  // específico de cada tela.
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.all(30),

                      decoration:
                          const BoxDecoration(
                        color: Color(0xFFD4D4D4),

                        // Arredondamento aplicado apenas
                        // ao canto superior esquerdo.
                        borderRadius:
                            BorderRadius.only(
                          topLeft:
                              Radius.circular(40),
                        ),

                        // Sombra para destacar a área
                        // do formulário.
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, -5),
                          ),
                        ],
                      ),

                      // Conteúdo recebido pela tela filha.
                      child: child,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
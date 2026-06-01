/* Autor: Rafael Henrique dos Santos Inácio 
RA: 25009719*/

// Importações dos pacotes do Flutter e do sistema de rotas do aplicativo
import 'package:flutter/material.dart';
import 'package:mescla_invest_app/routes/app_routes.dart';

// Widget StatelessWidget para a tela de boas-vindas.
// Como esta tela apenas exibe informações estáticas e botões de navegação,
// não há necessidade de gerenciar estado (StatefulWidget).
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // O widget Stack permite sobrepor elementos na tela (um em cima do outro, como camadas).
      // Aqui é usado para colocar o conteúdo por cima do fundo gradiente.
      body: Stack(
        children: [
          // 1ª CAMADA DA STACK: FUNDO GRADIENTE
          // Este Container ocupa o espaço de fundo e aplica o gradiente de cores do app
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                // Define as cores do gradiente (azul escuro para rosa)
                colors: [Color(0xFF353988), Color(0xFFDB0065)],
                // Ajusta onde cada cor atinge sua intensidade máxima
                stops: [0.65, 0.95],
                // Define a direção visual do gradiente (inferior direito para superior esquerdo)
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
              ),
            ),
          ),

          // 2ª CAMADA DA STACK: CONTEÚDO DA TELA
          // O SafeArea garante que o conteúdo não será cortado pelo "notch" (entalhe da câmera)
          // ou pelas barras de status/navegação nativas do celular
          SafeArea(
            child: Padding(
              // Aplica um respiro de 24 pixels em todas as bordas internas
              padding: const EdgeInsets.all(24),

              // 1. Forçamos a largura total para que a centralização funcione
              // O double.infinity faz o SizedBox ocupar toda a largura disponível na tela
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  // Centraliza todos os filhos (textos, logos, botões) no eixo horizontal
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // O Spacer "empurra" o conteúdo para baixo, criando um espaçamento flexível
                    const Spacer(),

                    // TEXTO, LOGO e NOME (Mantidos)
                    // Renderiza o texto introdutório
                    const Text(
                      "Bem-vindo ao",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 10),

                    // Carrega a logomarca do aplicativo a partir da pasta de assets locais
                    Image.asset('assets/images/logo_app.png', width: 100),
                    const SizedBox(height: 10),

                    // Renderiza o nome do aplicativo com destaque (negrito)
                    const Text(
                      "MesclaInvest",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // Outro Spacer flexível para separar o logo dos botões na parte inferior
                    const Spacer(),

                    // BOTÃO ENTRAR (60% da largura)
                    // O MediaQuery pega o tamanho exato da tela do aparelho e calcula 60% dessa largura
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.6,
                      height: 55,
                      child: ElevatedButton(
                        // Ao clicar, o Navigator direciona o usuário para a rota nomeada de Login
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.login),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            0xFFE60073,
                          ), // Cor rosa do botão
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ), // Bordas arredondadas
                        ),
                        child: const Text(
                          "Entrar",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),

                    // Divisor visual simples entre os botões
                    const SizedBox(height: 10),
                    const Text("ou", style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 10),

                    // BOTÃO CADASTRO (Ajustado para 60% também, para não quebrar a tela)
                    // Mantém a mesma consistência de largura do botão de "Entrar"
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.6,
                      height: 55,
                      child: ElevatedButton(
                        // Ao clicar, o Navigator direciona o usuário para a rota nomeada de Registro/Cadastro
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.register),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors
                              .grey[300], // Cor de fundo neutra para diferenciar a ação secundária
                          foregroundColor: Colors.black, // Cor do texto
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text("Criar conta"),
                      ),
                    ),

                    // Espaçamento final na parte inferior da tela
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

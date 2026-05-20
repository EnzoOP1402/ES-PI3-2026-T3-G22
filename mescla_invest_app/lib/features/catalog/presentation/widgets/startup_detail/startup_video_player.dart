/* Autor: Gabriela Sichiroli Ferrari */

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

class VideoDemoPlayer extends StatefulWidget {
  final String videoUrl;
  const VideoDemoPlayer({
    super.key,
    required this.videoUrl,
  });
  @override
  State<VideoDemoPlayer> createState() => _VideoDemoPlayer();
}

class _VideoDemoPlayer extends State<VideoDemoPlayer> {
  // Variáveis responsáveis pelo controle,
  // carregamento e tratamento de erro do vídeo.
  VideoPlayerController? _controller;
  bool _isLoading = true;
  bool _hasError = false;
  @override
  void initState() {
    // Inicializa o vídeo assim que o widget é criado.
    _initializeVideo();
    super.initState();
  }

  // Método responsável por configurar e iniciar o vídeo.
  Future<void> _initializeVideo() async {
    try {
      // Verifica se a URL do vídeo está vazia.
      if (widget.videoUrl.isEmpty) {
        setState(() {
          // Define erro e encerra o loading.
          _hasError = true;
          _isLoading = false;
        });
        return;
      }
      // Cria o controlador utilizando a URL recebida.
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );
      // Inicializa o player.
      await _controller!.initialize();
      // Define o vídeo para repetir automaticamente.
      await _controller!.setLooping(true);
      setState(() {
        // Finaliza o loading após inicializar o vídeo.
        _isLoading = false;
      });
    } catch (e) {
      // Caso ocorra qualquer erro durante a inicialização,
      // define estado de erro e encerra o loading.
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }
  @override
  void dispose() {
    // Libera os recursos utilizados pelo controlador.
    _controller?.dispose();
    super.dispose();
  }

  // Alterna entre play e pause do vídeo.
  void _toggleVideo() {
    if (_controller == null) return;
    setState(() {
      _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Exibe loading enquanto o vídeo está carregando.
    if (_isLoading) {
      return Column(
        children: [
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Carregando vídeo...',
            style: GoogleFonts.montserrat(
              fontSize: 12,
              color: Colors.black,
            ),
          ),
        ],
      );
    }
    // Exibe mensagem caso aconteça algum erro.
    if (_hasError || _controller == null) {
      return Column(
        children: [
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Center(
              child: Icon(
                Icons.error_outline_rounded,
                color: Colors.white,
                size: 52,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Não foi possível carregar o vídeo.',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              color: Colors.black,
            ),
          ),
        ],
      );
    }
    // Exibe o player de vídeo normalmente.
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: VideoPlayer(_controller!),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: _toggleVideo,
              icon: Icon(
                _controller!.value.isPlaying
                    ? Icons.pause_circle
                    : Icons.play_circle,
                size: 52,
                color: const Color(0xFF2F3192),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
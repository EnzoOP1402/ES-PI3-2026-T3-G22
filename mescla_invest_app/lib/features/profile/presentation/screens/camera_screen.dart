/* Autor: Murillo Iamarino Caravita */

import 'dart:io';
import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

// Tela para tirar foto ou selecionar uma foto de perfil
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

// Estado da tela de câmera
class _CameraScreenState extends State<CameraScreen> {
  CameraLensDirection _currentDirection = CameraLensDirection.back;
  List<CameraDescription>? _cameras;
  CameraController? _controller;
  XFile? _imageFile;
  bool _isLoadingCamera = true;
  bool _isTakingPicture = false;
  bool _isUploading = false;
  String? _errorMessage;
  String? photoUrl;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  // Função para inicializar a câmera, buscando as câmeras disponíveis e configurando o controlador 
  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      _cameras = cameras;
      if (cameras.isEmpty) {
        setState(() {
          _errorMessage = 'Nenhuma câmera encontrada.';
          _isLoadingCamera = false;
        });
        return;
      }

      final camera = cameras.firstWhere(
        (cam) => cam.lensDirection == _currentDirection,
        orElse: () => cameras.first,
      );
      _controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();

      if (!mounted) return;

      setState(() {
        _isLoadingCamera = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Erro ao iniciar câmera: $e';
        _isLoadingCamera = false;
      });
    }
  }

  // Função para alternar entre a câmera frontal e traseira
  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.isEmpty) return;
    final newDirection = _currentDirection == CameraLensDirection.back
        ? CameraLensDirection.front
        : CameraLensDirection.back;
    final newCamera = _cameras!.firstWhere(
      (cam) => cam.lensDirection == newDirection,
      orElse: () => _cameras!.first,
    );

    await _controller?.dispose();

    _controller = CameraController(
      newCamera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await _controller!.initialize();

    setState(() {
      _currentDirection = newDirection;
    });
  }

  Future<void> _takePicture() async {
    final controller = _controller;

    if (controller == null ||
        !controller.value.isInitialized ||
        controller.value.isTakingPicture) {
      return;
    }

    setState(() {
      _isTakingPicture = true;
    });

    try {
      final image = await controller.takePicture();

      if (!mounted) return;
      setState(() {
        _imageFile = image;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao tirar foto: $e')));
    } finally {
      if (!mounted) return;
      setState(() {
        _isTakingPicture = false;
      });
    }
  }

  // Função para selecionar uma imagem da galeria
  Future<void> _pickImageFromGallery() async {
    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() {
        _imageFile = XFile(image.path);
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao selecionar imagem: $e')));
    }
  }
 
  // Função para fazer upload da imagem para o Firebase Storage e obter a URL de download
  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final ref = FirebaseStorage.instance.ref().child(
        'users/${user.uid}/profile.jpg',
      );

      if (kIsWeb) {
        final bytes = await _imageFile!.readAsBytes();

        await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      } else {
        await ref.putFile(
          File(_imageFile!.path),
          SettableMetadata(contentType: 'image/jpeg'),
        );
      }

      final downloadUrl = await ref.getDownloadURL();

      if (!mounted) return;
      Navigator.pop(context, downloadUrl);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro no upload: $e')));
    } finally {
      if (!mounted) return;
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  // Construção da interface da tela de câmera, mostrando a pré-visualização, 
  // botões para tirar foto, alternar câmera e selecionar da galeria
  @override
  Widget build(BuildContext context) {
    if (_isLoadingCamera) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Câmera')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(_errorMessage!, textAlign: TextAlign.center),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFF363636),
      appBar: AppBar(
        title: const Text(
          'Tirar foto',
          style: TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),),
        backgroundColor: Color(0xFF363636),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: _imageFile == null
                ? CameraPreview(_controller!)
                : kIsWeb
                ? Image.network(
                    _imageFile!.path,
                    fit: BoxFit.contain,
                    width: double.infinity,
                  )
                : Image.file(
                    File(_imageFile!.path),
                    fit: BoxFit.contain,
                    width: double.infinity,
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_imageFile == null) ...[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 16,
                        ),
                        textStyle: const TextStyle(fontSize: 12),
                        minimumSize: const Size(0, 32),
                      ),
                      onPressed: _pickImageFromGallery,
                      child: const Text('Galeria'),
                    ),

                    SizedBox(width: 20),

                    GestureDetector(
                      onTap: _isTakingPicture ? null : _takePicture,
                      child: Container(
                        width: 78,
                        height: 78,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: _isTakingPicture
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black,
                                  ),
                                )
                              : Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 2,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),

                    SizedBox(width: 20),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        textStyle: const TextStyle(fontSize: 12),
                        minimumSize: const Size(0, 32),
                      ),
                      onPressed: _switchCamera,
                      child: Text(
                        _currentDirection == CameraLensDirection.back
                            ? 'Frontal'
                            : 'Traseira',
                      ),
                    ),
                  ] else ...[
                    ElevatedButton(
                      onPressed: _isUploading
                          ? null
                          : () async {
                              setState(() {
                                _imageFile = null;
                                _isLoadingCamera = true;
                              });

                              await _controller?.dispose();

                              _controller = null;

                              await _initializeCamera();
                            },
                      child: const Text('Tirar outra'),
                    ),

                    ElevatedButton(
                      onPressed: _isUploading ? null : _uploadImage,
                      child: _isUploading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Usar foto'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

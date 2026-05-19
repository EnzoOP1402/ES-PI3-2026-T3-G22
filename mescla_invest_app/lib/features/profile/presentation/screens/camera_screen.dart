import 'dart:io';
import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
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

  Future<void> _initializeCamera() async {
    try {
      debugPrint('Buscando câmeras...');

      final cameras = await availableCameras();

      debugPrint('Câmeras encontradas: ${cameras.length}');

      if (cameras.isEmpty) {
        setState(() {
          _errorMessage = 'Nenhuma câmera encontrada.';
          _isLoadingCamera = false;
        });
        return;
      }

      final camera = cameras.first;

      debugPrint('Inicializando controller...');

      _controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();

      debugPrint('Câmera inicializada!');

      if (!mounted) return;

      setState(() {
        _isLoadingCamera = false;
      });
    } catch (e) {
      debugPrint('ERRO CAMERA: $e');

      if (!mounted) return;

      setState(() {
        _errorMessage = 'Erro ao iniciar câmera: $e';
        _isLoadingCamera = false;
      });
    }
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
      appBar: AppBar(title: const Text('Tirar foto')),
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (_imageFile == null) ...[
                  ElevatedButton(
                    onPressed: _isTakingPicture ? null : _takePicture,
                    child: _isTakingPicture
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Tirar foto'),
                  ),

                  ElevatedButton(
                    onPressed: _pickImageFromGallery,
                    child: const Text('Escolher da galeria'),
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
        ],
      ),
    );
  }
}

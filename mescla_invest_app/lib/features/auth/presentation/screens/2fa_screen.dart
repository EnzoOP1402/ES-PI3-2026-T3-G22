import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TwoFAScreen extends StatefulWidget {
  final MultiFactorResolver resolver;

  const TwoFAScreen({
    super.key,
    required this.resolver,
  });

  @override
  State<TwoFAScreen> createState() => _TwoFAScreenState();
}

class _TwoFAScreenState extends State<TwoFAScreen> {
  final TextEditingController _codigoController = TextEditingController();

  bool _isLoading = false;
  String? _verificationId;
  String _telefoneMascarado = '';

  @override
  void initState() {
    super.initState();
    _enviarCodigo();
  }

  @override
  void dispose() {
    _codigoController.dispose();
    super.dispose();
  }

  Future<void> _enviarCodigo() async {
    try {
      final hint = widget.resolver.hints.first;

      if (hint is! PhoneMultiFactorInfo) {
        throw Exception('Segundo fator não suportado.');
      }

      setState(() {
        _telefoneMascarado = hint.phoneNumber ?? '';
      });

      await FirebaseAuth.instance.verifyPhoneNumber(
        multiFactorSession: widget.resolver.session,
        multiFactorInfo: hint,
        verificationCompleted: (_) {},
        verificationFailed: (FirebaseAuthException e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                e.message ?? 'Erro ao enviar código de verificação.',
              ),
            ),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          if (!mounted) return;

          setState(() {
            _verificationId = verificationId;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Código enviado por SMS com sucesso.'),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao iniciar verificação: $e')),
      );
    }
  }

  Future<void> _validarCodigo() async {
    final codigo = _codigoController.text.trim();

    if (codigo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite o código recebido por SMS.')),
      );
      return;
    }

    if (_verificationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('O código ainda não foi enviado. Tente novamente.'),
        ),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);

      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: codigo,
      );

      final assertion = PhoneMultiFactorGenerator.getAssertion(credential);

      await widget.resolver.resolveSignIn(assertion);

      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Código inválido.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao validar código: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _reenviarCodigo() async {
    await _enviarCodigo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9E9E9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3F3D99),
        elevation: 0,
        title: const Text(
          'Verificação em duas etapas',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F4F4),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF3F3D99)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.shield_outlined,
                    size: 56,
                    color: Color(0xFF3F3D99),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Confirme seu acesso',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3F3D99),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _telefoneMascarado.isNotEmpty
                        ? 'Digite o código enviado para $_telefoneMascarado'
                        : 'Digite o código enviado para seu celular',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _codigoController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      letterSpacing: 8,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      hintText: '000000',
                      counterText: '',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFF3F3D99),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFF3F3D99),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFF3F3D99),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _validarCodigo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3F3D99),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Confirmar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _isLoading ? null : _reenviarCodigo,
                    child: const Text(
                      'Reenviar código',
                      style: TextStyle(
                        color: Color(0xFF3F3D99),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
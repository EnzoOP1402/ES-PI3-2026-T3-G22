import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EnableTwoFAScreen extends StatefulWidget {
  final String phone;

  const EnableTwoFAScreen({
    super.key,
    required this.phone,
  });

  @override
  State<EnableTwoFAScreen> createState() => _EnableTwoFAScreenState();
}

class _EnableTwoFAScreenState extends State<EnableTwoFAScreen> {
  final TextEditingController _codigoController = TextEditingController();

  bool _isSendingCode = false;
  bool _isConfirming = false;
  bool _isSendingEmailVerification = false;
  bool _isCheckingEmailVerification = false;

  String? _verificationId;
  String _telefoneFormatado = '';
  bool _emailVerificado = false;

  @override
  void initState() {
    super.initState();
    _telefoneFormatado = _formatPhone(widget.phone);
    _carregarStatusEmail();
  }

  @override
  void dispose() {
    _codigoController.dispose();
    super.dispose();
  }

  String _formatPhone(String phone) {
    final numbers = phone.replaceAll(RegExp(r'[^0-9]'), '');
    return '+55$numbers';
  }

  Future<void> _carregarStatusEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await user.reload();
      final updatedUser = FirebaseAuth.instance.currentUser;

      if (!mounted || updatedUser == null) return;

      setState(() {
        _emailVerificado = updatedUser.emailVerified;
      });
    } catch (_) {}
  }

  Future<void> _enviarEmailVerificacao() async {
    try {
      setState(() => _isSendingEmailVerification = true);

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado.');
      }

      if (user.emailVerified) {
        if (!mounted) return;
        setState(() {
          _emailVerificado = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Seu e-mail já está verificado.'),
          ),
        );
        return;
      }

      await user.sendEmailVerification();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('E-mail de verificação enviado com sucesso.'),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message ?? 'Erro ao enviar e-mail de verificação.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro inesperado: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSendingEmailVerification = false);
      }
    }
  }

  Future<void> _verificarEmailNovamente() async {
    try {
      setState(() => _isCheckingEmailVerification = true);

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado.');
      }

      await user.reload();
      final updatedUser = FirebaseAuth.instance.currentUser;

      if (updatedUser == null) {
        throw Exception('Usuário não autenticado.');
      }

      if (!mounted) return;

      setState(() {
        _emailVerificado = updatedUser.emailVerified;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            updatedUser.emailVerified
                ? 'E-mail verificado com sucesso.'
                : 'Seu e-mail ainda não foi verificado.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao verificar e-mail: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isCheckingEmailVerification = false);
      }
    }
  }

  Future<void> _enviarCodigo() async {
    try {
      setState(() => _isSendingCode = true);

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado.');
      }

      await user.reload();
      final updatedUser = FirebaseAuth.instance.currentUser;

      if (updatedUser == null) {
        throw Exception('Usuário não autenticado.');
      }

      final factors = await updatedUser.multiFactor.getEnrolledFactors();
      if (factors.isNotEmpty) {
        throw Exception('Este usuário já possui 2FA ativado.');
      }

      if (!updatedUser.emailVerified) {
        setState(() {
          _emailVerificado = false;
        });
        throw Exception(
          'Verifique seu e-mail antes de ativar a autenticação em duas etapas.',
        );
      }

      setState(() {
        _emailVerificado = true;
      });

      final session = await updatedUser.multiFactor.getSession();

      await FirebaseAuth.instance.verifyPhoneNumber(
        multiFactorSession: session,
        phoneNumber: _telefoneFormatado,
        verificationCompleted: (_) {},
        verificationFailed: (FirebaseAuthException e) {
          final code = e.code;
          final message = e.message ?? '';

          String friendlyMessage;

          if (message.contains('invalid application verifier') ||
              message.contains('reCAPTCHA') ||
              message.contains('verifier')) {
            friendlyMessage =
                'Falha na validação de segurança do dispositivo. Verifique a configuração do Firebase e tente novamente.';
          } else if (code == 'invalid-phone-number') {
            friendlyMessage = 'Número de telefone inválido.';
          } else if (code == 'too-many-requests') {
            friendlyMessage = 'Muitas tentativas. Aguarde alguns minutos e tente novamente.';
          } else if (code == 'quota-exceeded') {
            friendlyMessage = 'Limite de envio de SMS atingido no Firebase.';
          } else {
            friendlyMessage = message.isNotEmpty
                ? message
                : 'Não foi possível enviar o código por SMS.';
          }

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(friendlyMessage)),
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
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _isSendingCode = false);
      }
    }
  }

  Future<void> _confirmarCodigo() async {
    final codigo = _codigoController.text.trim();

    if (codigo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite o código recebido por SMS.'),
        ),
      );
      return;
    }

    if (_verificationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Envie o código antes de confirmar.'),
        ),
      );
      return;
    }

    try {
      setState(() => _isConfirming = true);

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado.');
      }

      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: codigo,
      );

      final assertion = PhoneMultiFactorGenerator.getAssertion(credential);

      await user.multiFactor.enroll(
        assertion,
        displayName: 'Celular principal',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Autenticação em duas etapas ativada com sucesso!'),
        ),
      );

      Navigator.pop(context, true);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Erro ao confirmar código.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro inesperado: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isConfirming = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9E9E9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3F3D99),
        elevation: 0,
        title: const Text(
          'Ativar 2FA',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F4F4),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF3F3D99)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Icon(
                    Icons.shield_outlined,
                    size: 58,
                    color: Color(0xFF3F3D99),
                  ),
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'Habilitar autenticação em duas etapas',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3F3D99),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Para aumentar a segurança da sua conta, primeiro confirme seu e-mail e depois valide seu celular por SMS.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _emailVerificado
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _emailVerificado
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFB26A00),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _emailVerificado
                            ? Icons.check_circle_outline
                            : Icons.email_outlined,
                        color: _emailVerificado
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFFB26A00),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _emailVerificado
                              ? 'Seu e-mail já está verificado.'
                              : 'Seu e-mail ainda não foi verificado.',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _emailVerificado
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFFB26A00),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                if (!_emailVerificado) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: _isSendingEmailVerification
                          ? null
                          : _enviarEmailVerificacao,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF3F3D99)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isSendingEmailVerification
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Enviar e-mail de verificação',
                              style: TextStyle(
                                color: Color(0xFF3F3D99),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: TextButton(
                      onPressed: _isCheckingEmailVerification
                          ? null
                          : _verificarEmailNovamente,
                      child: _isCheckingEmailVerification
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Já verifiquei meu e-mail',
                              style: TextStyle(
                                color: Color(0xFF3F3D99),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                const Text(
                  'Telefone para verificação',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3F3D99),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF3F3D99)),
                  ),
                  child: Text(
                    _telefoneFormatado,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: (_isSendingCode || !_emailVerificado)
                        ? null
                        : _enviarCodigo,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF3F3D99)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isSendingCode
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Enviar código',
                            style: TextStyle(
                              color: Color(0xFF3F3D99),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Código SMS',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3F3D99),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _codigoController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: '000000',
                    counterText: '',
                    filled: true,
                    fillColor: Colors.white,
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
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isConfirming ? null : _confirmarCodigo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3F3D99),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isConfirming
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Confirmar e ativar',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
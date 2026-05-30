import 'package:flutter/material.dart';
import 'package:mescla_invest_app/features/auth/data/repositories/sms_auth_service.dart';

class TwoFAScreen extends StatefulWidget {
  final String verificationId;
  final String email;
  final String password;

  const TwoFAScreen({
    super.key,
    required this.verificationId,
    required this.email,
    required this.password,
  });

  @override
  State<TwoFAScreen> createState() => _TwoFAScreenState();
}

class _TwoFAScreenState extends State<TwoFAScreen> {
  final TextEditingController _codigoController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _codigoController.dispose();
    super.dispose();
  }

  Future<void> _validarCodigo() async {
    final codigo = _codigoController.text.trim();

    if (codigo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite o código recebido por SMS'),
        ),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);

      // 🔥 valida SMS (isso já autentica o usuário no Firebase)
      await SmsAuthService.validarCodigo(
        widget.verificationId,
        codigo,
      );

      if (!mounted) return;

      // 🚨 NÃO faz login de novo
      // 🚨 NÃO faz signOut
      // O Firebase já considera o usuário logado aqui

      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Código inválido. Tente novamente.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificação SMS'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Digite o código enviado para seu celular',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            TextField(
              controller: _codigoController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                hintText: '000000',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _validarCodigo,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Confirmar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
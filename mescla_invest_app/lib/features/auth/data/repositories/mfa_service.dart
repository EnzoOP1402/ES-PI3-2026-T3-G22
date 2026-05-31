import 'package:firebase_auth/firebase_auth.dart';

class MfaService {
  static Future<void> enviarCodigoCadastro({
    required String telefone,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      onError('Usuário não autenticado.');
      return;
    }

    final session = await user.multiFactor.getSession();

    await FirebaseAuth.instance.verifyPhoneNumber(
      multiFactorSession: session,
      phoneNumber: telefone,
      verificationCompleted: (_) {},
      verificationFailed: (e) {
        onError(e.message ?? 'Erro ao enviar código');
      },
      codeSent: (verificationId, _) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  static Future<void> confirmarCadastro({
    required String verificationId,
    required String smsCode,
    required String displayName,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado.');
    }

    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    final assertion = PhoneMultiFactorGenerator.getAssertion(credential);

    await user.multiFactor.enroll(
      assertion,
      displayName: displayName,
    );
  }
}
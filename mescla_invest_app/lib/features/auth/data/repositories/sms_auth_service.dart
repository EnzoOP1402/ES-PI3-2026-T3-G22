/* Autor: Bernardo Castro Brandão de Oliveira */

import 'package:firebase_auth/firebase_auth.dart';

class SmsAuthService {

  static Future<void> enviarCodigo(
    String telefone,
    Function(String verificationId) onCodeSent,
  ) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: telefone,

      verificationCompleted: (PhoneAuthCredential credential) async {
        // Em alguns Androids ele pode logar automaticamente
        await FirebaseAuth.instance.signInWithCredential(credential);
      },

      verificationFailed: (FirebaseAuthException e) {
        throw Exception(e.message ?? "Erro ao enviar SMS");
      },

      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },

      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  static Future<UserCredential> validarCodigo(
    String verificationId,
    String smsCode,
  ) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
}
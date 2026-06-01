/* Autor: Bernardo Castro Brandão de Oliveira - RA: 25014953*/

// Importação do pacote Firebase Authentication,
// responsável pelos serviços de autenticação da aplicação.
import 'package:firebase_auth/firebase_auth.dart';

// Classe responsável pelo envio e validação de códigos SMS
// utilizando a autenticação por telefone do Firebase.
class SmsAuthService {
  // Método responsável por enviar um código de verificação
  // para o número de telefone informado.
  static Future<void> enviarCodigo(
    // Número de telefone que receberá o SMS
    String telefone,

    // Função de callback executada quando o código for enviado
    Function(String verificationId) onCodeSent,
  ) async {
    // Inicia o processo de verificação por telefone
    await FirebaseAuth.instance.verifyPhoneNumber(
      // Número que receberá o código SMS
      phoneNumber: telefone,

      // Executado automaticamente em alguns dispositivos Android
      // quando o Firebase consegue validar o número sem exigir
      // que o usuário digite o código manualmente.
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Em alguns Androids ele pode logar automaticamente
        await FirebaseAuth.instance.signInWithCredential(credential);
      },

      // Executado caso ocorra algum erro durante o envio
      // ou validação do número de telefone.
      verificationFailed: (FirebaseAuthException e) {
        throw Exception(e.message ?? "Erro ao enviar SMS");
      },

      // Executado quando o código SMS é enviado com sucesso.
      codeSent: (String verificationId, int? resendToken) {
        // Retorna o verificationId para utilização futura
        // na validação do código informado pelo usuário.
        onCodeSent(verificationId);
      },

      // Executado quando o tempo limite para recuperação
      // automática do código expira.
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  // Método responsável por validar o código SMS informado
  // pelo usuário e realizar a autenticação.
  static Future<UserCredential> validarCodigo(
    // Identificador gerado durante o envio do SMS
    String verificationId,

    // Código recebido via mensagem SMS
    String smsCode,
  ) async {
    // Cria uma credencial utilizando o código informado
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    // Realiza a autenticação utilizando a credencial criada
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
}

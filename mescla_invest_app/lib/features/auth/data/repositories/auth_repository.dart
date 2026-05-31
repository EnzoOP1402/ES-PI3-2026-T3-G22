/* Autor: Enzo Olivato Pazian - 25001654 */

// Implementando as dependências
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mescla_invest_app/core/errors/app_exceptions.dart';
import '../models/user_model.dart';

// Classe que representa o Repositório com as funções relacionadas à autenticação de usuários investidores na plataforma
// Funciona como ponte entre os dados recebidos nas páginas e os recursos do Firebase Authentication
class AuthRepository {
  // Criando uma instância privada única (Singleton) para evitar a criação de múltiplas instâncias nas páginas que usarão os recursos desse repositório
  static final AuthRepository _instance = AuthRepository._internal();

  // Definindo o getter da instância para permitir seu acesso pelas outras páginas
  static AuthRepository get instance => _instance;

  // Construtor nomeado privado para a criação do Singleton
  AuthRepository._internal();

  // Criando uma instância do Firebase Authentication para a utilização de seus recursos
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream para monitorar se o usuário está logado ou não
  // Alimenta o AuthWrapper com o monitoramento do estado da autenticação
  Stream<User?> get authStateChange => _auth.authStateChanges();

  // Getter para o acesso ao uid do usuário autenticado
  User? get currentUser => _auth.currentUser;

  /// Método de login: responsável invocar o método de login do Firebase Auth através do
  /// [email] e da [password] fornecidos pelo usuário na interface
  Future<void> login(String email, String password) async {
    try {
      // Aguarda a operação de login do usuário através dos dados passados por parâmetro
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password
      );
    }
    // Se houver algum erro próprio dos serviços de autenticação do Firebase,
    // dispara o erro identificado através do método de tratamento de erro 
    on FirebaseAuthException catch (e) {
      // Lança a String amigável para ser capturada pelo catch da UI
      throw _handleAuthError(e);
    }
    // Se algum erro de outra natureza for identificado, dispara a mensagem de erro genérica
    // convertida para String através do construtor da exceção autoral definida ára o tratamento
    // de exceções encontradas na autenticação do usuário
    catch (e) {
      // lança o erro para ser interceptado pela UI
      throw AuthException("Não foi possível realizar o login agora.");
    }
  }
  /// Método de cadastro: responsável por utilizar os dados obtidos no objeto [user] e a [password]
  /// para validar a consistência de dados como o CPF, invocar o método de cadastro do Firebase Auth
  /// e criar um documento no Firestore contendo os dados do novo usuário criado através de uma chamada
  /// à Firebase Function registerUser.
  Future<void> register(UserModel user, String password) async {
    try {
      // Fazendo a chamada à função de cadastro do Firebase
      await FirebaseFunctions
      .instanceFor(region: 'southamerica-east1')
      .httpsCallable('registerUser')
      .call({
        'email': user.email,
        'password': password,
        'fullName': user.fullName,
        'cpf': user.cpf,
        'phone': user.phone,
      });
      
      // Após o retorno de sucesso da Function, o usuário já está criado no Auth, então
      // efetuamos o login automático dele usando o mesmo e-mail e senha inseridos
      await _auth.signInWithEmailAndPassword(email: user.email, password: password);
    }
    // Se 
    on FirebaseFunctionsException catch (e) {
      // Lança a exceção
      throw AuthException("Erro ao realizar cadastro: ${e.message ?? 'Falha na Function'}");
    }
    // Se erros específicos do Firebase Auth (Senha fraca, e-mail duplicado) forem identificados,
    // dispara o erro identificado através do método de tratamento de erro 
    on FirebaseAuthException catch (e) {
      // Lança a String amigável para ser capturada pelo catch da UI
      throw _handleAuthError(e);
    }
    // Se erros específicos do Firestore (Permissão, banco fora do ar) forem identificados,
    // dispara o erro identificado, convertendo-o em uma exceção autoral para tratar
    // a mensagem de erro 
    on FirebaseException {
      // Lança a exceção
      throw AuthException("Erro no banco de dados: Permissão negada ou falha na rede.");
    }
    // Se erros genéricos forem identificados, dispara o erro identificado, convertendo-o
    // em uma exceção autoral para tratar a mensagem de erro 
    catch (e) {
      // Lança a exceção
      throw AuthException("Ocorreu um erro inesperado. Tente novamente. ${e.toString()}");
    }
  }

  /// Método de logout: responsável por encerrar a sessão do usuário logado na plataforma
  Future<void> logout() async {
    try {
      // Aguarda a execução do encerramento da sessão do usuário
      await _auth.signOut();
    }
    // Se erros genéricos forem identificados, dispara o erro identificado,
    // convertendo-o em uma exceção autoral para tratar a mensagem de erro 
    catch (e) {
      throw AuthException("Erro ao sair da conta. Tente novamente.");
    }
  }

  /// Método de recuperação de senha: responsável por enviar uma e-mail à caixa de
  /// entrada do usuário que informou seu [email] para que ele possa redefinir sua
  /// senha através do recurso nativo do Firebase Auth de recuperação de senha
  Future<void> recoverPassword(String email) async {
    try {
      // Passo 1 para a recuperação de senha: Validação extra via Function
      // para existência do e-mail na base de dados

      // Formatando o e-mail recebido
      final String formattedEmail = email.trim().toLowerCase();

      // Invocando a Cloud Function para validar a existência do e-mail de forma segura
      final HttpsCallable callable = FirebaseFunctions
        .instanceFor(region: 'southamerica-east1')
        .httpsCallable('checkEmailExists');
      
      // Obtendo o resultado retornado
      final HttpsCallableResult result = await callable.call({
        'email': formattedEmail,
      });

      // Extrai o boolean retornado pela Function
      final bool exists = result.data['exists'] ?? false;

      // Se não existir, emite o seu erro autoral tratado pela UI
      if (!exists) {
        throw AuthException("E-mail não encontrado em nossa base.");
      }

      // Se o e-mail existir, o Firebase envia o link automaticamente para a caixa de entrada do usuário
      await _auth.sendPasswordResetEmail(email: email);
    }
    // Se erros específicos do Firebase Auth (como "e-mail inválido") forem identificados, dispara
    // o erro identificado através do método de tratamento de erro 
    on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
    on FirebaseFunctionsException catch (e) {
      throw AuthException("Não foi possível enviar o e-mail de recuperação. ${e.message}");
    }
    // Se erros genéricos forem identificados, dispara o erro identificado,
    // convertendo-o em uma exceção autoral para tratar a mensagem de erro,
    // mas se o erro já for do tipo autoral, apenas repassa
    catch (e) {
      // Repassa nossa mensagem do Firestore
      if (e is AuthException) rethrow;
      // Lança o erro como autoral
      throw AuthException("Não foi possível enviar o e-mail de recuperação.");
    }
  }

  /// Método privado _handleAuthError: é responsável por atuar como um Helper para mensagens amigáveis
  /// de erros nativos da autenticação do Firebase, retornando Strings específicas e mais fáceis
  /// de entender do que as mensagens nativas de erro, alternando entre resultados possíveis
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      // Erros de Cadastro
      case 'email-already-in-use': 
        return "Este e-mail já está cadastrado.";
      case 'weak-password': 
        return "A senha é muito fraca. Use pelo menos 6 caracteres.";
      
      // Erros de Login
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return "E-mail ou senha incorretos.";
      case 'user-disabled':
        return "Esta conta foi desativada.";
      case 'too-many-requests':
        return "Muitas tentativas bloqueadas. Tente novamente mais tarde.";
      
      // Erros Comuns
      case 'invalid-email': 
        return "O formato do e-mail é inválido.";
      case 'network-request-failed':
        return "Falha na conexão. Verifique sua internet.";
      default: 
        return "Ocorreu um erro inesperado: ${e.code}";
    }
  }
}
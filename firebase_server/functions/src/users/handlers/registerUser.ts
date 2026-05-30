/* Autor: Enzo Olivato Pazian */

import {HttpsError, onCall} from "firebase-functions/v2/https";
import {normalizeString} from "../../shared/validation";
import {normalizePhoneToE164} from "../shared/validation";
import {cpfExists} from "../repositories/userRepository";
import {auth, db} from "../../shared/firebase";
import {logger} from "firebase-functions";
import {UserDocument} from "../types";
import {FieldValue} from "firebase-admin/firestore";

/**
 * Função de cadastro de um usuário.
 *
 * Obtém os dados cadastrais vindos do frontend, valida-os, cria
 * um usuário no Firebase Authentication e salva seus dados no
 * Firestore.
 */
export const registerUser = onCall( async (request) => {
  // ETAPA 1: Obtenção e normalização dos dados vindos
  // da requisição

  // Obtendo e normalizando o e-mail do usuário
  const email = normalizeString(request.data?.email);

  // Obtendo e normalizando o nome do usuário
  const fullName = normalizeString(request.data?.fullName);

  // Não normalizamos a senha para evitar problemas com
  // caracteres especiais
  const password = request.data?.password;

  // Formatando o CPF recebido,deixando apenas números
  const rawCpf = normalizeString(request.data?.cpf);
  const cpf = rawCpf ? rawCpf.replace(/\D/g, "") : "";

  // Formatando o telefone para o padrão preferido pelo Firebase
  const rawPhone = request.data?.phone;
  const phone = normalizePhoneToE164(rawPhone);

  // Validação: se a função retornar null, barramos o cadastro imediatamente
  if (!phone) {
    throw new HttpsError(
      "invalid-argument",
      "O número de telefone informado é inválido. " +
      "Certifique-se de incluir o DDD."
    );
  }

  // Validação básica de presença de campos
  if (!email || !password || !fullName || !cpf || !phone) {
    throw new HttpsError(
      "invalid-argument",
      "Todos os campos de cadastro são obrigatórios."
    );
  }

  // Verificando se o tamanho da senha cumpre os requisitos do
  // Firebase
  if (password.length < 6) {
    throw new HttpsError(
      "invalid-argument",
      "A senha deve conter no mínimo 6 caracteres."
    );
  }

  // Criando a variável que receberá o ID do usuário criado
  // (começa com o valor nulo)
  let createdUid: string | null = null;

  // ETAPA 2: Realizando as operações de criação da conta
  try {
    // Verificando se o CPF já existe
    const isCpfDuplicated = await cpfExists(cpf);
    if (isCpfDuplicated) {
      throw new HttpsError(
        "already-exists",
        "Este CPF já está cadastrado em outra conta."
      );
    }

    // Criando a conta no Firebase Auth usando o SDK do Firebase
    // Admin e os dados obtidos
    const userAuthRecord = await auth.createUser({
      email: email,
      password: password,
      displayName: fullName,
      phoneNumber: phone,
    });

    // Armazenando o UID criado para o caso de precisarmos deletar
    // em um catch posterior
    createdUid = userAuthRecord.uid;

    // Criando um objeto com os dados do usuário para salvá-los no
    // Firestore
    const newUserData: UserDocument = {
      fullName,
      cpf,
      email,
      phone,
      // Iniciando forçadamente o saldo como 0
      balanceAvailableCents: 0,
      balanceFrozenCents: 0,
      twoFAOn: false,
      createdAt: FieldValue.serverTimestamp(),
    };

    // Salvando o documento no Firestore usando o UID do Auth como
    // ID do documento
    await db.collection("users").doc(createdUid).set(newUserData);

    // Registrando no Logger da Function a mensagem de sucesso
    // após o cadastro do usuário
    logger.info(
      "Usuário cadastrado com sucesso no sistema.",
      {uid: createdUid}
    );

    // Retornando um objeto com o status de sucesso e o ID do usuário
    // recém criado
    return {
      data: {
        success: true,
        uid: createdUid,
      },
    };
  } catch (error: unknown) {
    // Se houver algum erro com o Firestore ai tentarmos criar o
    // usuário, removemos ele do Authentication
    if (createdUid) {
      try {
        await auth.deleteUser(createdUid);
        logger.warn(
          `Rollback executado: Usuário ${createdUid} deletado do` +
          " Auth devido a falha no Firestore."
        );
      } catch (deleteError) {
        logger.error(
          "Falha crítica ao tentar executar rollback no Auth:",
          deleteError
        );
      }
    }

    // Repassando os erros customizados (ex: CPF já existe)
    if (error instanceof HttpsError) {
      throw error;
    }

    // Tratando erros específicos do próprio Firebase Auth Admin
    // (ex: E-mail já em uso), fazendo uma asserção segura e
    // dizendo que o objeto possui uma string 'code'
    const firebaseError = error as { code?: string };

    if (firebaseError.code === "auth/email-already-exists") {
      throw new HttpsError(
        "already-exists",
        "Este endereço de e-mail já está sendo usado por outra conta."
      );
    }

    // Se for qualquer outro erro inesperado (ex: banco fora do ar,
    // erro de timeout), nós registramos o erro real no Logger para
    // que possamos investigá-lo
    logger.error("Erro crítico no processo de cadastro:", error);

    // Em seguida, retornamos um novo erro para que o Flutter
    // receba uma mensagem amigável
    throw new HttpsError(
      "internal",
      "Erro ao processar o cadastro no servidor. Tente novamente."
    );
  }
});

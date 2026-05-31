/* Autor: Gabriela Sichiroli Ferrari - RA: 25013763 */

import {onCall, HttpsError} from "firebase-functions/v2/https";
import {FieldValue} from "firebase-admin/firestore";
import {requireAuthenticatedUser} from "../../shared/auth";
import {db} from "../../shared/firebase";
import {normalizeNumber} from "../../shared/validation";
import {logger} from "firebase-functions";

/**
 * Função de recarga de saldo.
 *
 * Obtém o valor desejado, valida-o e altera o campo no Firestore.
 */
export const addBalance = onCall(async (request) => {
  // Verifica autenticação
  const user = requireAuthenticatedUser(request);

  // Obtém o id do usuário autenticado
  const uid = user.uid;

  // Obtém e normaliza a quantidade a ser recarregada
  const amountCents = normalizeNumber(request.data?.amountCents);

  // Verificando se a quantidade está definida após a normalização
  if (!amountCents) {
    throw new HttpsError(
      "invalid-argument",
      "O amountCents é obrigatório."
    );
  }

  // Verificando se a quantidade é maior que 0
  if (amountCents <= 0) {
    throw new HttpsError(
      "invalid-argument",
      "amountCents deve ser maior que 0.",
    );
  }

  try {
    // Criando uma referência para o documento do usuário autenticado
    const userRef = db.collection("users").doc(uid);

    // Incrementando o saldo disponível do usuário com o valor informado
    await userRef.update({
      balanceAvailableCents: FieldValue.increment(amountCents),
    });

    // Registrando o acréscimo do saldo no logger da Function
    logger.info(`O saldo do usuário ${uid} foi incrementado em `+
      `R$${(amountCents/100).toFixed(2)}`);

    // Se a operação foi bem sucedida, retorna um objeto com o status e uma
    // mensagem de sucesso
    return {
      success: true,
      message: "Saldo adicionado com sucesso.",
    };
  } catch (error: unknown) {
    // Se o erro capturado já for um HttpsError que nós mesmos
    // lançamos lá dentro, nós apenas repassamos ele para o
    // Flutter ler a mensagem amigável
    if (error instanceof HttpsError) {
      throw error;
    }

    // Se for qualquer outro erro inesperado (ex: banco fora do ar,
    // erro de timeout), nós registramos o erro real no Logger para
    // que possamos investigá-lo
    logger.error("Erro interno ao carregar o saldo: ", error);

    // Em seguida, retornamos um novo erro para que o Flutter
    // receba uma mensagem amigável
    throw new HttpsError(
      "internal",
      "Houve um erro interno ao carregar seu saldo. Tente novamente mais tarde."
    );
  }
});

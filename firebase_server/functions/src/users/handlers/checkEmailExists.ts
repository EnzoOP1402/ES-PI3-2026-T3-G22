/* Autor: Enzo Olivato Pazian */

import {onCall, HttpsError} from "firebase-functions/v2/https";
import {db} from "../../shared/firebase";
import {logger} from "firebase-functions/v2";

/**
 * Function para verificar se um e-mail existe no
 * banco de dados, usada antes de enviar o e-mail
 * de recuperação de senha.
 */
export const checkEmailExists = onCall(
  async (request) => {
    // Obtendo o e-mail passado como parâmetro
    const email = request.data.email?.trim().toLowerCase();

    // Validação inicial do e-mail recebido
    if (!email) {
      throw new HttpsError(
        "invalid-argument",
        "O e-mail deve ser fornecido."
      );
    }

    try {
      // Faz uma busca limitada a 1 documento para economizar leitura
      const userSnapshot = await db.collection("users")
        .where("email", "==", email)
        .limit(1)
        .get();

      // Retorna de forma limpa se o e-mail existe ou não
      return {exists: !userSnapshot.empty};
    } catch (error) {
      logger.error("Erro ao verificar existência de e-mail:", error);
      throw new HttpsError(
        "internal",
        "Erro interno ao processar a verificação de e-mail."
      );
    }
  }
);

/* Autor: Enzo Olivato Pazian*/

import {HttpsError, onCall} from "firebase-functions/v2/https";
import {requireAuthenticatedUser} from "../../shared/auth";
import {getUserById} from "../repositories/userRepository";
import {logger} from "firebase-functions";

/**
 * Firebase Function responsável por obter e retornar o
 * saldo de um usuário, sendo usada na tela inicial e na
 * tela de carteira.
 */
export const getUserBalance = onCall(
  async (request) => {
    // Garantindo que o usuário está autenticado antes de obter os dados
    const user = requireAuthenticatedUser(request);

    try {
      // Obtendo os dados do usuário
      const userData = await getUserById(user.uid);

      // Se o documento obtido estiver vazio, lança um erro
      if (!userData) {
        throw new HttpsError(
          "not-found",
          "Usuário não encontrado"
        );
      }

      // Retorna os saldos do usuário
      return {
        balanceAvailableCents: userData.balanceAvailableCents | 0,
        balanceFrozenCents: userData.balanceFrozenCents | 0,
      };
    } catch (error: unknown) {
      // Registra o erro no logger da Function
      logger.error("Erro ao obter o saldo do usuário:",
        error);

      // Lança uma exceção que será exibida de forma amigável no front
      throw new HttpsError(
        "internal",
        "Erro ao carregar do saldo do usuário."
      );
    }
  }
);

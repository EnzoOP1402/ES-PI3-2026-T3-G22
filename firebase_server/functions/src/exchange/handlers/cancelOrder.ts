/* Autor: Enzo Olivato Pazian */

import {HttpsError, onCall} from "firebase-functions/v2/https";
import {requireAuthenticatedUser} from "../../shared/auth";
import {normalizeString} from "../../shared/validation";
import {getOrderByIdInTransaction} from "../repositories/exchangeRepository";
import {db} from "../../shared/firebase";
import {OrderStatus} from "../types";
import {getUserBalanceForUpdate, getUserWalletStartupForUpdate} from
  "../../users/repositories/userRepository";
import {logger} from "firebase-functions";

export const cancelOrder = onCall(
  async (request) => {
    // ETAPA 1: Verificação, obtenção e normalização de
    // parâmetros obrigatórios

    // Garantindo que o usuário está autenticado
    const user = requireAuthenticatedUser(request);

    // Obtendo e normalizando o UID da ordem
    const orderId = normalizeString(request.data?.orderId);

    // Verificando se o id da ordem está definido após as normalizações
    if (!orderId) {
      throw new HttpsError(
        "invalid-argument",
        "Informe o orderId."
      );
    }

    try {
      // ETAPA 2: A lógica atômica do cancelamento de oferta
      // Iniciando a transação atômica
      await db.runTransaction(async (transaction) => {
        // Obtendo os dados da ordem a partir de seu ID para analisar
        // suas propriedades
        const order = await getOrderByIdInTransaction(transaction, orderId);

        // Se a ordem buscada não está definida (não existe),
        // lança um erro HTTP
        if (!order || !order.data) {
          throw new HttpsError(
            "not-found",
            "Ordem nao encontrada."
          );
        }

        // Se o Id do usuário que abriu a ordem não for o mesmo do
        // usuário logado, emite um erro de permissão
        if (order.data.userId !== user.uid) {
          throw new HttpsError(
            "permission-denied",
            "Você não tem permissão para cancelar esta ordem."
          );
        }

        // Se a ordem não estiver aberta ou parcialmente realizada,
        // emite um erro (a ordem já foi realizada/cancelada)
        if (order.data.status !== "open" && order.data.status !== "partial") {
          throw new HttpsError(
            "failed-precondition",
            "A ordem não está mais aberta e não pode ser cancelada."
          );
        }

        // Mudando o status da ordem para "canceled"
        transaction.update(order.ref, {
          status: "canceled" as OrderStatus,
        });

        // Se a ordem for de compra, realiza a operação atômica
        // de estorno do valor para o saldo do usuário
        if (order.data.type === "buy") {
          // Obtendo o saldo do usuário para realizar o estorno
          const userBalance = await getUserBalanceForUpdate(
            transaction,
            user.uid
          );

          // Se o retorno for nulo, significa que o usuário não
          // foi encontrado no banco de dados, então lança um erro
          if (!userBalance) {
            throw new HttpsError(
              "not-found",
              "Usuário não encontrado."
            );
          }

          // Calculando o valor do estorno a partir da quantidade
          // de tokens pendentes multiplicada pelo preço da ordem
          const refund = order.data.remainingQuantity *
            order.data.priceCents;

          // Devolvendo o valor calculado do saldo congelado para o
          // saldo disponível
          transaction.update(userBalance.ref, {
            balanceFrozenCents: userBalance.balanceFrozenCents - refund,
            balanceAvailableCents: userBalance.balanceAvailableCents + refund,
          });
        } else if (order.data.type === "sell") {
          // Se a ordem for de venda, realiza a operação atômica
          // de estorno da quantidade de tokens ofertada

          // Obtendo os dados da carteira do usuário referente à startup
          // da qual ele ofertou os tokens
          const userWalletStartup = await getUserWalletStartupForUpdate(
            transaction,
            user.uid,
            order.data.startupId
          );

          // Verificando se o usuário possui tokens da startup indicada
          if (!userWalletStartup) {
            throw new HttpsError(
              "not-found",
              "Não foram encontrados tokens dessa startup em sua carteira."
            );
          }

          // Devolvendo os tokens da quantidade indisponível para
          // a quantidade disponível
          transaction.update(userWalletStartup.ref, {
            lockedQuantity: userWalletStartup.lockedQuantity -
              order.data.remainingQuantity,
            availableQuantity: userWalletStartup.availableQuantity +
              order.data.remainingQuantity,
          });
        }
      });

      // Registrando no Logger da Function a mensagem de sucesso
      // após a conclusão da transação
      logger.info("Ordem cancelada com sucesso.", {orderId});

      // Retornando um objeto com o status de sucesso e o id da ordem
      return {
        data: {
          success: true,
          id: orderId,
        },
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
      logger.error("Erro interno ao cancelar ordem: ", error);

      // Em seguida, retornamos um novo erro para que o Flutter
      // receba uma mensagem amigável
      throw new HttpsError(
        "internal",
        "Houve um erro interno ao cancelar sua ordem. " +
        "Tente novamente mais tarde."
      );
    }
  }
);

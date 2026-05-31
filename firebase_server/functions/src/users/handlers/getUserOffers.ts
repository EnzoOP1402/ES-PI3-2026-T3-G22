/* Autor: Enzo Olivato Pazian - 25001654 */

import {HttpsError, onCall} from "firebase-functions/v2/https";
import {requireAuthenticatedUser} from "../../shared/auth";
import {db} from "../../shared/firebase";
import {OfferDocument, OfferListTile} from "../../exchange/types";
import {logger} from "firebase-functions";

/**
 * Firebase Function responsável por listar as ofertas
 * ativas de um usuário.
 */
export const getUserOffers = onCall(
  async (request) => {
    // Garantindo que o usuário está autenticado antes de obter os dados
    const user = requireAuthenticatedUser(request);

    try {
      // Buscando todas as ordens com status "open" ou "partial" que
      // pertencem ao usuário em ordem alfabética
      const offersSnapshot = await db
        .collection("offers")
        .where("status", "in", ["open", "partial"])
        .where("userId", "==", user.uid)
        .orderBy("startupName", "asc")
        .get();

      // Se não existe nenhuma ordem, retorna uma lista vazia
      if (offersSnapshot.empty) {
        return {userOffers: []};
      }

      // Criando a lista que receberá os resultados obtidos e
      // convertidos para o tipo que representa os itens
      // da lista de ordens
      const userOffers: OfferListTile[] = [];

      // Percorrendo o array retornado pelo Firestore,
      // formatando seus itens e adicionando-os à lista
      // que contém os tokens que um usuário possui de cada
      // startup
      offersSnapshot.docs.forEach(
        (doc) => {
          // Convertendo a ordem da iteração atual para o
          // tipo que representa um documento da coleção offers
          const order = doc.data() as OfferDocument;

          // Formatando o objeto para o tipo que representa o item da lista
          // de ordens que será exibida na tela
          const formattedOrder: OfferListTile = {
            id: doc.id,
            startupName: order.startupName,
            tokenName: order.tokenName,
            quantity: order.remainingQuantity,
            priceCents: order.priceCents,
            type: order.type,
            trend: "equal",
            isGoodDeal: true,
          };

          // Adicionando a ordem formatado à lista
          userOffers.push(formattedOrder);
        }
      );

      // Retornando a lista obtida
      return {
        success: true,
        userOffers,
      };
    } catch (error: unknown) {
      // Registra o erro no logger da Function
      logger.error("Erro ao obter as ordens do usuário",
        error);

      // Lança uma exceção que será exibida de forma amigável no front
      throw new HttpsError(
        "internal",
        "Erro ao carregar as ordens do usuário."
      );
    }
  }
);

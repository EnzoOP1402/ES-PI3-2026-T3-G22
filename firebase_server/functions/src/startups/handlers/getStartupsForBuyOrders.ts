/* Autor: Enzo Olivato Pazian */

import {HttpsError, onCall} from "firebase-functions/v2/https";
import {requireAuthenticatedUser} from "../../shared/auth";
import {logger} from "firebase-functions";
import {db} from "../../shared/firebase";
import {StartupDocument, StartupForBuyOrders} from "../types";

/**
 * Firebase Function responsável pela listagem de Startups com tokens
 * emitidos para que uma ordem de compra possa ser aberta.
 */
export const getStartupsForBuyOrders = onCall(
  async (request) => {
    // Garantindo que o usuário está autenticado antes de obter os dados
    requireAuthenticatedUser(request);

    try {
      // Obtendo as startups que tenham tokens emitidos
      const startupSnapshot = await db.collection("Startups")
        .where("totalTokensIssued", ">", 0)
        .get();

      // Se não houver startups com tokens emitidos,
      // retorna uma lista vazia imediatamente
      if (startupSnapshot.empty) {
        return {
          success: true,
          startupsForBuyOrders: [],
        };
      }

      // Declarando a lista que receberá os dados obtidos e
      // convertidos para um modelo com apenas as
      // informações necessárias para a listagem
      const startupsForBuyOrders: StartupForBuyOrders[] = [];

      // Percorrendo o array retornado pelo Firestore,
      // formatando seus itens e adicionando-os à lista
      // de dados formatados
      startupSnapshot.docs.forEach(
        (doc) => {
          // Convertendo o item da iteração atual para o
          // tipo que representa um documento da coleção Startups
          const startupDoc = doc.data() as StartupDocument;

          // Criando o objeto que será inserido na lista final
          const formattedStartup: StartupForBuyOrders = {
            id: doc.id,
            name: startupDoc.name,
            tokenName: startupDoc.tokenName,
            currentTokenPriceCents: startupDoc.currentTokenPriceCents,
          };

          // Adicionando o item formatado à lista
          startupsForBuyOrders.push(formattedStartup);
        }
      );

      // Ordenando o vetor em ordem alfabética para melhorar a
      // visualização dos resultados
      startupsForBuyOrders.sort((a, b) => a.name.localeCompare(b.name));

      // Retornando a lista obtida
      return {
        success: true,
        startupsForBuyOrders,
      };
    } catch (error: unknown) {
      // Registra o erro no logger da Function
      logger.error("Erro ao montar a lista de startups para ordens de compra:",
        error);

      // Lança uma exceção que será exibida de forma amigável no front
      throw new HttpsError(
        "internal",
        "Erro ao carregar a lista de startups disponíveis para compra."
      );
    }
  }
);

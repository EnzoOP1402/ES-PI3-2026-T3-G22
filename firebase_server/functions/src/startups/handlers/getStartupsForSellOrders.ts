/* Autor: Enzo Olivato Pazian */

import {HttpsError, onCall} from "firebase-functions/v2/https";
import {requireAuthenticatedUser} from "../../shared/auth";
import {logger} from "firebase-functions";
import {db} from "../../shared/firebase";
import {StartupForSellOrders} from "../types";
import {WalletDocument} from "../../users/types";

/**
 * Firebase Function responsável pela listagem de Startups das quais
 * um usuário possui tokens em sua carteira para que ele possa abrir
 * uma ordem de venda de tokens.
 */
export const getStartupsForSellOrders = onCall(
  async (request) => {
    // Garantindo que o usuário está autenticado antes de obter os dados
    const user = requireAuthenticatedUser(request);

    try {
      // Obtendo as startups da qual o usuário possui tokens
      // disponíveis para venda
      const walletSnapshot = await db.collection("users")
        .doc(user.uid)
        .collection("wallet")
        .where("availableQuantity", ">", 0)
        .get();

      // Se não houver startups com tokens emitidos,
      // retorna uma lista vazia imediatamente
      if (walletSnapshot.empty) {
        return {
          success: true,
          startupsForSellOrders: [],
        };
      }

      // Declarando a lista que receberá os dados obtidos e
      // convertidos para um modelo com apenas as
      // informações necessárias para a listagem
      const startupsForSellOrders: StartupForSellOrders[] = [];

      // Percorrendo o array retornado pelo Firestore,
      // formatando seus itens e adicionando-os à lista
      // de dados formatados
      walletSnapshot.docs.forEach(
        (doc) => {
          // Convertendo o item da iteração atual para o
          // tipo que representa um documento da coleção Startups
          const walletDoc = doc.data() as WalletDocument;

          // Criando o objeto que será inserido na lista final
          const formattedStartup: StartupForSellOrders = {
            id: walletDoc.startupId || doc.id,
            name: walletDoc.startupName,
            tokenName: walletDoc.tokenName,
          };

          // Adicionando o item formatado à lista
          startupsForSellOrders.push(formattedStartup);
        }
      );

      // Ordenando o vetor em ordem alfabética para melhorar a
      // visualização dos resultados
      startupsForSellOrders.sort((a, b) => a.name.localeCompare(b.name));

      // Retornando a lista obtida
      return {
        success: true,
        startupsForSellOrders,
      };
    } catch (error: unknown) {
      // Registra o erro no logger da Function
      logger.error("Erro ao montar a lista de startups para ordens de venda:",
        error);

      // Lança uma exceção que será exibida de forma amigável no front
      throw new HttpsError(
        "internal",
        "Erro ao carregar a lista de startups disponíveis para venda."
      );
    }
  }
);

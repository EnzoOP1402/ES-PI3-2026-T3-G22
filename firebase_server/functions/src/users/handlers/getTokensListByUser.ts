/* Autor: Enzo Olivato Pazian */

import {HttpsError, onCall} from "firebase-functions/https";
import {requireAuthenticatedUser} from "../../shared/auth";
import {db} from "../../shared/firebase";
import {WalletDocument, WalletListTile} from "../types";
import {logger} from "firebase-functions";

/**
 * Firebase Function responsável por obter uma lista com a quantidade de
 * tokens que um usuário possui por startup a partir dos dados armazenados
 * em sua subcoleção `wallet`.
 */
export const getTokensListByUser = onCall(
  async (request) => {
    // Garantindo que o usuário está autenticado antes de obter os dados
    const user = requireAuthenticatedUser(request);

    try {
      // Referenciando carteira do usuário
      const userWallet = db.collection("users")
        .doc(user.uid)
        .collection("wallet");

      // Obtendo os dados da carteira e ordenando os
      // resultados em ordem decrescente de quantidade de
      // tokens e alfabética
      const walletSnapshot = await userWallet
        .orderBy("availableQuantity", "desc")
        .orderBy("startupName", "asc")
        .get();

      // Criando a lista que receberá os resultados obtidos e
      // convertidos para o tipo que representa os itens
      // da lista de tokens
      const tokenList: WalletListTile[] = [];

      // Percorrendo o array retornado pelo Firestore,
      // formatando seus itens e adicionando-os à lista
      // que contém os tokens que um usuário possui de cada
      // startup
      walletSnapshot.docs.forEach(
        (doc) => {
          // Convertendo o item da iteração atual para o
          // tipo que representa um documento da coleção Wallet
          const item = doc.data() as WalletDocument;
          // Definindo a quantidade real (disponível + bloqueado no mercado)
          const available = item.availableQuantity || 0;
          const locked = item.lockedQuantity || 0;
          const totalQuantity = available + locked;

          // Filtro para não exibir startups cujos tokens foram todos vendidos
          if (totalQuantity <= 0) return;

          // Criando o objeto que será inserido na lista
          // final a partir do item anterior
          const formattedItem: WalletListTile = {
            startupId: item.startupId,
            startupName: item.startupName,
            tokenName: item.tokenName,
            quantity: item.availableQuantity,
          };

          // Adicionando o item formatado à lista
          tokenList.push(formattedItem);
        }
      );

      // Retornando a lista obtida
      return {
        success: true,
        tokenList,
      };
    } catch (error: unknown) {
      // Registra o erro no logger da Function
      logger.error("Erro ao obter os tokens por startup do usuário",
        error);

      // Lança uma exceção que será exibida de forma amigável no front
      throw new HttpsError(
        "internal",
        "Erro ao carregar os tokens do usuário."
      );
    }
  }
);

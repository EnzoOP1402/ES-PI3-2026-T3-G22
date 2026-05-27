/* Autor: Enzo Olivato Pazian */

import {HttpsError, onCall} from "firebase-functions/https";
import {requireAuthenticatedUser} from "../../shared/auth";
import {db} from "../../shared/firebase";
import {logger} from "firebase-functions";
import {OfferDocument, OfferListTile, PriceTrend} from "../types";
import {normalizeString} from "../../shared/validation";
import {getStartupById} from "../../startups";

/**
 * Firebase Function responsável pelo carregamento das informações
 * exibidas na tela do balcão de tokens de uma startup específica,
 * exibindo as ordens de compra e venda que ainda não foram realizadas.
 */
export const getExchangeBoardByStartup = onCall(
  async (request) => {
    // Garantindo que o usuário está autenticado antes de obter os dados
    requireAuthenticatedUser(request);

    // Obtendo e normalizando o UID da startup
    const startupId = normalizeString(request.data?.startupId);

    // Verificando se o id da startup está definido após a normalização
    if (!startupId) {
      throw new HttpsError(
        "invalid-argument",
        "Informe o startupId."
      );
    }

    try {
      // Obtendo os dados da startup a partir de seu ID para o
      // preenchimento correto das outras informações advindas
      // dela (nome e nome do token)
      const startup = await getStartupById(startupId);

      // Se a startup buscada não está definida (não existe),
      // lança um erro HTTP
      if (!startup) {
        throw new HttpsError(
          "not-found",
          "Startup nao encontrada."
        );
      }

      // Buscando todas as ordens com status "open" ou "partial" daquela
      // startup
      const offersSnapshot = await db
        .collection("offers")
        .where("status", "in", ["open", "partial"])
        .where("startupId", "==", startupId)
        .get();

      // Se não existe nenhuma ordem, retorna ambas as listas vazias
      if (offersSnapshot.empty) {
        return {sellOrders: [], buyOrders: []};
      }

      // Obtendo o preço a mercado para definir os indicativos
      const marketPrice = startup.currentTokenPriceCents || 0;

      // Criando as listas de ordens vazias que serão populadas em apenas
      // um loop
      const sellOrders: OfferListTile[] = [];
      const buyOrders: OfferListTile[] = [];

      offersSnapshot.docs.forEach((doc) => {
        // Convertendo o documento da iteração para a estrutura com
        // o tipo de dado dos documentos de oferta
        const order = doc.data() as OfferDocument;

        // Calculando a tendência de preço
        let trend: PriceTrend = "equal";
        if (order.priceCents > marketPrice) trend = "up";
        if (order.priceCents < marketPrice) trend = "down";

        // Definindo se a oferta é vantajosa para quem está olhando o balcão
        // Ordem de Venda abaixo do mercado = Bom para comprar (true)
        // Ordem de Compra acima do mercado = Bom para vender (true)
        const isGoodDeal = order.type === "sell" ?
          order.priceCents <= marketPrice :
          order.priceCents >= marketPrice;

        // Formatando o objeto para o tipo que representa o item da lista
        // de ordens que será exibida na tela
        const formattedOrder: OfferListTile = {
          id: doc.id,
          startupName: order.startupName,
          tokenName: order.tokenName,
          quantity: order.remainingQuantity,
          priceCents: order.priceCents,
          trend,
          isGoodDeal,
        };

        // Separa dinamicamente sem precisar de .find() posterior
        if (order.type === "sell") {
          sellOrders.push(formattedOrder);
        } else if (order.type === "buy") {
          buyOrders.push(formattedOrder);
        }
      });

      // Agora aplicamos apenas a ordenação financeira nativa do mercado
      // Mais baratas primeiro
      sellOrders.sort((a, b) => a.priceCents - b.priceCents);
      // Mais caras primeiro
      buyOrders.sort((a, b) => b.priceCents - a.priceCents);

      // Retornando as listas obtidas
      return {
        success: true,
        sellOrders,
        buyOrders,
      };
    } catch (error) {
      // Registra o erro no logger da Function
      logger.error("Erro ao montar o painel do balcão de tokens para startup:",
        error);

      // Lança uma exceção que será exibida de forma amigável no front
      throw new HttpsError(
        "internal",
        "Erro ao carregar os dados do balcão para a startup"
      );
    }
  }
);

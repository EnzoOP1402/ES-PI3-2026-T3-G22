/* Autor: Enzo Olivato Pazian */

import {HttpsError, onCall} from "firebase-functions/https";
import {requireAuthenticatedUser} from "../../shared/auth";
import {db} from "../../shared/firebase";
import {logger} from "firebase-functions";
import {OfferDocument} from "../types";

export const getExchangeBoard = onCall(
  async (request) => {
    requireAuthenticatedUser(request);

    try {
      // Buscando todas as ordens com status "open"
      const offersSnapshot = await db
        .collection("offers")
        .where("status", "==", "open")
        .get();

      // Se não existe nenhuma ordem, retorna ambas as listas vazias
      if (offersSnapshot.empty) {
        return {sellOrders: [], buyOrders: []};
      }

      // Convertendo os documentos para a nossa estrutura tipada
      const allOffers = offersSnapshot.docs.map((doc) => ({
        id: doc.id,
        ...(doc.data() as OfferDocument),
      }));

      // 2. OTIMIZAÇÃO CRÍTICA: Coletar IDs únicos de startups para
      // buscar os preços de mercado de uma vez só
      const startupIds = Array.from(new Set(allOffers.map((o) => o.startupId)));

      const startupMarketPrices: Record<string, number> = {};

      // O Firestore permite a busca 'in' com até 30 IDs por lote
      if (startupIds.length > 0) {
        // Separando em pedaços de 30 se necessário, ou buscando
        // direto se for menor
        const startupsSnapshot = await db
          .collection("startups")
          .where("__name__", "in", startupIds.slice(0, 30))
          .get();

        startupsSnapshot.forEach((doc) => {
          const data = doc.data();
          // Armazena o preço atual da startup mapeado pelo ID dela
          startupMarketPrices[doc.id] = data.currentTokenPriceCents || 0;
        });
      }

      // 3. Processar as ordens injetando a regra de tendência de preço
      const processedOrders = allOffers.map((order) => {
        const marketPrice = startupMarketPrices[order.startupId] || 0;

        let trend: "up" | "down" | "equal" = "equal";
        if (order.priceCents > marketPrice) trend = "up";
        if (order.priceCents < marketPrice) trend = "down";

        // Definindo se a oferta é vantajosa para quem está olhando o balcão
        // Ordem de Venda abaixo do mercado = Bom para comprar (true)
        // Ordem de Compra acima do mercado = Bom para vender (true)
        const isGoodDeal = order.type === "sell" ?
          order.priceCents <= marketPrice :
          order.priceCents >= marketPrice;

        return {
          id: order.id,
          startupName: order.startupName,
          tokenName: order.tokenName,
          quantity: order.remainingQuantity,
          priceCents: order.priceCents,
          trend,
          isGoodDeal,
        };
      });

      // 4. Separar em duas listas e aplicar as ordenações de mercado financeiro
      // Ordens de venda: Mais baratas primeiro (melhor preço de
      // compra para o usuário)
      const sellOrders = processedOrders
        .filter((o) => allOffers.find(
          (raw) => raw.id === o.id
        )?.type === "sell")
        .sort((a, b) => a.priceCents - b.priceCents);

      // Ordens de compra: Mais caras primeiro (melhor preço de venda
      // para o usuário)
      const buyOrders = processedOrders
        .filter((o) => allOffers.find((raw) => raw.id === o.id)?.type === "buy")
        .sort((a, b) => b.priceCents - a.priceCents);

      return {
        sellOrders,
        buyOrders,
      };
    } catch (error) {
      logger.error("Erro ao montar o painel do balcão de tokens:", error);
      throw new HttpsError("internal", "Erro ao carregar os dados do balcão.");
    }
  }
);

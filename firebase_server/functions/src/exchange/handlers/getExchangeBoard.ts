/* Autor: Enzo Olivato Pazian */

import {HttpsError, onCall} from "firebase-functions/https";
import {requireAuthenticatedUser} from "../../shared/auth";
import {db} from "../../shared/firebase";
import {logger} from "firebase-functions";
import {OfferDocument, OfferListTile, PriceTrend} from "../types";

/**
 * Firebase Function responsável pelo carregamento das informações
 * exibidas na tela inicial do balcão de tokens, exibindo as ordens
 * de compra e venda que ainda não foram realizadas.
 */
export const getExchangeBoard = onCall(
  async (request) => {
    // Garantindo que o usuário está autenticado antes de obter os dados
    requireAuthenticatedUser(request);

    try {
      // Buscando todas as ordens com status "open" ou "partial"
      const offersSnapshot = await db
        .collection("offers")
        .where("status", "in", ["open", "partial"])
        .get();

      // Se não existe nenhuma ordem, retorna ambas as listas vazias
      if (offersSnapshot.empty) {
        return {sellOrders: [], buyOrders: []};
      }

      // Convertendo os documentos para a estrutura com o tipo de dado dos
      // documentos de oferta
      const allOffers = offersSnapshot.docs.map((doc) => ({
        id: doc.id,
        ...(doc.data() as OfferDocument),
      }));

      // Otimizando a busca de preços: coletando IDs únicos
      // de startups para buscar os preços de mercado de
      // uma vez só (que serão usados na exibição do
      // indicador de bom negócio)
      // Armazena em uma lista o resultado do mapeamento do
      // ID de todas as startups e removendo os que se
      // repetem para evitar buscas repetidas
      const startupIds = Array.from(new Set(allOffers.map(
        (offer) => offer.startupId)
      ));

      // Criando um "Map" que receberá o preço de mercado
      // de cada startup e os armazenará no par chave e
      // valor contendo o ID da startup e seu preço
      const startupMarketPrices: Record<string, number> = {};

      // Verifica se a lista de IDs é maior que 0
      if (startupIds.length > 0) {
        // Fazendo a busca dos dados das startups no
        // Firestore de acordo com a lista de IDs, separando
        // em pedaços de até 30 se necessário (já que o
        // Firestore limita a query a 30 itens com o
        // operador "in"), ou buscando direto se for menor
        const startupsSnapshot = await db
          .collection("Startups")
          .where("__name__", "in", startupIds.slice(0, 30))
          .get();

        // Para cada documento obtido, armazena no "Map" o
        // valor de mercado atual de cada uma
        startupsSnapshot.forEach((doc) => {
          const data = doc.data();
          startupMarketPrices[doc.id] = data.currentTokenPriceCents || 0;
        });
      }

      // Processando as ordens injetando a regra de
      // tendência de preço: se o preço é maior que
      // o de mercado, a tendência está alta, senão
      // está baixa ou igual
      const processedOrders = allOffers.map((order) => {
        const marketPrice = startupMarketPrices[order.startupId] || 0;

        let trend: PriceTrend = "equal";
        if (order.priceCents > marketPrice) trend = "up";
        if (order.priceCents < marketPrice) trend = "down";

        // Definindo se a oferta é vantajosa para quem está olhando o balcão
        // Ordem de Venda abaixo do mercado = Bom para comprar (true)
        // Ordem de Compra acima do mercado = Bom para vender (true)
        const isGoodDeal = order.type === "sell" ?
          order.priceCents <= marketPrice :
          order.priceCents >= marketPrice;

        // Retornando objeto que representa o item da lista
        // de ordens que será exibido na tela
        return {
          id: order.id,
          startupName: order.startupName,
          tokenName: order.tokenName,
          quantity: order.remainingQuantity,
          priceCents: order.priceCents,
          trend,
          isGoodDeal,
        } as OfferListTile;
      });

      // Separando em duas listas e aplicando as ordenações de mercado
      // financeiro

      // Ordens de venda: Mais baratas primeiro (melhor preço de
      // compra para o usuário)
      // Filtrando todas as ordens obtidas cujo tipo é "sell" e as
      // ordenando em ordem crescente (a - b)
      const sellOrders = processedOrders
        .filter((offer) => allOffers.find(
          (raw) => raw.id === offer.id
        )?.type === "sell")
        .sort((a, b) => a.priceCents - b.priceCents);

      // Ordens de compra: Mais caras primeiro (melhor preço de venda
      // para o usuário)
      // Filtrando todas as ordens obtidas cujo tipo é "buy" e as
      // ordenando em ordem decrescente (b - a)
      const buyOrders = processedOrders
        .filter((offer) => allOffers.find(
          (raw) => raw.id === offer.id
        )?.type === "buy")
        .sort((a, b) => b.priceCents - a.priceCents);

      // Retornando as listas obtidas
      return {
        sellOrders,
        buyOrders,
      };
    } catch (error) {
      // Registra o erro no logger da Function
      logger.error("Erro ao montar o painel do balcão de tokens:", error);

      // Lança uma exceção que será exibida de forma amigável no front
      throw new HttpsError(
        "internal",
        "Erro ao carregar os dados do balcão para a startup."
      );
    }
  }
);

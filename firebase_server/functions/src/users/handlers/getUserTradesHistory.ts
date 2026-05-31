/* Autor: Enzo Olivato Pazian */

import {onCall, HttpsError} from "firebase-functions/v2/https";
import {FieldPath, Filter, Timestamp} from "firebase-admin/firestore";
import {logger} from "firebase-functions/v2";
import {requireAuthenticatedUser} from "../../shared/auth";
import {db} from "../../shared/firebase";
import {TradeDocument} from "../../exchange/types";
import {StartupDocument} from "../../startups/types";

/**
 * Firebase Function responsável por obter a lista de transações
 * que um usuário realizou a partir dos dados armazenados
 * na coleção `trades`.
 */
export const getUserTradesHistory = onCall(
  async (request) => {
    // Garantir que o usuário está autenticado
    const user = requireAuthenticatedUser(request);

    try {
      // Buscando transações em que o usuário é o comprador OU o vendedor
      const tradesSnapshot = await db.collection("trades")
        .where(
          Filter.or(
            Filter.where("buyerId", "==", user.uid),
            Filter.where("sellerId", "==", user.uid)
          )
        ).get();

      // Se o usuário não possuir transações, retorna a lista vazia
      if (tradesSnapshot.empty) {
        return {transactions: []};
      }

      // Extraindo IDs únicos de startups para
      // fazer o carregamento em lote
      const startupIds = new Set<string>();

      tradesSnapshot.docs.forEach((doc) => {
        const data = doc.data() as TradeDocument;
        if (data.startupId) {
          startupIds.add(data.startupId);
        }
      });

      // Criando um mapa em memória para associar o
      // ID da Startup ao nome do Token
      const startupTokenNameMap: Record<string, string> = {};

      // Se encontrou as startups, realiza a busca
      if (startupIds.size > 0) {
        // Convertendo o Set de startups em um array para
        // dividi-lo
        const startupIdsArray = Array.from(startupIds);

        // Dividindo o array em blocos de no máximo 30 itens
        // para respeitar o limite do Firestore
        const chunks: string[][] = [];
        for (let i = 0; i < startupIdsArray.length; i += 30) {
          chunks.push(startupIdsArray.slice(i, i + 30));
        }

        // Executando as buscas de todos os blocos em paralelo
        const fetchPromises = chunks.map((chunk) =>
          db.collection("Startups")
            .where(FieldPath.documentId(), "in", chunk)
            .get()
        );

        // Executando as buscas em lote
        const snapshots = await Promise.all(fetchPromises);

        // Alimentando o mapa de nomes
        snapshots.forEach((startupsSnapshot) => {
          startupsSnapshot.docs.forEach((doc) => {
            const startupData = doc.data() as StartupDocument;
            startupTokenNameMap[doc.id] = startupData.tokenName||
             "Token";
          });
        });
      }

      // Mapeando e processando dos dados
      const transactions = tradesSnapshot.docs.map((doc) => {
        // Obtendo e convertendo os dados da transação atual
        const data = doc.data() as TradeDocument;

        // Verificando o papel do usuário nesta transação específica
        const isBuyer = data.buyerId === user.uid;

        // Convertendo a data de registro para Timestamp para
        // poder formatá-la para o padrão ISO
        const registeredAtTimestamp = data.registeredAt as unknown as Timestamp;

        // Convertendo a data para o padrão ISO
        const dateIso = (
          registeredAtTimestamp &&
          typeof registeredAtTimestamp.toDate === "function"
        ) ?
          registeredAtTimestamp.toDate().toISOString() :
          new Date().toISOString();

        // Resgatando o valor monetário total
        // (se houver preço unitário * quantidade) ou usando o amount direto
        // Se no seu banco você armazena tokenPriceCents e quantity,
        // o valor pode ser calculado aqui
        const tokenPriceCents = data.unitPriceCents || 0;
        const totalAmountCents = tokenPriceCents * (data.quantity || 0);

        return {
          id: doc.id,
          // Se ele é o comprador, é uma ordem de 'compra'
          // Se é vendedor, 'venda'
          operationType: isBuyer ? "compra" : "venda",
          // Se comprou, o dinheiro saiu do saldo (negativo)
          // Se vendeu, entrou (positivo).
          isNegative: isBuyer,
          quantity: data.quantity || 0,
          // Convertendo o total de centavos para reais
          // para facilitar na UI
          amount: totalAmountCents / 100,
          // Busca o nome resolvido no nosso
          // mapa em memória
          tokenName: startupTokenNameMap[data.startupId] || "Token",
          date: dateIso,
        };
      });

      // Ordena o histórico da transação mais recente para a
      // mais antiga (em memória)
      transactions.sort((a, b) => {
        return new Date(b.date).getTime() - new Date(a.date).getTime();
      });

      // Retornando a lista de transações obtidas
      return {transactions};
    } catch (error) {
      logger.error("Erro ao buscar histórico de transações:", error);
      throw new HttpsError("internal", "Erro ao processar o histórico.");
    }
  }
);

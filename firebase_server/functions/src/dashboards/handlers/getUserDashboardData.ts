/* Autor: Enzo Olivato Pazian */

import {HttpsError, onCall} from "firebase-functions/v2/https";
import {
  ChartPoint,
  DashboardRequest,
  PriceHistoryDocument,
  StartupDashboardData,
} from "../types";
import {requireAuthenticatedUser} from "../../shared/auth";
import {logger} from "firebase-functions";
import {db} from "../../shared/firebase";
import {FieldPath} from "firebase-admin/firestore";
import {StartupDocument} from "../../startups/types";

export const getUserDashboardData = onCall<DashboardRequest>(
  {memory: "512MiB"},
  async (request): Promise<StartupDashboardData[]> => {
    // Garantindo que o usuário está autenticado
    // e obtendo seus dados
    const user = requireAuthenticatedUser(request);

    // Obtendo os parâmetros da requisição e, se algum
    // não estiver definido, assumindo os valores padrões
    const period = request.data.period || "24h";
    const searchQuery = request.data.searchQuery?.trim().toLowerCase() || "";

    try {
      // ETAPA 1: Buscando as startups que o usuário possui
      // em sua carteira

      // Referenciando carteira do usuário
      const userWallet = db.collection("users")
        .doc(user.uid)
        .collection("wallet");

      // Obtendo os dados da carteira e ordenando os
      // resultados em ordem decrescente de quantidade de
      // tokens e alfabética
      const userWalletSnapshot = await userWallet
        .orderBy("availableQuantity", "desc")
        .orderBy("startupName", "asc")
        .get();

      // Se o usuário não possuir tokens, retorna uma lista
      // vazia
      if (userWalletSnapshot.empty) {
        return [];
      }

      // Extraindo apenas os IDs das startups das quais ele
      // possui tokens
      const ownedStartupIds = userWalletSnapshot.docs.map(
        (doc) => (doc.data().startupId)
      );

      // ETAPA 2: Buscando as imagens das startups com proteção de limite
      // (chunks de 30)

      // Definindo o limite
      const chunkSize = 30;
      // Inicializando a lista de buscas
      const startupPromises = [];

      // Obtendo os dados das startups contidas no array
      // de startups da carteira do usuário de 30 em 30
      for (let i = 0; i < ownedStartupIds.length; i += chunkSize) {
        // Obtendo a sub-lista
        const chunk = ownedStartupIds.slice(i, i + chunkSize);
        // Obtendo os dados
        const promise = db.collection("Startups")
          .where(FieldPath.documentId(), "in", chunk)
          .get();
        // Adicionando à fila de execução
        startupPromises.push(promise);
      }

      // Executa todas as queries em paralelo e junta os resultados
      const snapshots = await Promise.all(startupPromises);
      const allStartupDocs = snapshots.flatMap((snap) => snap.docs);

      // Filtrando os dados retornados com base no parâmetro de busca pelo nome
      const filteredStartups = allStartupDocs.filter((doc) => {
        const name: string = doc.data().name?.toLowerCase() || "";
        return name.includes(searchQuery);
      });

      // Se o resultado filtrado não existir, retorna a
      // lista vazia
      if (filteredStartups.length === 0) return [];

      // ETAPA 3: Definindo as regras com base no período
      // indicado no parâmetro

      // Definindo a subcoleção de atualizações diária como padrão
      let subcollectionName = "price_history_daily";
      // Inicializando a variável que definirá o início do intervalo
      let timeLimitMs = 0;

      // Obtendo a data atual e a quantidade de milissegundos de um dia
      const now = Date.now();
      const dayMS = 24 * 60 * 60 * 1000;

      // Definindo o intervalo com base no parâmetro
      switch (period) {
      case "24h": {
        // Se a visualização for da variação diária,
        // a busca será feita na subcoleção de variação
        // diária
        subcollectionName = "price_history_hourly";
        // O intervalo é a data de agora menos a quantidade
        // de milissegundos de 1 dia
        timeLimitMs = now - dayMS;
        break;
      }
      case "7d": {
        // O intervalo é a data de agora menos a quantidade
        // de milissegundos de 7 dias (1 semana)
        timeLimitMs = now - (7 * dayMS);
        break;
      }
      case "1m": {
        // O intervalo é a data de agora menos a quantidade
        // de milissegundos de 30 dias (1 mês)
        timeLimitMs = now - (30 * dayMS);
        break;
      }
      case "6m": {
        // O intervalo é a data de agora menos a quantidade
        // de milissegundos de 180 dias (6 meses)
        timeLimitMs = now - (180 * dayMS);
        break;
      }
      case "1y": {
        // O intervalo é a data de agora menos a quantidade
        // de milissegundos de 365 dias (1 ano)
        timeLimitMs = now - (365 * dayMS);
        break;
      }
      }

      // Obtendo a data de início do intervalo (referente ao
      // tempo calculado)
      const startDate = new Date(timeLimitMs);

      // ETAPA 4: Buscando os históricos paralelamente

      // Mapeando um array de promises para rodar todas as buscas
      // do banco ao mesmo tempo e melhorar a performance em relação
      // a buscas individuais
      const dashboardPromises = filteredStartups.map(
        async (startupDoc) => {
          // Convertendo os dados da startup para o tipo que a representa
          const startupData = startupDoc.data() as StartupDocument;
          // Armazenando o ID da startup
          const startupId = startupDoc.id;
          // Obtendo o valor atual para calcular a valorização geral
          const currentPriceCents = startupData.currentTokenPriceCents || 100;

          // Buscando os dados da linha do tempo apropriada da startup atual
          const historySnapshot = await db.collection("Startups")
            .doc(startupId)
            .collection(subcollectionName)
            .where("timestamp", ">=", startDate)
            .orderBy("timestamp", "asc")
            .get();

          // Inicializando a lista que receberá os pontos do gráfico
          const chartData: ChartPoint[] = [];
          // Definindo o valor inicial dos tokens
          let firstPriceCents = currentPriceCents;

          // Se a subcoleção de horas possuir dados, obtemos os dados
          // para alimentar o gráfico
          if (!historySnapshot.empty) {
            // O primeiro documento do período dita o preço base
            // para calcularmos a variação
            firstPriceCents = historySnapshot.docs[0]
              .data().averagePriceCents;

            historySnapshot.forEach(
              (doc) => {
                // Convertendo o objeto da iteração atual para o tipo que
                // representa um documento da coleção de históricos
                const data = doc.data() as PriceHistoryDocument;

                // Obtendo o valor do eixo X
                const time = data.timestamp ?
                  data.timestamp.toMillis() :
                  Date.now();

                // Montando o par ordenado para o gráfico e adicionando-o
                // à lista de pares
                chartData.push({
                  // No eixo X envia a data
                  x: time,
                  // No eixo Y exibe o valor do token convertido em R$
                  y: data.averagePriceCents / 100,
                });
              }
            );
          }

          // Adicionando o ponto exato do momento atual para o gráfico
          // encerrar no preço de agora
          chartData.push({
            // Adicionando a data atual ao eixo X
            x: now,
            y: (currentPriceCents / 100),
          });

          // ETAPA 5: Calculando a variação percentual

          // Inicializando a variação
          let variation = 0;

          // Se o valor inicial é maior que o da inicializaçao,
          // calcula a variação
          if (firstPriceCents > 0) {
            variation = ((currentPriceCents - firstPriceCents) /
              firstPriceCents) * 100;
          }

          // Arredondando para 1 casa decimal
          const variationPercentage = Number(Math.abs(variation).toFixed(1));
          // Obtendo o indicador de variação positiva
          const isPositive = variation >= 0;

          // Retornando o conjunto de dados
          return {
            startupId,
            startupName: startupData.name,
            logoUrl: startupData.coverImageUrl || "",
            currentPrice: currentPriceCents / 100,
            variationPercentage,
            isPositive,
            chartData,
          } as StartupDashboardData;
        }
      );

      // Aguarda todas as startups terminarem seus cálculos
      const responseData = await Promise.all(dashboardPromises);
      // Retorna o array com os dados
      return responseData;
    } catch (error: unknown) {
      logger.error("Erro ao processar os dashboards do usuário: ", error);
      throw new HttpsError(
        "internal",
        "Falha ao gerar os dados do dashboard."
      );
    }
  }
);

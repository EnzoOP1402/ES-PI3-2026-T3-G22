/* Autor: Enzo Olivato Pazian */

import {onSchedule} from "firebase-functions/v2/scheduler";
import {db} from "../../shared/firebase";
import {logger} from "firebase-functions/v2";
import {StartupDocument} from "../../startups/types";
import {TradeDocument} from "../../exchange/types";
import {FieldValue} from "firebase-admin/firestore";

/**
 * Trigger agendado para o cálculo da variação diária
 * com base nas transações realizadas.
 *
 * O Trigger é agendado para ser acionado todos os dias
 * à 00:00. Seu funcionamento consiste em percorrer
 * a coleção de `trades` para cada startup registrada
 * e calcular o preço unitário médio das transações
 * do última dia, e registrar a atualização em uma
 * subcoleção de cada startup chamada `price_history_daily`,
 * que será usada para alimentar o gráficos de intervalos
 * superiores a 24 horas dos dashboards.
 */
export const calculateDailyTokenPrice = onSchedule(
  {
    // Expressão Cron: Roda sempre à 00:00
    schedule: "0 0 * * *",
    // Força a execução baseada no horário de Brasília
    timeZone: "America/Sao_Paulo",
    // Define o uso de memória (baixo custo)
    memory: "256MiB",
  },
  async (): Promise<void> => {
    // Inicializando o lote que realizará a escrita em massa
    // dos novos preços
    const batch = db.batch();

    // ETAPA 1: Configurando a janela de tempo da valorização
    // (últimas 24 horas)

    // Obtendo a data atual
    const now = new Date();

    // Definindo o fim do intervalo (dia atual)
    const endDate = new Date(
      now.getFullYear(),
      now.getMonth(),
      now.getDate(),
      0, 0, 0, 0
    );

    // Definindo o início do intervalo (1 dia a menos do fim)
    const startDate = new Date(endDate.getTime() - (24 * 60 * 60 * 1000));

    // Criando o ID fixo do documento que será gerado nas
    // subcoleções das startups usando os dados de `startDate`
    // (o dia anterior)
    const year = startDate.getFullYear();
    // Somando +1 ao valor do mês pelo fato do método retornar
    // o valor referente ao índice do vetor de meses
    const month = String(startDate.getMonth() + 1)
    // Usamos padStart para manter o número com 2 casas decimais
    // e adicionar 0 à esquerda às posições vazias
      .padStart(2, "0");
    const day = String(startDate.getDate())
      .padStart(2, "0");
    // Construindo o ID com os dados obtidos no modelo YYYY-MM-DD
    const documentId = `${year}-${month}-${day}`;

    try {
      // ETAPA 2: Buscando as startups ativas
      const startupsSnapshot = await db.collection("Startups").get();

      // Se nenhuma startup foi obtida, encerra a função
      if (startupsSnapshot.empty) {
        logger.error("Nenhuma startup cadastrada no sistema.");
        return;
      }

      // ETAPA 3: Processando cada startup individualmente
      for (const startupDoc of startupsSnapshot.docs) {
        // Convertendo o objeto recebido para adequar os campos
        const startup = startupDoc.data() as StartupDocument;
        const startupId = startupDoc.id;
        const currentPrice = startup.currentTokenPriceCents;

        // Consultando transações da startup que ocorreram
        // somente dentro do intervalo definido
        const tradesSnapshot = await db.collection("trades")
          .where("startupId", "==", startupId)
          .where("registeredAt", ">=", startDate)
          .where("registeredAt", "<", endDate)
          .get();

        // Definindo o valor final padrão caso não haja nenhuma
        // transação ocorrida no período
        let dailyAverage = currentPrice;

        // Se houveram transações, calcula a média ponderada
        // do preço unitário do token
        if (!tradesSnapshot.empty) {
          // Inicializando as variáveis que serão incrementadas
          // na média
          let totalVolumeCents = 0;
          let totalTokens = 0;

          // Percorre a lista de documentos de transações para
          // calcular a média
          tradesSnapshot.forEach((doc) => {
            const trade = doc.data() as TradeDocument;
            const price = Number(trade.unitPriceCents);
            const quantity = Number(trade.quantity);

            // Proteção para evitar somar valores nulos ou
            // strings por erro de digitação
            if (!isNaN(price) && !isNaN(quantity)) {
              // Incrementa o valor total de uma transação
              totalVolumeCents += price * quantity;
              // Incrementa a quantidade comprada
              totalTokens += quantity;
            }
          });

          // Se a quantidade de tokens foi incrementada
          // (houveram transações para a startup específica),
          // calcula a média
          if (totalTokens > 0) {
            dailyAverage = Math.round(
              totalVolumeCents / totalTokens
            );
          }
        }

        // ETAPA 4: Preparando a gravação na subcoleção price_history_daily

        // Criando a referência para a subcoleção do histórico através do ID
        // cronológico criado anteriormente
        const historyRef = db.collection("Startups")
          .doc(startupId)
          .collection("price_history_daily")
          .doc(documentId);

        // Adiciona a operação de escrita do histórico ao lote
        batch.set(
          historyRef, {
            averagePriceCents: dailyAverage,
            timestamp: FieldValue.serverTimestamp(),
          },
          {merge: true}
        );

        // Registrando uma mensagem de sucesso para cada startup
        logger.info(`Valorização diária da startup ${startupId} `+
          `atualizada à(s) ${documentId}.`);
      }

      // ETAPA 5: Executando todas as escritas de uma só vez

      // Commitando as alterações
      await batch.commit();
      // Emitindo uma mensagem de sucesso
      logger.info("Sucesso! Processamento diário concluído com"+
        `sucesso para o ID diário ${documentId}`);
      // Encerrando o Trigger
      return;
    } catch (error: unknown) {
      // Se houver algum erro, emite uma mensagem e encerra o Trigger
      logger.error("Erro! Falha no trigger diário: ", error);
    }
  }
);

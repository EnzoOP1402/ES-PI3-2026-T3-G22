/* Autor: Enzo Olivato Pazian */

import {onCall, HttpsError} from "firebase-functions/v2/https";
import {db} from "../../shared/firebase";
import {logger} from "firebase-functions/v2";
import {requireAuthenticatedUser} from "../../shared/auth";

// Mapeamento exato dos preços atuais extraídos como referência
const STARTUP_BASELINES: { [key: string]: number } = {
  "AgroSense": 160,
  "CardVision": 12,
  "HealthVibe": 5,
  "Metalive": 9,
  "NotaCerta": 70,
  "PetMatch": 90,
  "SafePay": 166,
  "UrbanMob": 200,
};

/**
 * Function responsável pela inserção de dados em massa nos
 * históricos de valorização para alimentar os gráficos de
 * variação das startups.
 */
export const seedHistoricalData = onCall(
  // Mais tempo e memória para a inserção em massa
  {memory: "512MiB", timeoutSeconds: 240},
  async (request) => {
    // Exigindo autenticação
    requireAuthenticatedUser(request);

    try {
      // Obtendo os dados das startups
      const startupsSnapshot = await db.collection("Startups").get();

      // Se não encontrou nenhuma, lança um erro
      if (startupsSnapshot.empty) {
        throw new HttpsError(
          "not-found",
          "Nenhuma startup encontrada no banco para aplicar o seed."
        );
      }

      // Inicializando o lote
      let batch = db.batch();
      // Inicializando o contador de operações (limitador de lote)
      let operationCount = 0;
      // Obtendo a data atual
      const now = new Date();

      // Função utilitária para formatar os IDs cronológicos
      // idênticos aos Triggers
      const pad = (n: number) => String(n).padStart(2, "0");

      // Iniciando o loop da mudança
      for (const startupDoc of startupsSnapshot.docs) {
        // Obtém o ID da iteração atual
        const startupId = startupDoc.id;
        // Obtém o nome da startup atual
        const startupName = startupDoc.data().name as string;

        // Verifica se a startup atual faz parte do  mapa de baselines
        // Se não encontrar por nome exato, tenta por aproximação
        const matchedKey = Object.keys(STARTUP_BASELINES).find(
          (key) => startupName?.toLowerCase().includes(key.toLowerCase())
        );

        // Se não encontrou a startup, emite uma mensagem de erro
        // e avança para a próxima iteração
        if (!matchedKey) {
          logger.warn(`Startup "${startupName}"
            não encontrada no mapeamento de baselines. Pulando...`);
          continue;
        }

        // Obtém o preço da startup atual
        const baselinePrice = STARTUP_BASELINES[matchedKey];

        // ETAPA 1: Gerando dados horários (Últimas 48 Horas)
        for (let h = 48; h >= 1; h--) {
          const targetDate = new Date(now.getTime() - h * 60 * 60 * 1000);

          // Equação para flutuação harmônica (Onda Senoidal + Ruído)
          const wave = Math.sin(h * 0.4) * 0.12; // Oscilação de até 12%
          const noise = (Math.random() - 0.5) * 0.04; // Ruído de até 4%
          const calculatedPrice = Math.max(1,
            Math.round(baselinePrice * (1 + wave + noise))
          );

          // Gerando o ID do novo documento
          const docId = `${targetDate.getFullYear()}`+
            `-${pad(targetDate.getMonth() + 1)}`+
            `-${pad(targetDate.getDate())}`+
            `-${pad(targetDate.getHours())}`;

          // Obtendo a referência da coleção que receberá os dados
          const hourlyRef = db.collection("Startups")
            .doc(startupId)
            .collection("price_history_hourly")
            .doc(docId);

          // Adicionando a operação ao lote
          batch.set(hourlyRef, {
            averagePriceCents: calculatedPrice,
            timestamp: targetDate,
          }, {merge: true});

          // Incrementando o contador
          operationCount++;

          // Se 400 operações já foram adicionadas, executa elas e
          // reinicializa o contador
          if (operationCount >= 400) {
            await batch.commit();
            batch = db.batch();
            operationCount = 0;
          }
        }

        // ETAPA 2: Gerando dados diários (Últimos 365 Dias)
        for (let d = 365; d >= 1; d--) {
          // Obtendo a data de um ano atrás
          const targetDate = new Date(now.getTime() - d * 24 * 60 * 60 * 1000);

          // Uma oscilação mais larga e lenta para o gráfico anual
          const wave = Math.sin(d * 0.08) * 0.25; // Oscilação de até 25%
          const noise = (Math.random() - 0.5) * 0.08; // Ruído de até 8%
          const calculatedPrice = Math.max(1,
            Math.round(baselinePrice * (1 + wave + noise))
          );

          // Gerando o ID do novo documento
          const docId = [
            targetDate.getFullYear(),
            pad(targetDate.getMonth() + 1),
            pad(targetDate.getDate()),
            pad(targetDate.getHours()),
          ].join("-");

          // Obtendo a referência da coleção que receberá os dados
          const dailyRef = db.collection("Startups")
            .doc(startupId)
            .collection("price_history_daily")
            .doc(docId);

          // Adicionando a operação ao lote
          batch.set(dailyRef, {
            averagePriceCents: calculatedPrice,
            timestamp: targetDate,
          }, {merge: true});

          // Incrementando o contador
          operationCount++;

          // Se 400 operações já foram adicionadas, executa elas e
          // reinicializa o contador
          if (operationCount >= 400) {
            await batch.commit();
            batch = db.batch();
            operationCount = 0;
          }
        }
      }

      // Gravando o restante das operações remanescentes se houverem
      if (operationCount > 0) {
        await batch.commit();
      }

      // Retornando um indicativo de sucesso
      return {
        success: true,
        message: "Histórico populado com sucesso para"+
          "todas as startups conhecidas!",
      };
    } catch (error) {
      // Emitindo uma mensagem de erro
      logger.error("Erro ao rodar o seed de dados históricos:", error);
      // Lançando o erro que será tratado pelo Flutter
      throw new HttpsError(
        "internal",
        "Erro interno ao processar inserção em massa."
      );
    }
  }
);

/* Autor: Enzo Olivato Pazian */

import {onDocumentCreated} from "firebase-functions/v2/firestore";
import {OfferDocument, TradeDocument} from "../types";
import {logger} from "firebase-functions";
import {db} from "../../shared/firebase";
import {getUserBalanceForUpdate, getUserWalletStartupForUpdate} from
  "../../users/repositories/userRepository";
import {FieldValue} from "firebase-admin/firestore";

/**
 * Trigger responsável por identificar e realizar ordens de compra
 * e venda compatíveis entre si.
 */
export const matchOrderTrigger = onDocumentCreated(
  // Definindo a rota que o gatilho irá monitorar
  {document: "offers/{offerId}"},
  async (event) => {
    // ETAPA 1: Obtenção e verificação dos parâmetros obrigatórios

    // Obtendo os dados da nova ordem que acabou de
    // ser criada através do objeto de contexto
    const orderSnapshot = event.data;

    // Se não conseguir obter os dados, encerra a função
    if (!orderSnapshot) return;

    // Obtendo o ID da ordem criada que preencheu o
    // {offerId} que o trigger observa
    const incomingOfferId = event.params.offerId;

    // Obtendo os dados do documento criado
    const incomingOffer = orderSnapshot.data() as OfferDocument;

    // Garantindo que a ordem que será realizada está aberta
    // ou parcialmente realizada
    if (
      incomingOffer.status !== "open" &&
      incomingOffer.status !== "partial"
    ) return;

    // Exibindo no logger que o motor foi iniciado
    logger.info(`Motor ativado para a nova ordem [${incomingOfferId}]`+
      ` da startup ${incomingOffer.startupId}`);

    try {
      // ----------------------------------------------------
      // ETAPA 2: Busca por ofertas compatíveis (livro de ofertas)

      // Obtendo o tipo inverso da ordem para buscar seus
      // correspondentes (se a ordem atual é de compra,
      // serão buscadas ordens de venda)
      const counterType = incomingOffer.type === "buy" ? "sell" : "buy";

      // Definindo a query de busca para ordens correspondentes
      let counterOffersQuery = db
        .collection("offers")
        .where("startupId", "==", incomingOffer.startupId)
        .where("type", "==", counterType)
        .where("status", "in", ["open", "partial"]);

      // Definindo a regra de ordenação com base no tipo de ordem
      if (incomingOffer.type === "buy") {
        // Se a ordem criada for de compra, ordenaremos os resultados
        // das ordens de venda pelo menor preço disponível em relação
        // à oferta proposta
        counterOffersQuery = counterOffersQuery
          .where("priceCents", "<=", incomingOffer.priceCents)
          .orderBy("priceCents", "asc");
      } else {
        // Se a ordem criada for de venda, ordenaremos os resultados
        // das ordens de compra pelo maior preço disponível em relação
        // à oferta proposta
        counterOffersQuery = counterOffersQuery
          .where("priceCents", ">=", incomingOffer.priceCents)
          .orderBy("priceCents", "desc");
      }

      // Adicionando a ordenação por data à query de busca de ofertas
      // (prioridade de tempo: as mais antigas são priorizadas)
      const counterOffersSnapshot = await counterOffersQuery.orderBy(
        "createdAt", "asc"
      ).get();

      // Verificando se houve retorno de ordens compatíveis
      if (counterOffersSnapshot.empty) {
        logger.info("Nenhuma ordem compatível encontrada para cruzar"+
          `com [${incomingOfferId}].`);
        return;
      }

      // ----------------------------------------------------
      // ETAPA 3: Loop de correspondências

      // Obtendo a quantidade de tokens necessárias para a realização
      // da ordem (variável de controle para o loop de realização)
      let remainingQuantityToFill = incomingOffer.remainingQuantity;

      // Iniciando o loop de correspondência
      // Com base na lista de ordens compatíveis retornada, cada item
      // será percorrido para que elas se realizem, até que a ordem
      // criada tenha sido totalmente realizada ou todos os itens
      // tenham sido percorridos
      for (const counterDoc of counterOffersSnapshot.docs) {
        // Condição de parada: se a quantidade restante para a
        // realização for 0, significa que a ordem foi realizada
        if (remainingQuantityToFill <= 0) break;

        // Iniciando a transação atômica para as operações de
        // realização das ordens e armazenando seu resultado para
        // o tratamento de erros
        const result = await db.runTransaction(
          async (transaction) => {
            // Buscando novamente os dados da ordem original e sua
            // contraparte para garantir que não houve mudança entre
            // a obtenção dos dados e o início do loop

            // Obtendo a referência dos documentos das ordens para
            // fazer a busca na transação
            const freshIncomingRef = db.collection("offers")
              .doc(incomingOfferId);
            const freshCounterRef = db.collection("offers")
              .doc(counterDoc.id);

            // Realizando a busca dos dados das ordens através da
            // referência
            const freshIncomingSnap = await transaction.get(freshIncomingRef);
            const freshCounterSnap = await transaction.get(freshCounterRef);

            // Salvando os dados obtidos da busca formatado para o
            // tipo de um documento de ordem
            const freshIncoming = freshIncomingSnap.data() as OfferDocument;
            const freshCounter = freshCounterSnap.data() as OfferDocument;

            // Se a ordem principal já foi preenchida por outra
            // transação concorrente, retornamos uma ação para
            // dar break no loop externo
            if (freshIncoming.status === "completed") {
              return {action: "break"};
            }

            // Se ordem do livro já foi limpa, retornamos uma
            // ação para dar continue e pular para a próxima ordem
            // do livro.
            if (freshCounter.status === "completed") {
              return {action: "continue"};
            }

            // ====================================================
            // FASE 1: LEITURAS DA TRANSAÇÃO (READS)
            // Absolutamente nenhum comando de escrita (update/set)
            // pode rodar antes desse bloco terminar.
            // ====================================================

            // Obtendo o ID do usuário comprador e vendedor
            const buyerId = freshIncoming.type === "buy" ?
              freshIncoming.userId : freshCounter.userId;

            const sellerId = freshIncoming.type === "sell" ?
              freshIncoming.userId : freshCounter.userId;

            // Obtendo o ID da startup a partir dos dados da ordem
            const startupId = freshIncoming.startupId;

            // Obtendo o saldo do usuário comprador para atualização
            const buyerBalance = await getUserBalanceForUpdate(
              transaction, buyerId
            );

            // Obtendo o saldo do usuário vendedor para atualização
            const sellerBalance = await getUserBalanceForUpdate(
              transaction, sellerId
            );

            // Obtendo a wallet do usuário vendedor
            const sellerWallet = await getUserWalletStartupForUpdate(
              transaction, sellerId, startupId
            );

            // Se não conseguir obter os dados do saldo, emite um
            // erro e encerra a iteração
            if (!buyerBalance || !sellerBalance) {
              logger.error(
                "Não foi possível obter os dados de saldo dos usuários"
              );
              return;
            }

            // Verificando se os IDs das ordens compatíveis é igual
            // (evitando que um usuário realize a própria ordem)
            if (buyerId === sellerId) {
              logger.info(
                `Ignorando correspondência na ordem [${counterDoc.id}]. `+
                `O usuário '${buyerId}' não pode negociar consigo mesmo.`
              );
              // Retorna a ação "continue" para pular
              // esta ordem sem estourar o motor
              return {action: "continue"};
            }

            // Se não conseguir obter os dados da carteira, emite
            // um erro e encerra a iteração
            if (!sellerWallet) {
              logger.error(
                `Carteira do vendedor [${sellerId}] não encontrada`+
                ` para a startup ${startupId}`
              );
              return;
            }

            // ====================================================
            // FASE 2: CÁLCULOS LÓGICOS E REGRAS DE NEGÓCIO (MEMÓRIA)
            // Processamento local de dados estruturados
            // ====================================================

            // Definindo a quantidade que será negociada nessa
            // realização (o menor valor entre ambas as quantidades
            // restantes)
            const matchQuantity = Math.min(
              freshIncoming.remainingQuantity,
              freshCounter.remainingQuantity
            );

            // Definindo o valor total da negociação, que consiste
            // no preço unitário da negociação (que é o valor
            // ofertado pela ordem correspondente) multiplicado
            // pela quantidade negociada
            const totalCost = matchQuantity * freshCounter.priceCents;

            // Descobrindo quanto dinheiro o comprador "congelou"
            // originalmente para essa quantidade de tokens
            const buyerFrozenAmountForMatch = freshIncoming.type === "buy" ?
              // Se o comprador é o usuário dessa ordem, o valor é
              // a quantidade multiplicada pelo valor desta ordem
              matchQuantity * freshIncoming.priceCents :
              // Se o comprador é o usuário da ordem complementar,
              // o valor é o preço de negociação dessa ordem
              totalCost;

            // Definindo o troco (diferença entre o valor reservado
            // e o custo total da negociação)
            const changeCents = buyerFrozenAmountForMatch - totalCost;

            // Definindo os novos saldos do comprador
            // Definindo o novo saldo congelado (perde todo o valor
            // que havia reservado para essa negociação)
            const buyerFrozenBalanceAfterPurchase =
              buyerBalance.balanceFrozenCents - buyerFrozenAmountForMatch;

            // Definindo o novo saldo disponível (é ressarcido com o
            // valor calculado pelo troco)
            const buyerAvailableBalanceAfterPurchase =
              buyerBalance.balanceAvailableCents + changeCents;

            // Definindo o novo saldo do vendedor
            const sellerBalanceAfterPurchase =
              sellerBalance.balanceAvailableCents + totalCost;

            // Verificando se o vendedor vendeu os últimos tokens
            // que possuía de uma startup através da diferença entre
            // o total de tokens que ele possui e o total vendido
            const sellerTotalTokensBefore =
              sellerWallet.availableQuantity + sellerWallet.lockedQuantity;
            const sellerTotalTokensAfter =
              sellerTotalTokensBefore - matchQuantity;

            // Definindo as quantidades restantes de ambas as ordens
            const newIncomingQuantity =
              freshIncoming.remainingQuantity - matchQuantity;
            const newCounterQuantity =
              freshCounter.remainingQuantity - matchQuantity;

            // Definindo os novos status das ordens após suas
            // realizações
            const newIncomingStatus = newIncomingQuantity === 0 ?
              "completed" : "partial";
            const newCounterStatus = newCounterQuantity === 0 ?
              "completed" : "partial";

            // ====================================================
            // FASE 3: ESCRITAS DA TRANSAÇÃO (WRITES)
            // A partir deste ponto, nenhuma leitura (.get) é permitida!
            // ====================================================

            // Atualizando os saldos do usuário comprador com os
            // novos valores calculados
            transaction.update(buyerBalance.ref, {
              balanceFrozenCents: buyerFrozenBalanceAfterPurchase,
              balanceAvailableCents: buyerAvailableBalanceAfterPurchase,
            });

            // Atualizando o saldo do usuário vendedor com o valor
            // da transação
            transaction.update(sellerBalance.ref, {
              balanceAvailableCents: sellerBalanceAfterPurchase,
            });

            // Exibindo uma mensagem de sucesso da operação
            logger.info("Saldos dos usuários atualizados");

            // Criando uma referência para a wallet do comprador
            const buyerWalletRef = db
              .collection("users")
              .doc(buyerId)
              .collection("wallet")
              .doc(startupId);

            // Removendo os tokens negociados da carteira do vendedor
            transaction.update(sellerWallet.ref, {
              lockedQuantity: FieldValue.increment(-matchQuantity),
            });

            // Adicionando os tokens negociados à carteira do comprador
            transaction.set(
              buyerWalletRef,
              {availableQuantity: FieldValue.increment(matchQuantity)},
              {merge: true}
            );

            // Exibindo uma mensagem de sucesso da operação
            logger.info(
              "Troca de tokens realizada com sucesso. "+
              `${matchQuantity} tokens transferidos.`
            );

            // Criando uma referência para o novo registro (com id único)
            const tradeRef = db.collection("trades").doc();

            // Criando um objeto com os dados da transação
            const tradeDocument: TradeDocument = {
              buyerId,
              sellerId,
              startupId: startupId,
              quantity: matchQuantity,
              unitPriceCents: freshCounter.priceCents,
              totalPriceCents: totalCost,
              buyOrderId: freshIncoming.type === "buy" ?
                incomingOfferId :
                counterDoc.id,
              sellOrderId: freshIncoming.type === "sell" ?
                incomingOfferId :
                counterDoc.id,
              registeredAt: FieldValue.serverTimestamp(),
            };

            // Registrando a transação na blockchain fictícia
            transaction.set(tradeRef, tradeDocument);

            // Exibindo uma mensagem de sucesso da operação
            logger.info(
              `Registro da transação ${tradeRef.id}`+
              " realizado com sucesso."
            );

            // Obtendo a referência para os investidores da startup
            const buyerInvestorRef = db
              .collection("Startups")
              .doc(startupId)
              .collection("investors")
              .doc(buyerId);

            const sellerInvestorRef = db
              .collection("Startups")
              .doc(startupId)
              .collection("investors")
              .doc(sellerId);

            // Adicionando ou atualizando os dados do usuário comprador
            transaction.set(
              buyerInvestorRef,
              {
                userId: buyerId,
                // Incrementando a quantidade de tokens que ele
                // possui nesta startup
                quantity: FieldValue.increment(matchQuantity),
                updatedAt: FieldValue.serverTimestamp(),
              },
              {merge: true}
            );

            if (sellerTotalTokensAfter <= 0) {
              // Se o saldo final dele zerou, ele deixou de ser
              // investidor da startup, então deletamos seu
              // documento da coleção para que ele perca acesso
              // aos privilégios de investidor
              transaction.delete(sellerInvestorRef);

              // Emitindo a mensagem de sucesso da exclusão
              logger.info(
                `Usuário [${sellerId}] deixou de ser investidor da `+
                `startup ${startupId} (Posição zerada).`
              );

              // Se seu saldo zerou, removemos o documento da startup
              // de sua carteira

              // Obtendo a referência do documento da startup da carteira
              // do usuário
              const sellerWalletRef = db.collection("users")
                .doc(sellerId)
                .collection("wallet")
                .doc(startupId);

              // Excluindo o documento da carteira
              transaction.delete(sellerWalletRef);

              // Emitindo a mensagem de sucesso da exclusão
              logger.info(
                `Revisão de carteira: Documento do token [${startupId}] `+
                `removido da wallet do usuário [${sellerId}] por chegar a zero.`
              );
            } else {
              // Se ele ainda possui tokens restantes, ele continua
              // sendo investidor, então apenas atualizamos quantos
              // tokens ele possui
              transaction.set(
                sellerInvestorRef,
                {
                  quantity: FieldValue.increment(-matchQuantity),
                  updatedAt: FieldValue.serverTimestamp(),
                },
                {merge: true}
              );
            }

            // Exibindo uma mensagem de sucesso da operação
            logger.info("Quadro de investidores da startup"+
              " atualizado com sucesso.");

            // Atualizando a oferta criada (incoming)
            transaction.update(freshIncomingRef, {
              remainingQuantity: newIncomingQuantity,
              status: newIncomingStatus,
            });

            // Atualizando os dados da oferta correspondente (counter)
            transaction.update(freshCounterRef, {
              remainingQuantity: newCounterQuantity,
              status: newCounterStatus,
            });

            // Retornando o sucesso e a quantidade restante para
            // atualizar o loop de forma segura
            return {action: "success", newIncomingQuantity};
          }
        );

        // Controlando o loop externo com base no resultado da transação

        // Se houve um break, significa que a ordem principal foi
        // completada, então o motor deve ser encerrado
        if (result?.action === "break") {
          logger.info(`Ordem principal [${incomingOfferId}] já foi`+
            " totalmente preenchida em paralelo. Parando o motor.");
          break;
        }

        // Se houve um continue, significa que a ordem complementar
        // já foi concluída, então prossegue para o próximo item
        if (result?.action === "continue") {
          logger.info(`Ordem do livro [${counterDoc.id}] já`+
            "consumida. Pulando para a próxima.");
          continue;
        }

        // Por fim, se a transação foi um sucesso real, atualiza o
        // valor da variável de controle que armazena a quantidade
        // restante de tokens que precisam negociados nas ofertas
        remainingQuantityToFill = result?.newIncomingQuantity ?? 0;
      }
    } catch (error: unknown) {
      // Emitindo uma mensagem de erro
      logger.error(
        "Erro crítico no processamento do matchOrderTrigger para "+
        `a ordem [${incomingOfferId}]: `, error);
    }
  }
);

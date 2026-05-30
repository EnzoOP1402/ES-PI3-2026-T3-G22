/* Autor: Enzo Olivato Pazian */

import {HttpsError, onCall} from "firebase-functions/https";
import {requireAuthenticatedUser} from "../../shared/auth";
import {normalizeNumber, normalizeString} from "../../shared/validation";
import {db} from "../../shared/firebase";
import {getUserBalanceForUpdate} from "../../users/repositories/userRepository";
import {FieldValue} from "firebase-admin/firestore";
import {logger} from "firebase-functions";
import {getStartupByIdInTransaction} from
  "../../startups/repositories/startupRepository";
import {TradeDocument} from "../types";

/**
 * Firebase Function responsável pela realização de uma compra de
 * tokens a mercado.
 *
 * Ela recebe da requisição os dados do usuário autenticado, o
 * ID da startup para obter os dados relacionados à sua oferta
 * e a quantidade de tokens que o usuário deseja adquirir.
 *
 * A partir dos dados recebidos, ela faz as verificações das pré
 * condições de compra e, se elas forem bem sucedidas, realiza a
 * venda de tokens para o usuário.
 */
export const buyFromStartupMarket = onCall(async (request) => {
  // ETAPA 1: Verificação, obtenção e normalização de
  // parâmetros obrigatórios
  const user = requireAuthenticatedUser(request);

  // Obtendo e normalizando o UID da startup
  const startupId = normalizeString(request.data?.startupId);

  // Obtendo e normalizando a quantidade de tokens da ordem
  const quantity = normalizeNumber(request.data?.quantity);

  // Verificando se o id da startup está definido após
  // a normalização
  if (!startupId || !quantity) {
    throw new HttpsError(
      "invalid-argument",
      "Informe o startupId e a quantity.",
    );
  }

  // ETAPA 2: A lógica atômica da ordem de compra a mercado

  try {
    // Iniciando a transação atômica
    await db.runTransaction(async (transaction) => {
      // Obtendo os dados da startup a partir de seu ID para o
      // preenchimento correto das outras informações advindas
      // dela (nome, nome do token, preço atual e quantidade
      // disponível)
      const startup = await getStartupByIdInTransaction(transaction, startupId);

      // Se a startup buscada não está definida (não existe),
      // lança um erro HTTP
      if (!startup || !startup.data) {
        throw new HttpsError("not-found", "Startup nao encontrada.");
      }

      // Verificando se a startup possui a quantidade desejada
      // de tokens disponíveis para venda
      if (startup.data.purchaseAvailableTokens < quantity) {
        throw new HttpsError(
          "unavailable",
          "A startup não possui essa quantidade de tokens " +
            "disponíveis para venda.",
        );
      }

      // Obtendo o saldo do usuário
      const userBalance = await getUserBalanceForUpdate(transaction, user.uid);

      // Se o retorno for nulo, significa que o usuário não
      // foi encontrado no banco de dados, então lança um erro
      if (!userBalance) {
        throw new HttpsError("not-found", "Usuário não encontrado.");
      }

      // Definindo o custo total da ordem
      const totalCost = startup.data.currentTokenPriceCents * quantity;

      // Verificando se o usuário possui saldo disponível suficiente
      // para realizar a compra dos tokens
      // Se ele não tiver, lança um erro de pré condição inválida
      if (userBalance.balanceAvailableCents < totalCost) {
        throw new HttpsError(
          "failed-precondition",
          "O usuário não tem saldo suficiente para a abertura da ordem.",
        );
      }

      // Atualizando os dados de saldo do usuário através da
      // referência retornada pela função de obtenção
      // O valor total da ordem é removido do saldo disponível
      // do usuário
      transaction.update(userBalance.ref, {
        balanceAvailableCents: userBalance.balanceAvailableCents - totalCost,
      });

      // Depois das verificações de saldo, fazemos as operações
      // relacionadas à startup

      // Aumentando o capital aportado e diminuindo a quantidade
      // de tokens disponíveis da Startup
      transaction.update(startup.ref, {
        // Acrescenta o valor da compra
        capitalRaisedCents: FieldValue.increment(totalCost),
        // Subtrai a quantidade de tokens comprados da quantidade
        // disponível da startup
        purchaseAvailableTokens: FieldValue.increment(-quantity),
      });

      // Adicionando os tokens à wallet do usuário

      // Criando uma referência para a wallet (que está no caminho
      // users/{userId}/wallet/{startupId}/)
      const userWalletRef = db
        .collection("users")
        .doc(user.uid)
        .collection("wallet")
        .doc(startupId);

      // Atualizando a carteira do usuário com os novos dados da
      // compra realizada
      transaction.set(
        userWalletRef,
        {
          // Salvando os dados da startup referentes ao token
          startupId: startupId,
          startupName: startup.data.name,
          tokenName: startup.data.tokenName,
          // Incrementando/inicializando a quantidade disponível
          // com a quantidade adquirida
          availableQuantity: FieldValue.increment(quantity),
        },
        // Usando merge para garantir que, se o documento já
        // existir, ele não apague os dados anteriores
        {merge: true},
      );

      // Atualizando a subcoleção de investidores da startup

      // Obtendo a referência da subcoleção de investidores
      const buyerInvestorRef = db
        .collection("Startups")
        .doc(startupId)
        .collection("investors")
        .doc(user.uid);

      // Atualizando/registrando os dados de investidores da startup
      // após a compra
      transaction.set(
        buyerInvestorRef,
        {
          // Incrementa ou inicializa a quantidade de tokens comprados
          quantity: FieldValue.increment(quantity),
          updatedAt: FieldValue.serverTimestamp(),
        },
        // O merge garante a criação caso seja um novo investidor
        {merge: true},
      );

      // Registrando a transação na blockchain

      // Criando uma referência para o novo registro (com
      // um id recém criado)
      const tradeRef = db.collection("trades").doc();

      // Criando um objeto com os dados da transação
      const tradeDocument: TradeDocument = {
        buyerId: user.uid,
        startupId: startupId,
        quantity: quantity,
        unitPriceCents: startup.data.currentTokenPriceCents,
        totalPriceCents: totalCost,
        registeredAt: FieldValue.serverTimestamp(),
      };

      // Registrando a transação na blockchain
      transaction.set(tradeRef, tradeDocument);

      // Exibindo uma mensagem de sucesso da operação
      logger.info(
        `Registro da transação ${tradeRef.id}`+
        " realizado com sucesso."
      );
    });

    // Registrando no Logger da Function a mensagem de sucesso
    // após a conclusão da transação
    logger.info("Compra a mercado realizada com sucesso.");

    // Retornando um objeto com o status de sucesso, o id da
    // startup e o id do usuário
    return {
      data: {
        success: true,
        startupId,
        userId: user.uid,
      },
    };
  } catch (error: unknown) {
    // Se o erro capturado já for um HttpsError que nós mesmos
    // lançamos lá dentro, nós apenas repassamos ele para o
    // Flutter ler a mensagem amigável
    if (error instanceof HttpsError) {
      throw error;
    }

    // Se for qualquer outro erro inesperado (ex: banco fora do ar,
    // erro de timeout), nós registramos o erro real no Logger para
    // que possamos investigá-lo
    logger.error("Erro interno ao realizar compra a mercado: ", error);

    // Em seguida, retornamos um novo erro para que o Flutter
    // receba uma mensagem amigável
    throw new HttpsError(
      "internal",
      "Houve um erro interno ao realizar a compra a mercado. " +
        "Tente novamente mais tarde.",
    );
  }
});

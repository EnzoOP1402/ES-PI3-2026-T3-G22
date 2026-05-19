/* Autor: Enzo Olivato Pazian */

import {HttpsError, onCall} from "firebase-functions/https";
import {requireAuthenticatedUser} from "../../shared/auth";
import {normalizeNumber, normalizeString} from "../../shared/validation";
import {OfferDocument, OrderStatus, OrderType} from "../types";
import {getStartupById} from "../../startups";
import {FieldValue} from "firebase-admin/firestore";
import {logger} from "firebase-functions";
import {getUserBalanceForUpdate} from "../../users/repositories/userRepository";
import {createOrderOnTransaction} from "../repositories/exchangeRepository";
import {db} from "../../shared/firebase";

/**
 * Firebase Function responsável pela criação de uma ordem de compra.
 *
 * Ela recebe da requisição os dados do usuário autenticado,
 * o ID da startup, o preço em centavos da ordem e a quantidade
 * de tokens que será negociada.
 *
 * A partir dos dados recebidos, ela cria um objeto do tipo
 * OfferDocument e o insere no Firebase, retornando o id do
 * novo documento.
 */
export const createBuyOrder = onCall(
  async (request) => {
    // ETAPA 1: Verificação, obtenção e normalização de
    // parâmetros obrigatórios

    // Garantindo que o usuário está autenticado
    const user = requireAuthenticatedUser(request);

    // Obtendo e normalizando o UID da startup
    const startupId = normalizeString(request.data?.startupId);

    // Obtendo e normalizando o preço em centavos da ordem
    const priceCents = normalizeNumber(request.data?.priceCents);

    // Obtendo e normalizando a quantidade de tokens da ordem
    const quantity = normalizeNumber(request.data?.quantity);

    // Verificando se o id da startup, o preço em centavos e a
    // quantidade de tokens estão definidas após as normalizações
    if (!startupId || !priceCents || !quantity) {
      throw new HttpsError(
        "invalid-argument",
        "Informe o startupId, o priceCents e a quantity."
      );
    }

    // Verificando se o preço e a quantidade são maiores que 0
    if (quantity <= 0 || priceCents <= 0) {
      throw new HttpsError(
        "invalid-argument",
        "priceCents e quantity devem ser maiores que 0.",
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

      // ETAPA 2: A lógica atômica da criação de oferta

      // Pré declarando a variável local que armazenará o id da
      // ordem criada
      let offerId = "";

      // Iniciando a transação atômica
      await db.runTransaction(async (transaction) => {
        // Obtendo o saldo do usuário
        const userBalance = await getUserBalanceForUpdate(
          transaction,
          user.uid
        );

        // Se o retorno for nulo, significa que o usuário não
        // foi encontrado no banco de dados, então lança um erro
        if (!userBalance) {
          throw new HttpsError(
            "not-found",
            "Usuário não encontrado."
          );
        }

        // Definindo o custo total da ordem
        const totalCost = priceCents * quantity;

        // Verificando se o usuário possui saldo disponível suficiente
        // para realizar a compra dos tokens
        // Se ele não tiver, lança um erro de pré condição inválida
        if (userBalance.balanceAvailable < totalCost) {
          throw new HttpsError(
            "failed-precondition",
            "O usuário não tem saldo suficiente para a abertura da ordem."
          );
        }

        // Atualizando os dados de saldo do usuário através da
        // referência retornada pela função de obtenção
        // O valor total da ordem é removido do saldo disponível
        // do usuário e é movido para o saldo congelado
        transaction.update(userBalance.ref, {
          balanceAvailable: userBalance.balanceAvailable - totalCost,
          balanceFrozen: userBalance.balanceFrozen + totalCost,
        });

        // Depois das verificações e operações com o saldo,
        // criamos a ordem

        // Criando um objeto do tipo OfferDocument com os dados
        // obtidos para inseri-los no Firestore
        const order: OfferDocument = {
          userId: user.uid,
          startupId,
          startupName: startup.name,
          tokenName: startup.tokenName,
          type: "buy" as OrderType,
          priceCents,
          quantity,
          remainingQuantity: quantity,
          status: "open" as OrderStatus,
          createdAt: FieldValue.serverTimestamp(),
        };

        // Inserindo a ordem no Firestore através da função de
        // criação de ordens/ofertas
        offerId = await createOrderOnTransaction(transaction, order);
      });


      // Registrando no Logger da Function a mensagem de sucesso
      // após a conclusão da transação
      logger.info("Ordem de compra criada com sucesso.", {offerId});

      // Retornando um objeto com o status de sucesso e o id da oferta
      return {
        data: {
          success: true,
          id: offerId,
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
      logger.error("Erro interno ao criar ordem de compra: ", error);

      // Em seguida, retornamos um novo erro para que o Flutter
      // receba uma mensagem amigável
      throw new HttpsError(
        "internal",
        "Houve um erro interno ao criar sua ordem de compra. " +
        "Tente novamente mais tarde."
      );
    }
  }
);

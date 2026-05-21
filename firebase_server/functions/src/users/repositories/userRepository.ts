/* Autor: Enzo Olivato Pazian */

import {db} from "../../shared/firebase";
import {Transaction} from "firebase-admin/firestore";
import {UserDocument, WalletDocument} from "../types";

// Criando um acesso rápido à coleção de usuários
const userCollection = db.collection("users");

/**
 * Verifica se um CPF já foi cadastrado no banco de dados.
 *
 * @param {string} cpf - O CPF que está tentando ser cadastrado
 * @return {boolean} - Retorna se o CPF existe ou não.
 */
export async function cpfExists(cpf: string) {
  // Obtém a lista de documentos que possuem o CPF indicado
  const cpfCheck = await userCollection.where("cpf", "==", cpf).limit(1).get();

  // Se a lista estiver vazia, retorna false (não existe),
  // se não, retorna true (existe)
  return !cpfCheck.empty;
}

/**
 * Obtém os dados de saldo um usuário dentro de uma
 * transação ativa.
 *
 * É usada na criação de ordens de compra, sendo
 * uma parte essencial das verificações de
 * viabilidade da abertura de ordens.
 *
 * @param {Transaction} transaction -
 * Representa a transação em andamento;
 * @param {string} userId - O UID do usuário a ter os
 * dados de saldo buscados
 */
export async function getUserBalanceForUpdate(
  transaction: Transaction,
  userId: string,
) {
  // Criando uma referência ao documento do usuário
  const userRef = userCollection.doc(userId);

  // Obtemos o objeto com os dados do documento do
  // usuário através da operação de busca atômica
  // gerada pela transaction
  const userDoc = await transaction.get(userRef);

  // Se o documento não trouxer dados de um usuário
  // existente, retorna null (que será interceptado
  // pela transação principal)
  if (!userDoc.exists) {
    return null;
  }

  // Extraindo os dados do documento
  const data = userDoc.data() as UserDocument;

  // Retornando os dados obtidos
  return {
    // Retornando a referência para que ela possa ser
    // acessada pelo próximo update
    ref: userRef,
    // Retornando o saldo disponível
    balanceAvailableCents: data?.balanceAvailableCents || 0,
    // Retornando o saldo congelado
    balanceFrozenCents: data?.balanceFrozenCents || 0,
  };
}

/**
 * Obtém os dados da carteira de um usuário dentro de uma
 * transação ativa.
 *
 * É usada na criação de ordens de venda,
 * sendo uma parte essencial das verificações de
 * viabilidade da abertura de ordens.
 *
 * @param {Transaction} transaction -
 * Representa a transação em andamento;
 * @param {string} userId - O UID do usuário a ter os
 * dados da carteira buscados
 * @param {string} startupId - O UID da startup da qual
 * o usuário possui tokens
 */
export async function getUserWalletStartupForUpdate(
  transaction: Transaction,
  userId: string,
  startupId: string,
) {
  if (!userId || !startupId) {
    throw new Error(
      "userId e startupId são obrigatórios para buscar a carteira.",
    );
  }
  // Criando uma referência ao documento da carteira do usuário
  // referentes à startup indicada
  const walletRef = userCollection
    .doc(userId)
    .collection("wallet")
    .doc(startupId);

  // Obtemos o objeto com os dados do documento do
  // usuário através da operação de busca atômica
  // gerada pela transaction
  const walletDoc = await transaction.get(walletRef);

  // Se o documento não trouxer dados de uma startup
  // existente na carteira, retorna null (que será
  // interceptado pela transação principal)
  if (!walletDoc.exists) {
    return null;
  }

  // Extraindo os dados do documento
  const data = walletDoc.data() as WalletDocument;

  // Retornando os dados obtidos
  return {
    // Retornando a referência para que ela possa ser
    // acessada pelo próximo update
    ref: walletRef,
    // Retornando os dados da carteira do usuário
    // referentes à startup indicada
    availableQuantity: data?.availableQuantity,
    lockedQuantity: data?.lockedQuantity,
  };
}

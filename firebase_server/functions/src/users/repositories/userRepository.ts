/* Autor: Enzo Olivato Pazian */

import admin from "firebase-admin";
import {db} from "../../shared/firebase";

// Criando um acesso rápido à coleção de usuários
const userCollection = db.collection("users");

/**
 * Verifica se um CPF já foi cadastrado no banco de dados.
 *
 * @param {string} cpf - O CPF que está tentando ser cadastrado
 * @return {boolean} - Retorna se o CPF existe ou não.
 */
export async function cpfExists(
  cpf: string
) {
  // Obtém a lista de documentos que possuem o CPF indicado
  const cpfCheck = await userCollection
    .where("cpf", "==", cpf)
    .limit(1)
    .get();

  // Se a lista estiver vazia, retorna false (não existe),
  // se não, retorna true (existe)
  return !cpfCheck.empty;
}

/**
 * Obtém os dados de saldo um usuário dentro de uma
 * transação ativa.
 *
 * É usada na criação de ordens de compra e venda,
 * sendo uma parte essencial das verificações de
 * viabilidade da abertura de ordens.
 *
 * @param {admin.firestore.Transaction} transaction -
 * Representa a transação em andamento;
 * @param {string} userId - O UID do usuário a ter os
 * dados de saldo buscados
 */
export async function getUserBalanceForUpdate(
  transaction: admin.firestore.Transaction,
  userId: string
) {
  // Obtemos o objeto com os dados do documento do
  // usuário através da operação de busca atômica
  // gerada pela transaction
  const userDoc = await transaction.get(userCollection.doc(userId));

  // Se o documento não trouxer dados de um usuário
  // existente, retorna null (que será interceptado
  // pela transação principal)
  if (!userDoc.exists) {
    return null;
  }

  // Extraindo os dados do documento
  const data = userDoc.data();

  // Retornando os dados obtidos
  return {
    // Retornando a referência para que ela possa ser
    // acessada pelo próximo update
    ref: userCollection.doc(userId),
    // Retornando o saldo disponível
    balanceAvailable: data?.balanceAvailable || 0,
    // Retornando o saldo congelado
    balanceFrozen: data?.balanceFrozen || 0,
  };
}

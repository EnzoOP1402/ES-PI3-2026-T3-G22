/* Autor: Enzo Olivato Pazian */

import admin from "firebase-admin";
import {db} from "../../shared/firebase";
import {OfferDocument} from "../types";

const offersCollection = db.collection("offers");

/**
 * Função responsável pela criação de uma ordem de compra ou venda.
 *
 * @param {admin.firestore.Transaction} transaction -
 * Representa a transação em andamento;
 * @param {OfferDocument} offer - Oferta a ser criada.
 * @return {string} offerRef.id - Retorna o id da oferta recém criada.
 */
export async function createOrderOnTransaction(
  transaction: admin.firestore.Transaction,
  offer: OfferDocument
): Promise<string> {
  // Obtendo uma referência à coleção com o ID gerado automaticamente,
  // para que ela possa ser acessada pelo método da transaction
  const newOfferRef = offersCollection.doc();

  // Usa o objeto transaction para adicionar os dados ao documento
  // referenciado
  transaction.set(newOfferRef, offer);

  // Retorna o id do novo documento criado
  return newOfferRef.id;
}

/**
 * Função responsável por obter os dados de uma ordem através de
 * seu ID.
 *
 * @param {string} orderId - O ID da ordem a ser buscada
 * @return {OfferDocument} - Um objeto contendo os dados da ordem
 */
export async function getOrderById(
  orderId: string
): Promise<OfferDocument | undefined> {
  // Obtendo o documento referente à ordem
  const orderSnapshot = await offersCollection.doc(orderId).get();

  // Se ele estiver vazio, retorna undefined
  if (!orderSnapshot.exists) {
    return undefined;
  }

  // Senão, retorna o objeto com os dados da ordem
  return orderSnapshot.data() as OfferDocument;
}

/**
 * Função responsável por obter os dados de uma ordem através de
 * seu ID dentro de uma Transaction.
 *
 * @param {admin.firestore.Transaction} transaction -
 * Representa a transação em andamento;
 * @param {string} orderId - O ID da ordem a ser buscada
 * @return {OfferDocument} - Um objeto contendo os dados da ordem
 */
export async function getOrderByIdInTransaction(
  transaction: admin.firestore.Transaction,
  orderId: string
) {
  // Criando uma referência ao documento da ordem
  const orderRef = offersCollection.doc(orderId);

  // Obtendo o objeto com os dados da ordem através da
  // operação de busca atômica gerada pela Transaction
  const orderDoc = await transaction.get(orderRef);

  // Se o documento não existir, retorna null (que será
  // interceptado pela transação principal)
  if (!orderDoc) {
    return null;
  }

  // Extraindo os dados do documento
  const data = orderDoc.data() as OfferDocument;

  // Retornando os dados obtidos
  return {
    // Retornando a referência para que ela possa ser
    // acessada pelo próximo update
    ref: orderRef,
    // Retornando os dados do documento
    data: data as OfferDocument,
  };
}

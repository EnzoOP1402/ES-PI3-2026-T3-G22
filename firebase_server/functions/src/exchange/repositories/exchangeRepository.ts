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

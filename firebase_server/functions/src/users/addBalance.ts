/* Autor: Gabriela Sichiroli Ferrari */

import { onCall, HttpsError } from "firebase-functions/v2/https";
import { db } from "../startups/shared/firebase";
import { FieldValue } from "firebase-admin/firestore";
import { requireAuthenticatedUser } from "../startups/shared/auth";

/**
 * 
 */
export const addBalance = onCall(async (request) => {
  try {
    // Verifica autenticação
    const user = requireAuthenticatedUser(request);
    const uid = user.uid;
    const amount = Number(request.data.amount);
    
    if (!Number.isInteger(amount) || amount <= 0) {
      throw new HttpsError(
        "invalid-argument",
        "Valor inválido."
      );
    }

    const userRef = db.collection("users").doc(uid);

    await userRef.update({
      balanceAvailableCents: FieldValue.increment(amount),
    });

    return {
      success: true,
      message: "Saldo adicionado com sucesso.",
    };
  } catch (error) {
    console.error(error);

    throw new HttpsError(
      "internal",
      "Erro ao adicionar saldo."
    );
  }
});
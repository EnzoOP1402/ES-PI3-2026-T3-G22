/* Autor: coloque seu nome aqui */

import {onCall, HttpsError} from "firebase-functions/v2/https";
import {getFirestore, Timestamp} from "firebase-admin/firestore";

const db = getFirestore();

/**
 * Normaliza dados do Firestore para retorno seguro ao Flutter.
 *
 * @param {unknown} data dado recebido do Firestore
 * @return {unknown} dado normalizado
 */
function normalizeFirestoreData(data: unknown): unknown {
  if (data === null || data === undefined) {
    return data;
  }

  if (data instanceof Timestamp) {
    return data.toDate().toISOString();
  }

  if (Array.isArray(data)) {
    return data.map((item) => normalizeFirestoreData(item));
  }

  if (typeof data === "object") {
    const normalized: Record<string, unknown> = {};

    for (const [key, value] of Object.entries(data)) {
      normalized[key] = normalizeFirestoreData(value);
    }

    return normalized;
  }

  return data;
}

export const getStartupDetails = onCall(async (request) => {
  const startupId = request.data?.startupId;

  if (!startupId || typeof startupId !== "string") {
    throw new HttpsError(
      "invalid-argument",
      "O campo startupId é obrigatório."
    );
  }

  try {
    const startupRef = db.collection("Startups").doc(startupId);
    const startupSnapshot = await startupRef.get();

    if (!startupSnapshot.exists) {
      throw new HttpsError(
        "not-found",
        "Startup não encontrada."
      );
    }

    const startupData = startupSnapshot.data() ?? {};

    return normalizeFirestoreData({
      id: startupSnapshot.id,
      ...startupData,
    });
  } catch (error) {
    console.error("Erro em getStartupDetails:", error);

    if (error instanceof HttpsError) {
      throw error;
    }

    throw new HttpsError(
      "internal",
      "Erro interno ao buscar detalhes da startup."
    );
  }
});

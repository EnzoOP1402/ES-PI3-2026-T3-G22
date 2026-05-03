import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const db = admin.firestore();

export const getStartupDetails = functions.https.onCall(
  async (request) => {
    const startupId = request.data?.id;

    if (!startupId) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Informe o id da startup"
      );
    }

    const doc = await db.collection("Startups").doc(startupId).get();

    if (!doc.exists) {
      throw new functions.https.HttpsError(
        "not-found",
        "Startup não encontrada"
      );
    }

    const data = doc.data();

    return {
      id: doc.id,
      ...data,
    };
  }
);
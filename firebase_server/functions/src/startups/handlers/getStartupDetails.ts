import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const db = admin.firestore();

// Função para buscar os detalhes de uma startup específica
export const getStartupDetails = functions.https.onCall(async (request: functions.https.CallableRequest) => {
  const startupId = request.data.startupId; // Acessando o startupId de request.data

  // Verifica se o startupId foi fornecido
  if (!startupId) {
    throw new functions.https.HttpsError('invalid-argument', 'Startup ID é obrigatório.');
  }

  try {
    const startupDoc = await db.collection("Startups").doc(startupId).get();

    // Se o documento não existir, retorna erro
    if (!startupDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Startup não encontrada.');
    }

    // Retorna os dados da startup
    return { id: startupDoc.id, ...startupDoc.data() };
  } catch (error) {
    // Trata o erro corretamente
    if (error instanceof Error) {
      throw new functions.https.HttpsError('internal', 'Erro ao buscar dados da startup: ' + error.message);
    } else {
      throw new functions.https.HttpsError('internal', 'Erro desconhecido ao buscar dados da startup.');
    }
  }
});
import * as admin from "firebase-admin";
import {setGlobalOptions} from "firebase-functions";

admin.initializeApp();

setGlobalOptions({maxInstances: 10});

export * from "./startups";

export const criarDepositoTED = functions.https.onCall(
  async (data, context) => {
    // Usuário precisa estar autenticado
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Usuário não autenticado."
      );
    }

    const uid = context.auth.uid;

    const valor = Number(data.valor);
    const comprovanteUrl = data.comprovanteUrl || null;
    const metodo = "TED";

    // Validação
    if (!valor || valor <= 0) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Valor inválido para depósito."
      );
    }

    try {
      // Cria documento do depósito
      const depositoRef = db.collection("depositos_ted").doc();

      await depositoRef.set({
        depositoId: depositoRef.id,
        userId: uid,
        valor,
        comprovanteUrl,
        metodo,
        status: "pendente", // pendente | aprovado | rejeitado
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Histórico opcional por usuário
      await db
        .collection("users")
        .doc(uid)
        .collection("historico_depositos")
        .doc(depositoRef.id)
        .set({
          depositoId: depositoRef.id,
          valor,
          metodo,
          status: "pendente",
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });

      return {
        success: true,
        depositoId: depositoRef.id,
        message: "Depósito TED registrado com sucesso.",
      };
    } catch (error) {
      console.error("Erro ao criar depósito TED:", error);

      throw new functions.https.HttpsError(
        "internal",
        "Erro interno ao processar depósito."
      );
    }
  }
);
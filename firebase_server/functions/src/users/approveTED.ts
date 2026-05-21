import {HttpsError, onCall} from "firebase-functions/https";

export const criarDepositoTED = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError(
      "unauthenticated",
      "Usuário não autenticado."
    );
  }

  const uid = request.auth.uid;

  const valor = Number(request.data.valor);

  const comprovanteUrl =
    typeof request.data.comprovanteUrl === "string"
      ? request.data.comprovanteUrl
      : null;

  if (isNaN(valor) || valor <= 0) {
    throw new HttpsError(
      "invalid-argument",
      "Valor inválido para depósito."
    );
  }

  const depositoRef = db.collection("depositos_ted").doc();

  await depositoRef.set({
    depositoId: depositoRef.id,
    userId: uid,
    valor,
    comprovanteUrl,
    metodo: "TED",
    status: "pendente",
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  await db
    .collection("users")
    .doc(uid)
    .collection("historico_depositos")
    .doc(depositoRef.id)
    .set({
      depositoId: depositoRef.id,
      valor,
      metodo: "TED",
      status: "pendente",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

  return {
    success: true,
    depositoId: depositoRef.id,
    message: "Depósito TED registrado com sucesso.",
  };
});

export const aprovarDepositoTED = onCall(async (request) => {
  const depositoId = request.data.depositoId;

  if (!depositoId) {
    throw new HttpsError(
      "invalid-argument",
      "ID do depósito é obrigatório."
    );
  }

  const depositoRef = db.collection("depositos_ted").doc(depositoId);
  const depositoSnap = await depositoRef.get();

  if (!depositoSnap.exists) {
    throw new HttpsError(
      "not-found",
      "Depósito não encontrado."
    );
  }

  const deposito = depositoSnap.data();

  if (deposito?.status !== "pendente") {
    throw new HttpsError(
      "failed-precondition",
      "Depósito já processado."
    );
  }

  const userRef = db.collection("users").doc(deposito.userId);

  await db.runTransaction(async (transaction) => {
    const userSnap = await transaction.get(userRef);

    if (!userSnap.exists) {
      throw new HttpsError(
        "not-found",
        "Usuário não encontrado."
      );
    }

    const saldoAtual = Number(userSnap.data()?.balance || 0);

    transaction.update(userRef, {
      balance: saldoAtual + deposito.valor,
    });

    transaction.update(depositoRef, {
      status: "aprovado",
      approvedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    transaction.update(
      userRef.collection("historico_depositos").doc(depositoId),
      {
        status: "aprovado",
      }
    );
  });

  return {
    success: true,
    message: "Depósito aprovado e saldo atualizado.",
  };
});
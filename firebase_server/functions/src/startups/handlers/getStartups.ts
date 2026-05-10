import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const db = admin.firestore();

export const getStartups = functions.https.onCall(async () => {
  const snapshot = await db.collection("Startups").get();

  const startups = snapshot.docs.map((doc) => ({
    id: doc.id,
    ...doc.data(),
  }));

  return startups;
});

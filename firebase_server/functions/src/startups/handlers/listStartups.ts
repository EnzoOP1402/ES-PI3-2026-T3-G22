import {onCall} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

export const listStartups = onCall(async () => {
  const snapshot = await admin.firestore()
    .collection("startups")
    .get();

  const startups = snapshot.docs.map((doc) => ({
    id: doc.id,
    ...doc.data(),
  }));

  return {
    data: startups,
  };
});

/* eslint-disable linebreak-style */
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const db = admin.firestore();

export const getStartupsTest = functions.https.onRequest(async (req, res) => {
  try {
    const snapshot = await db.collection("Startups").get();

    const startups = snapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    }));

    res.status(200).json(startups);
  } catch (error) {
    res.status(500).send(error);
  }
});

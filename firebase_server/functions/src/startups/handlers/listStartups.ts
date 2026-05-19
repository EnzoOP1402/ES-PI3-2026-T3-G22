import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import cors from "cors";

const corsHandler = cors({ origin: true });

const db = admin.firestore();
const collectionStartups = db.collection("startups");

export const listStartups = functions.https.onRequest((req, res) => {
    corsHandler(req, res, async () => {
        try {
            const snapshot = await collectionStartups.get();

            const startups = snapshot.docs.map(doc => ({
                id: doc.id,
                ...doc.data(),
            }));

            res.status(200).json(startups);
        } catch (error) {
            console.error("Erro ao listar startups:", error);
            res.status(500).send("Erro ao listar startups");
        }
    });
});
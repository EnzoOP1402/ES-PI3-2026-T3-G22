import * as admin from "firebase-admin";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { setGlobalOptions } from "firebase-functions/v2";

admin.initializeApp();
const db = admin.firestore();

setGlobalOptions({
  maxInstances: 10,
  region: "southamerica-east1",
});

export * from "./startups";
export * from "./users";
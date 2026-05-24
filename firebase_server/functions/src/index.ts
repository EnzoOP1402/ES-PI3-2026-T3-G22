/* Autor: Enzo Olivato Pazian */

import * as admin from "firebase-admin";
import {setGlobalOptions} from "firebase-functions";

admin.initializeApp();

setGlobalOptions({
  maxInstances: 10,
  region: "southamerica-east1",
});

export * from "./users";

export * from "./startups";

export * from "./exchange";

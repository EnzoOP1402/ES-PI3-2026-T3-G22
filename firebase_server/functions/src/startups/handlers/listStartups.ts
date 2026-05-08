import {HttpsError, onCall} from "firebase-functions/https";
import {allowedStages} from "../shared/constants";
import {requireAuthenticatedUser} from "../shared/auth";
import {normalizeString} from "../shared/validation";
import {listStartupItems} from "../repositories/startupRepository";
import {StartupStage} from "../types";

export const listStartups = onCall(async (request) => {
  requireAuthenticatedUser(request);

  const stage = normalizeString(request.data?.state);
  const search = normalizeString(
    request.data?.search
  )?.toLocaleLowerCase("pt-BR");

  if (stage && !allowedStages.includes(stage as StartupStage)) {
    throw new HttpsError(
      "invalid-argument",
      "Filtro inválido. Use: nova, em_operacao ou em_expansao."
    );
  }

  const allStartups = await listStartupItems();

  console.log("STARTUPS ENCONTRADAS NO FIRESTORE:", allStartups.length);

  const startups = allStartups
    .filter((startup) => {
      if (!stage) {
        return true;
      }

      return startup.stage === stage;
    })
    .filter((startup) => {
      if (!search) {
        return true;
      }

      const searchable = [
        startup.name,
        startup.shortDescription,
        startup.stage,
        ...(startup.tags ?? []),
      ].join(" ").toLocaleLowerCase("pt-BR");

      return searchable.includes(search);
    })
    .sort((left, right) => {
      return left.name.localeCompare(right.name, "pt-BR");
    });

  return {
    count: startups.length,
    filters: {
      availableStages: allowedStages,
      stage: stage ?? null,
      search: search ?? null,
    },
    data: startups,
  };
});

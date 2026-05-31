/* eslint-disable require-jsdoc */
/* Autor: Mateus Dias */

import {FieldValue, Transaction} from "firebase-admin/firestore";

import {
  StartupDocument,
  StartupListItem,
  StartupQuestionDocument,
} from "../types";
import {db} from "../../shared/firebase";

const startupsCollection = db.collection("Startups");

const demoStartups: Array<StartupDocument & {id: string}> = [
  {
    id: "biochip-campus",
    name: "BioChip Campus",
    stage: "nova",
    shortDescription: "Sensores portateis para analises laboratoriais " +
 "didaticas.",
    description: "A BioChip Campus simula kits de diagnostico rapido para " +
 "laboratorios universitarios, conectando sensores de baixo custo a um " +
 "aplicativo de acompanhamento.",
    executiveSummary: "Startup em fase de ideacao com foco em prototipagem " +
 "de sensores educacionais e validacao com cursos da area de saude.",
    capitalRaisedCents: 1850000,
    totalTokensIssued: 100000,
    currentTokenPriceCents: 125,
    founders: [
      {
        name: "Ana Ribeiro",
        role: "CEO",
        equityPercent: 48,
        bio: "Responsavel por estrategia e parcerias academicas.",
      },
      {
        name: "Lucas Moreira",
        role: "CTO",
        equityPercent: 37,
        bio: "Responsavel por hardware e integracao mobile.",
      },
      {name: "Mescla Labs", role: "Reserva estrategica", equityPercent: 15},
    ],
    externalMembers: [
      {
        name: "Dra. Helena Costa",
        role: "Mentora",
        organization: "PUC-Campinas",
      },
    ],
    demoVideos: ["https://example.com/videos/biochip-campus-demo"],
    pitchDeckUrl: "https://example.com/decks/biochip-campus.pdf",
    coverImageUrl: "https://images.unsplash.com/photo-" +
 "1581093458791-9d15482442f6",
    tags: ["healthtech", "iot", "educacao"],
    tokenName: "BCTK",
    purchaseAvailableTokens: 100000,
  },
  {
    id: "rota-verde",
    name: "Rota Verde",
    stage: "em_operacao",
    shortDescription: "Otimizacao de rotas sustentaveis para entregas urbanas.",
    description: "A Rota Verde usa dados de distancia, emissao estimada e " +
 "ocupacao de entregadores para sugerir rotas urbanas com menor impacto " +
 "ambiental.",
    executiveSummary: "Startup em operacao piloto com pequenos comercios " +
 "locais e validacao de indicadores de economia de combustivel.",
    capitalRaisedCents: 7400000,
    totalTokensIssued: 250000,
    currentTokenPriceCents: 310,
    founders: [
      {name: "Beatriz Santos", role: "CEO", equityPercent: 42},
      {name: "Rafael Almeida", role: "COO", equityPercent: 28},
      {name: "Carla Nogueira", role: "CTO", equityPercent: 20},
      {name: "Reserva de incentivos", role: "Pool", equityPercent: 10},
    ],
    externalMembers: [
      {name: "Marcos Lima", role: "Conselheiro", organization: "Mescla"},
      {
        name: "Patricia Gomes",
        role: "Mentora",
        organization: "Rede de Logistica",
      },
    ],
    demoVideos: ["https://example.com/videos/rota-verde-demo"],
    pitchDeckUrl: "https://example.com/decks/rota-verde.pdf",
    coverImageUrl: "https://images.unsplash.com/photo-" +
 "1500530855697-b586d89ba3ee",
    tags: ["logtech", "sustentabilidade", "mobilidade"],
    tokenName: "RVTK",
    purchaseAvailableTokens: 250000,
  },
  {
    id: "mentorai",
    name: "MentorAI",
    stage: "em_expansao",
    shortDescription: "Triagem inteligente para programas de mentoria " +
 "universitarios.",
    description: "A MentorAI organiza perfis de estudantes e mentores para " +
 "recomendar encontros com base em objetivos, disponibilidade e " +
 "historico de acompanhamento.",
    executiveSummary: "Startup em expansao com uso simulado em programas de " +
 "pre-aceleracao e potencial de integracao a plataformas educacionais.",
    capitalRaisedCents: 12350000,
    totalTokensIssued: 500000,
    currentTokenPriceCents: 525,
    founders: [
      {name: "Diego Martins", role: "CEO", equityPercent: 36},
      {name: "Juliana Vieira", role: "CPO", equityPercent: 24},
      {name: "Felipe Andrade", role: "CTO", equityPercent: 25},
      {
        name: "Investidores simulados",
        role: "Participacao externa",
        equityPercent: 15,
      },
    ],
    externalMembers: [
      {
        name: "Sofia Pereira",
        role: "Conselheira",
        organization: "Ecossistema Mescla",
      },
    ],
    demoVideos: ["https://example.com/videos/mentorai-demo"],
    pitchDeckUrl: "https://example.com/decks/mentorai.pdf",
    coverImageUrl: "https://images.unsplash.com/photo-1552664730-d307ca884978",
    tags: ["edtech", "ia", "mentoria"],
    tokenName: "MAITK",
    purchaseAvailableTokens: 500000,
  },
];

function toListItem(id: string, startup: StartupDocument): StartupListItem {
  return {
    id,
    name: startup.name,
    stage: startup.stage,
    shortDescription: startup.shortDescription,
    capitalRaisedCents: startup.capitalRaisedCents,
    totalTokensIssued: startup.totalTokensIssued,
    currentTokenPriceCents: startup.currentTokenPriceCents,
    coverImageUrl: startup.coverImageUrl,
    tags: startup.tags,
  };
}

export async function listStartupItems(): Promise<StartupListItem[]> {
  const snapshot = await startupsCollection.limit(100).get();

  return snapshot.docs.map((doc) =>
    toListItem(doc.id, doc.data() as StartupDocument)
  );
}

export async function getStartupById(
  startupId: string
): Promise<StartupDocument | undefined> {
  const startupSnapshot = await startupsCollection.doc(startupId).get();

  if (!startupSnapshot.exists) {
    return undefined;
  }

  return startupSnapshot.data() as StartupDocument;
}

export async function userIsInvestor(
  startupId: string,
  uid: string
): Promise<boolean> {
  const investorSnapshot = await startupsCollection
    .doc(startupId)
    .collection("investors")
    .doc(uid)
    .get();

  return investorSnapshot.exists;
}

// Função editada por: Enzo Olivato Pazian
// Melhoria adicionada: busca na coleção de usuários para a obtenção
// de dados relacionados a ele para exibi-los nas perguntas
export async function listPublicQuestions(startupId: string) {
  const questionsSnapshot = await startupsCollection
    .doc(startupId)
    .collection("questions")
    .where("visibility", "==", "publica")
    .limit(50)
    .get();

  // Usamos Promise.all para processar as buscas de usuário de forma assíncrona
  const questionsWithUsers = await Promise.all(
    questionsSnapshot.docs.map(async (doc) => {
      const data = doc.data();
      const authorId = data.authorUid;

      let authorName = "Usuário";
      let authorPhotoUrl = null;

      if (authorId) {
        try {
          // Busca o documento do usuário na coleção "users" do Firestore
          const userDoc = await db.collection("users").doc(authorId).get();
          if (userDoc.exists) {
            const userData = userDoc.data();
            authorName = userData?.fullName || "Usuário";
            authorPhotoUrl = userData?.profilePicture || null;
          }
        } catch (error) {
          console.error(`Erro ao buscar usuário ${authorId}:`, error);
        }
      }

      return {
        id: doc.id,
        text: data.text,
        answer: data.answer ?? null,
        answeredAt: data.answeredAt?.toDate?.()?.toISOString?.() ?? null,
        createdAt: data.createdAt?.toDate?.()?.toISOString?.() ?? null,
        authorName,
        authorPhotoUrl,
      };
    })
  );

  return questionsWithUsers.sort((left, right) =>
    String(right.createdAt ?? "").localeCompare(String(left.createdAt ?? ""))
  );
}

// Função criada por: Enzo Olivato Pazian
/**
 * Função para a listagem das perguntas privadas de uma startup
 * feitas pelo usuário logado.
 * @param {string} startupId - O id da startup que possui as perguntas
 * @param {string} userId - O id do usuário que fez as perguntas
 * @return {[]} - A lista de perguntas com os dados dos usuários
 */
export async function listPrivateQuestions(startupId: string, userId: string) {
  const questionsSnapshot = await startupsCollection
    .doc(startupId)
    .collection("questions")
    .where("visibility", "==", "privada")
    .where("authorUid", "==", userId)
    .limit(50)
    .get();

  // Obtendo os dados do usuário
  try {
    // Busca o documento do usuário na coleção "users" do Firestore
    const userDoc = await db.collection("users").doc(userId).get();
    if (userDoc.exists) {
      const userData = userDoc.data();
      const authorName = userData?.fullName || "Usuário";
      const authorPhotoUrl = userData?.profilePicture || null;

      const questionsWithUsers = questionsSnapshot.docs.map(
        (doc) => {
          const data = doc.data();

          return {
            id: doc.id as string,
            text: data.text as string,
            answer: data.answer as string ?? null,
            answeredAt: data.answeredAt?.toDate?.()?.toISOString?.() ?? null,
            createdAt: data.createdAt?.toDate?.()?.toISOString?.() ?? null,
            authorName: authorName as string,
            authorPhotoUrl: authorPhotoUrl as string ?? null,
          };
        }
      );

      return questionsWithUsers.sort((left, right) =>
        String(right.createdAt ?? "")
          .localeCompare(String(left.createdAt ?? ""))
      );
    }
    return [];
  } catch (error) {
    console.error(`Erro ao buscar usuário ${userId}:`, error);
    return [];
  }
}

export async function createQuestion(
  startupId: string,
  question: StartupQuestionDocument
): Promise<string> {
  const questionRef = await startupsCollection
    .doc(startupId)
    .collection("questions")
    .add(question);

  return questionRef.id;
}

export async function seedDemoStartups(): Promise<string[]> {
  const batch = db.batch();

  for (const startup of demoStartups) {
    const {id, ...data} = startup;
    const startupRef = startupsCollection.doc(id);

    batch.set(startupRef, {
      ...data,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    }, {merge: true});
  }

  await batch.commit();

  return demoStartups.map((startup) => startup.id);
}

// Função criada por: Enzo Olivato Pazian
/**
 * Obtém os dados de saldo um usuário dentro de uma
 * transação ativa.
 *
 * É usada na criação de ordens de compra e venda,
 * sendo uma parte essencial das verificações de
 * viabilidade da abertura de ordens.
 *
 * @param {Transaction} transaction -
 * Representa a transação em andamento;
 * @param {string} startupId - O startup que terá os dados
 * obtidos
 */
export async function getStartupByIdInTransaction(
  transaction: Transaction,
  startupId: string
) {
  // Obtemos o objeto com os dados do documento da
  // startup através da operação de busca atômica
  // gerada pela transaction
  const startupDoc = await transaction.get(startupsCollection.doc(startupId));

  // Se o documento não trouxer dados de uma startup
  // existente, retorna null (que será interceptado
  // pela transação principal)
  if (!startupDoc.exists) {
    return null;
  }

  // Extraindo os dados do documento
  const data = startupDoc.data();

  // Retornando os dados obtidos
  return {
    // Retornando a referência para que ela possa ser
    // acessada pelo próximo update
    ref: startupsCollection.doc(startupId),
    // Retornando os dados da startup
    data: data as StartupDocument,
  };
}

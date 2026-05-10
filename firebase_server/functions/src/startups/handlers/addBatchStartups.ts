/* eslint-disable linebreak-style *//* eslint-disable max-len */
/* Autor: Enzo Olivato Pazian */

// Importando os recursos principais para o uso do firebase
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const db = admin.firestore();

// Referenciando a coleção Startups do banco de dados
const collectionStartups = db.collection("Startups");

/**
 * Exclui TODOS os documentos de uma colecao.
 * @param {FirebaseFirestore.CollectionReference} collectionRef
 * Referencia da colecao desejada.
 * @return {Promise<number>} Numero de documentos excluidos.
 */
async function deleteCollectionDocuments(
  collectionRef: FirebaseFirestore.CollectionReference,
): Promise<number> {
  const snapshot = await collectionRef.get();

  if (snapshot.empty) {
    return 0;
  }

  const deletePromises = snapshot.docs.map((doc) => doc.ref.delete());
  await Promise.all(deletePromises);

  return snapshot.size;
}

// Function para a inserção de dados de startups em lote
export const addBatchStartups = functions
  .https.onRequest(async (request, response) => {
    // Excluindo os dados antigos da coleção
    await deleteCollectionDocuments(collectionStartups);

    // Lista com as startups a serem inseridas
    const startups = [
      {
        "name": "NotaCerta",
        "stage": "em_operacao",
        "shortDescription": "Plataforma digital que conecta alunos interresados em aprender música ...",
        "description": "Plataforma digital que conecta alunos interresados em aprender música com professores qualificados ",
        "executiveSummary": "Startup do setor de Edtech focada em inovação e escalabilidade dentro do ecossistema Mescla.",
        "capitalRaisedCents": 7000000,
        "totalTokensIssued": 100000,
        "currentTokenPriceCents": 70,
        "founders": [
          {
            "name": "Livia Lucizano",
            "role": "CEO",
            "equityPercent": 50,
            "bio": "Responsável pela liderança e visão estratégica da Livia Lucizano.",
          },
          {
            "name": "Laura Soares",
            "role": "Sócio-Fundador",
            "equityPercent": 50,
            "bio": "Responsável pela liderança e visão estratégica da Laura Soares.",
          },
        ],
        "externalMembers": [
          {
            "name": "Harry Styles",
            "role": "Mentor",
            "organization": "PUC-Campinas",
          },
        ],
        "demoVideos": [
          "https: //notacerta-demo.com",
        ],
        "tags": [
          "edtech",
          "puc-campinas",
          "mescla",
        ],
      },
      {
        "name": "HealthVibe",
        "stage": "nova",
        "shortDescription": "Aplicativo de telemedicina focado em saúde mental para estudantes....",
        "description": "Aplicativo de telemedicina focado em saúde mental para estudantes.",
        "executiveSummary": "Startup do setor de healthtech focada em inovação e escalabilidade dentro do ecossistema Mescla.",
        "capitalRaisedCents": 5000000,
        "totalTokensIssued": 1000000,
        "currentTokenPriceCents": 5,
        "founders": [
          {
            "name": "Beatriz Fernandes Costa",
            "role": "CEO",
            "equityPercent": 100,
            "bio": "Responsável pela liderança e visão estratégica da Beatriz Fernandes Costa.",
          },
        ],
        "externalMembers": [
          {
            "name": "Dra. Helena Psicóloga",
            "role": "Mentor",
            "organization": "PUC-Campinas",
          },
        ],
        "demoVideos": [
          "https://mescla.edu/healthvibe",
        ],
        "tags": [
          "healthtech",
          "puc-campinas",
          "mescla",
        ],
      },
      {
        "name": "Metalive",
        "stage": "em_operacao",
        "shortDescription": "Ambiente de integração de realidade aumentada, focado na interação soc...",
        "description": "Ambiente de integração de realidade aumentada, focado na interação social pelo metaverso, incluindo uma inteligencia artificial que cria avatares automáticos referenciando a foto de perfil da pessoa. ",
        "executiveSummary": "Startup do setor de socialtech focada em inovação e escalabilidade dentro do ecossistema Mescla.",
        "capitalRaisedCents": 8900000,
        "totalTokensIssued": 100000,
        "currentTokenPriceCents": 89,
        "founders": [
          {
            "name": "Moski Shimoji",
            "role": "CEO",
            "equityPercent": 25,
            "bio": "Responsável pela liderança e visão estratégica da Moski Shimoji.",
          },
          {
            "name": "Erick Lujahini",
            "role": "Sócio-Fundador",
            "equityPercent": 15,
            "bio": "Responsável pela liderança e visão estratégica da Erick Lujahini.",
          },
          {
            "name": "Emay Saltgate",
            "role": "Sócio-Fundador",
            "equityPercent": 15,
            "bio": "Responsável pela liderança e visão estratégica da Emay Saltgate.",
          },
        ],
        "externalMembers": [
          {
            "name": "Nicky Johan Shimoji",
            "role": "Mentor",
            "organization": "PUC-Campinas",
          },
        ],
        "demoVideos": [
          "https://metaverselive/mescla/tech",
        ],
        "tags": [
          "socialtech",
          "puc-campinas",
          "mescla",
        ],
      },
      {
        "name": "CardVision",
        "stage": "nova",
        "shortDescription": "Plataforma digital que utiliza inteligência artificial para analisar e...",
        "description": "Plataforma digital que utiliza inteligência artificial para analisar e estimar o valor de cartas colecionáveis, como Pokémon, Yu-Gi-Oh e Magic: The Gathering. A ferramenta considera fatores como raridade, estado de conservação (via imagem), histórico de vendas e tendências de mercado para prever preços e auxiliar colecionadores e investidores.",
        "executiveSummary": "Startup do setor de fintech focada em inovação e escalabilidade dentro do ecossistema Mescla.",
        "capitalRaisedCents": 6000000,
        "totalTokensIssued": 500000,
        "currentTokenPriceCents": 12,
        "founders": [
          {
            "name": "Gabriela Silva",
            "role": "CEO",
            "equityPercent": 50,
            "bio": "Responsável pela liderança e visão estratégica da Gabriela Silva.",
          },
          {
            "name": "Lucas Mendes",
            "role": "Sócio-Fundador",
            "equityPercent": 50,
            "bio": "Responsável pela liderança e visão estratégica da Lucas Mendes.",
          },
        ],
        "externalMembers": [
          {
            "name": "Carlos Eduardo",
            "role": "Mentor",
            "organization": "PUC-Campinas",
          },
        ],
        "demoVideos": [
          "https://cardvision-demo.com",
        ],
        "tags": [
          "fintech",
          "puc-campinas",
          "mescla",
        ],
      },
      {
        "name": "PetMatch",
        "stage": "em_operacao",
        "shortDescription": "Plataforma baseada em IA que cruza dados de abrigos de animais com o p...",
        "description": "Plataforma baseada em IA que cruza dados de abrigos de animais com o perfil comportamental e rotina de usuários para sugerir a adoção ideal.",
        "executiveSummary": "Startup do setor de pet tech focada em inovação e escalabilidade dentro do ecossistema Mescla.",
        "capitalRaisedCents": 4500000,
        "totalTokensIssued": 50000,
        "currentTokenPriceCents": 90,
        "founders": [
          {
            "name": "Carla Ribeiro",
            "role": "CEO",
            "equityPercent": 100,
            "bio": "Responsável pela liderança e visão estratégica da Carla Ribeiro.",
          },
        ],
        "externalMembers": [
          {
            "name": "Luisa Schnider",
            "role": "Mentor",
            "organization": "PUC-Campinas",
          },
        ],
        "demoVideos": [
          "https://petmatch.app/video",
        ],
        "tags": [
          "pet tech",
          "puc-campinas",
          "mescla",
        ],
      },
      {
        "name": "AgroSense",
        "stage": "em_expansao",
        "shortDescription": "Sensores IoT para medição de umidade do solo em tempo real....",
        "description": "Sensores IoT para medição de umidade do solo em tempo real.",
        "executiveSummary": "Startup do setor de agrotech focada em inovação e escalabilidade dentro do ecossistema Mescla.",
        "capitalRaisedCents": 80000000,
        "totalTokensIssued": 500000,
        "currentTokenPriceCents": 160,
        "founders": [
          {
            "name": "Marcos Pontes",
            "role": "CEO",
            "equityPercent": 50,
            "bio": "Responsável pela liderança e visão estratégica da Marcos Pontes.",
          },
          {
            "name": "Fabio Luiz",
            "role": "Sócio-Fundador",
            "equityPercent": 50,
            "bio": "Responsável pela liderança e visão estratégica da Fabio Luiz.",
          },
        ],
        "externalMembers": [
          {
            "name": "Dr. Arnaldo Terra",
            "role": "Mentor",
            "organization": "PUC-Campinas",
          },
        ],
        "demoVideos": [
          "https://mescla.edu/agrosense",
        ],
        "tags": [
          "agrotech",
          "puc-campinas",
          "mescla",
        ],
      },
      {
        "name": "SafePay",
        "stage": "em_operacao",
        "shortDescription": "Gateway de pagamento simplificado para microempreendedores locais....",
        "description": "Gateway de pagamento simplificado para microempreendedores locais.",
        "executiveSummary": "Startup do setor de fintech focada em inovação e escalabilidade dentro do ecossistema Mescla.",
        "capitalRaisedCents": 25000000,
        "totalTokensIssued": 150000,
        "currentTokenPriceCents": 166,
        "founders": [
          {
            "name": "Ricardo Mello",
            "role": "CEO",
            "equityPercent": 60,
            "bio": "Responsável pela liderança e visão estratégica da Ricardo Mello.",
          },
          {
            "name": "Michele Campos",
            "role": "Sócio-Fundador",
            "equityPercent": 40,
            "bio": "Responsável pela liderança e visão estratégica da Michele Campos.",
          },
        ],
        "externalMembers": [
          {
            "name": "Mentor Financeiro",
            "role": "Mentor",
            "organization": "PUC-Campinas",
          },
        ],
        "demoVideos": [
          "https://mescla.edu/safepay",
        ],
        "tags": [
          "fintech",
          "puc-campinas",
          "mescla",
        ],
      },
      {
        "name": "UrbanMob",
        "stage": "em_operacao",
        "shortDescription": "Sistema de compartilhamento de patinetes elétricos dentro de campi....",
        "description": "Sistema de compartilhamento de patinetes elétricos dentro de campi.",
        "executiveSummary": "Startup do setor de mobilidade focada em inovação e escalabilidade dentro do ecossistema Mescla.",
        "capitalRaisedCents": 60000000,
        "totalTokensIssued": 300000,
        "currentTokenPriceCents": 200,
        "founders": [
          {
            "name": "Pedro Vaz",
            "role": "CEO",
            "equityPercent": 55,
            "bio": "Responsável pela liderança e visão estratégica da Pedro Vaz.",
          },
          {
            "name": "Clara Luz",
            "role": "Sócio-Fundador",
            "equityPercent": 45,
            "bio": "Responsável pela liderança e visão estratégica da Clara Luz.",
          },
        ],
        "externalMembers": [
          {
            "name": "Eng. Jorge Santos",
            "role": "Mentor",
            "organization": "PUC-Campinas",
          },
        ],
        "demoVideos": [
          "https://mescla.edu/urbanmob",
        ],
        "tags": [
          "mobilidade",
          "puc-campinas",
          "mescla",
        ],
      },
    ];
    // Criando o batch para a operação em lote
    const batch = db.batch();

    // Iterando sobre os dados e preparando as escritas
    startups.forEach((item) => {
      // Criando uma referência para um novo documento com ID automático
      const docRef = collectionStartups.doc();
      batch.set(docRef, item);
    });

    try {
      // Efetuando a operação em lote (commit)
      await batch.commit();
      response.send("Startups inseridas com sucesso!");
    } catch (e) {
      // Exibindo as mensagens de erro
      functions.logger.error("Erro ao inserir startups");
      response.send("Erro ao inserir startups" + e);
    }
  });

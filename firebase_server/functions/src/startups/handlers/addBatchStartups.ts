/* eslint-disable max-len */
/* Autor: Enzo Olivato Pazian */

// Importando os recursos principais para o uso do firebase
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const db = admin.firestore();

// Referenciando a coleção Startups do banco de dados
const collectionStartups = db.collection("Startups");

// Function para a inserção de dados de startups em lote
export const addBatchStartups = functions
  .https.onRequest(async (request, response) => {
    // Lista com as startups a serem inseridas
    const startups = [
      {
        "nome": "NotaCerta",
        "descricao": "Plataforma digital que conecta alunos interessados em aprender música com professores qualificados",
        "estagio": "Em operação",
        "setor": "Edtech",
        "capitalAportado": 70000.0,
        "tokensEmitidos": 100000,
        "tokensDisponiveis": 20000,
        "socios": ["Livia Lucizano", "Laura Soares"],
        "participacaoSocietaria": ["50%", "50%"],
        "mentoresConselho": ["Harry Styles"],
        "videoDemo": "https://notacerta-demo.com",
        "dataCriacao": "2026-04-05T19:01:00Z",
        "valorFixoTokens": 0.70,
        "ofertasAtivas": [{}],
        "status": "Ativa",
      },
      {
        "nome": "HealthVibe",
        "descricao": "Aplicativo de telemedicina focado em saúde mental para estudantes.",
        "estagio": "Nova",
        "setor": "healthtech",
        "capitalAportado": 50000.0,
        "tokensEmitidos": 1000000,
        "tokensDisponiveis": 200000,
        "socios": ["Beatriz Fernandes Costa"],
        "participacaoSocietaria": ["100%"],
        "mentoresConselho": ["Dra. Helena Psicóloga"],
        "videoDemo": "https://mescla.edu/healthvibe",
        "dataCriacao": "2026-04-05T19:01:00Z",
        "valorFixoTokens": 0.05,
        "ofertasAtivas": [{}],
        "status": "Ativa",
      },
      {
        "nome": "Metalive",
        "descricao": "Ambiente de integração de realidade aumentada, focado na interação social pelo metaverso, incluindo uma inteligência artificial que cria avatares automáticos.",
        "estagio": "Em operação",
        "setor": "socialtech",
        "capitalAportado": 89000.0,
        "tokensEmitidos": 100000,
        "tokensDisponiveis": 20000,
        "socios": ["Moski Shimoji", "Abran Lincher; Erick Lujahini", "Emay Saltgate", "Truham Wilson", "Maly Salzburg"],
        "participacaoSocietaria": ["25%", "25%", "20%", "15%", "15%"],
        "mentoresConselho": ["Nicky Johan Shimoji"],
        "videoDemo": "https://metaverselive/mescla/tech",
        "dataCriacao": "2026-04-05T19:01:00Z",
        "valorFixoTokens": 0.89,
        "ofertasAtivas": [{}],
        "status": "Ativa",
      },
      {
        "nome": "CardVision",
        "descricao": "Plataforma digital que utiliza inteligência artificial para analisar e estimar o valor de cartas colecionáveis.",
        "estagio": "Nova",
        "setor": "fintech",
        "capitalAportado": 60000.0,
        "tokensEmitidos": 500000,
        "tokensDisponiveis": 100000,
        "socios": ["Gabriela Silva", "Lucas Mendes"],
        "participacaoSocietaria": ["50%", "50%"],
        "mentoresConselho": ["Carlos Eduardo"],
        "videoDemo": "https://cardvision-demo.com",
        "dataCriacao": "2026-04-05T19:01:00Z",
        "valorFixoTokens": 0.12,
        "ofertasAtivas": [{}],
        "status": "Ativa",
      },
      {
        "nome": "PetMatch",
        "descricao": "Plataforma baseada em IA que cruza dados de abrigos de animais com o perfil comportamental de usuários para adoção.",
        "estagio": "Em operação",
        "setor": "pet tech",
        "capitalAportado": 45000.0,
        "tokensEmitidos": 50000,
        "tokensDisponiveis": 10000,
        "socios": ["Carla Ribeiro"],
        "participacaoSocietaria": ["100%"],
        "mentoresConselho": ["Luisa Schnider"],
        "videoDemo": "https://petmatch.app/video",
        "dataCriacao": "2026-04-05T19:01:00Z",
        "valorFixoTokens": 0.90,
        "ofertasAtivas": [{}],
        "status": "Ativa",
      },
      {
        "nome": "AgroSense",
        "descricao": "Sensores IoT para medição de umidade do solo em tempo real.",
        "estagio": "Em expansão",
        "setor": "agrotech",
        "capitalAportado": 800000.0,
        "tokensEmitidos": 500000,
        "tokensDisponiveis": 0,
        "socios": ["Marcos Pontes", "Fabio Luiz"],
        "participacaoSocietaria": ["50%", "50%"],
        "mentoresConselho": ["Dr. Arnaldo Terra"],
        "videoDemo": "https://mescla.edu/agrosense",
        "dataCriacao": "2026-04-05T19:01:00Z",
        "valorFixoTokens": 1.60,
        "ofertasAtivas": [{}],
        "status": "Inativa",
      },
      {
        "nome": "SafePay",
        "descricao": "Gateway de pagamento simplificado para microempreendedores locais.",
        "estagio": "Em operação",
        "setor": "fintech",
        "capitalAportado": 250000.0,
        "tokensEmitidos": 150000,
        "tokensDisponiveis": 30000,
        "socios": ["Ricardo Mello", "Michele Campos"],
        "participacaoSocietaria": ["60%", "40%"],
        "mentoresConselho": ["Mentor Financeiro"],
        "videoDemo": "https://mescla.edu/safepay",
        "dataCriacao": "2026-04-05T19:01:00Z",
        "valorFixoTokens": 1.67,
        "ofertasAtivas": [{}],
        "status": "Ativa",
      },
      {
        "nome": "UrbanMob",
        "descricao": "Sistema de compartilhamento de patinetes elétricos dentro de campi.",
        "estagio": "Em operação",
        "setor": "mobilidade",
        "capitalAportado": 600000.0,
        "tokensEmitidos": 300000,
        "tokensDisponiveis": 0,
        "socios": ["Pedro Vaz", "Clara Luz"],
        "participacaoSocietaria": ["55%", "45%"],
        "mentoresConselho": ["Eng. Jorge Santos"],
        "videoDemo": "https://mescla.edu/urbanmob",
        "dataCriacao": "2026-04-05T19:01:00Z",
        "valorFixoTokens": 2.00,
        "ofertasAtivas": [{}],
        "status": "Inativa",
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

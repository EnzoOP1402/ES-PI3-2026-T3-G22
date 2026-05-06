import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

// Inicializando o Firebase Admin
admin.initializeApp();

// Referência ao Firestore
const db = admin.firestore();
const collectionStartups = db.collection("startups");

// Função para inserir startups em lote
export const addBatchStartups = functions.https.onRequest(async (request, response) => {
  // Dados das startups que serão inseridos
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
      "ofertasAtivas": [{}], // Adicione detalhes das ofertas ativas se necessário
      "status": "Ativa",
    },
    // Adicione outras startups se necessário
  ];

  // Criando um batch para a operação em lote
  const batch = db.batch();

  // Iterando sobre as startups e adicionando no batch
  startups.forEach((item) => {
    const docRef = collectionStartups.doc();  // Cria um novo documento com ID automático
    batch.set(docRef, item);
  });

  try {
    // Executando o commit do batch, que insere todos os documentos de uma vez
    await batch.commit();
    response.status(200).send("Startups inseridas com sucesso!");
  } catch (e) {
    // Caso ocorra algum erro, será retornada uma mensagem de erro
    functions.logger.error("Erro ao inserir startups", e);
    response.status(500).send("Erro ao inserir startups: " + e);
  }
});
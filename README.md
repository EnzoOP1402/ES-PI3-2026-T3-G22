# MesclaInvest 📈

> **Simulação de Investimentos e Tokenização para o ecossistema de inovação Mescla.**

O **MesclaInvest** é uma plataforma mobile desenvolvida para conectar a comunidade ao ecossistema de startups do **Mescla** (Hub de Inovação da PUC-Campinas).

A aplicação permite que usuários atuem como **Investidores Anjo** em um ambiente totalmente educacional, realizando investimentos simulados por meio da compra e venda de tokens representativos de participação em startups.

O objetivo é proporcionar uma experiência prática sobre investimentos, empreendedorismo e mercado financeiro, incentivando a interação entre investidores e startups de forma segura, transparente e acessível.

---

## 🚀 Objetivos do Projeto

Diferente de aplicativos de investimento comuns, o MesclaInvest foca na transparência e na experiência da **Tokenização**. Através de uma interface analítica, o investidor pode analisar informações detalhadas das startups, interagir com elas e negociar ativos no Balcão de Tokens.

* Aproximar a comunidade acadêmica do ecossistema de startups.
* Simular operações de investimento em empresas inovadoras.
* Permitir a negociação de tokens em um mercado secundário.
* Promover educação financeira e empreendedorismo.
* Oferecer uma experiência intuitiva e gamificada de investimento.

### 🖥️ Principais Funcionalidades

🔐 **Autenticação e Segurança**

* Cadastro de usuários.
* Login seguro.
* Recuperação de senha.
* Controle de acesso para usuários autenticados.

🏢 **Catálogo de Startups**

Os usuários podem visualizar startups cadastradas na plataforma contendo:

* Nome da startup.
* Descrição.
* Área de atuação.
* Plano de negócio.
* Estrutura societária.
* Quantidade de tokens emitidos.
* Valor unitário dos tokens.

💰 **Investimento em Tokens**

O investidor pode:

* Comprar tokens diretamente das startups.
* Visualizar informações detalhadas antes da compra.
* Consultar o valor unitário dos ativos.
* Acompanhar sua participação em cada startup.

📊 **Dashboard do Investidor**

O dashboard apresenta:

* Quantidade de tokens adquiridos.
* Acompanhamento em tempo real da valorização dos tokens adquiridos.
* Evolução dos investimentos.
* Retorno sobre investimento (ROI).

💼 **Carteira Simulada**

A carteira permite:

* Visualização do saldo disponível.
* Depósitos simulados.
* Lista dos tokens adquiridos.
* Histórico de transações.
* Histórico de ofertas
* Cancelar ordens abertas.

🏪 **Balcão de Tokens**

Mercado secundário para negociação entre usuários.

Funcionalidades:

* Abrir ordens de compra.
* Abrir ordens de venda.
* Comprar tokens de outros investidores.
* Visualizar ofertas disponíveis.
* Acompanhar status das negociações.

❓ **Sistema de Perguntas**

Os investidores podem interagir com as startups através de:

* Perguntas Públicas

Visíveis para todos os usuários.

* Perguntas Privadas
  
Visíveis apenas para o investidor e a startup.

### 📱 Principais Telas

**Tela de Login**

Permite autenticação e recuperação de senha.

**Tela Inicial (Home)**

Apresenta destaques do ecossistema.

**Catálogo de Startups**

Lista todas as startups disponíveis para investimento.

**Detalhes da Startup**

Exibe informações completas da empresa e opção de investimento.

**Dashboard**

Apresenta indicadores financeiros do investidor.

**Carteira**

Exibe saldo, ativos e histórico de transações.

**Balcão de Tokens**

Permite negociação entre investidores.

**Perfil**

Gerenciamento dos dados do usuário.

---

### 🏗️ Arquitetura do Sistema

O MesclaInvest segue uma arquitetura baseada em serviços utilizando Firebase como backend.

**Frontend**

* Flutter
* Dart
  
**Backend**

* Firebase Functions
* TypeScript

**Autenticação**

* Firebase Authentication

**Banco de Dados**

* Cloud Firestore

---

## 🛠️ Tecnologias Utilizadas

O projeto utiliza tecnologias de ponta para garantir performance e escalabilidade:

* **Framework:** [Flutter](https://flutter.dev/) 
* **Linguagens:** Dart e Typescript
* **Backend & Auth:** [Firebase](https://firebase.google.com/)
* **Banco de Dados:** Cloud Firestore (NoSQL)
* **Arquitetura:** Lógica de Blockchain simulada para integridade das transações.

----

## 📂 Estrutura do Projeto

```
lib/
├── core/
├── features/
│   ├── auth/
│   ├── catalog/
│   ├── dashboard/
│   ├── exchange/
│   ├── wallet/
│   ├── profile/
│   └── startup/
├── routes/
├── services/
└── main.dart

functions/
├── src/
├── package.json
└── tsconfig.json
```

---

## 👥 A Equipe 22

Confira os desenvolvedores deste projeto:

| Integrante | GitHub |
| :--- | :---: |
| **Bernardo Castro Brandão de Oliveira** | [🔗](https://github.com/Bernardooficial123) |
| **Enzo Olivato Pazian** | [🔗](https://github.com/EnzoOP1402) |
| **Gabriela Sichiroli Ferrari** | [🔗](https://github.com/GabSichiroli) |
| **Livia Carvalho Lucizano** | [🔗](https://github.com/Liviaengsoftware) |
| **Murillo Iamarino Caravita** | [🔗](https://github.com/MurilloCaravita) |
| **Rafael Henrique dos Santos Inácio** | [🔗](https://github.com/rafaelhenriqueinacio) |

---

## ⚠️ Disclaimer (Aviso Legal)

Este projeto possui finalidade exclusivamente acadêmica - (Projeto Integrador 3 - Engenharia de Software). 

* Não utiliza dinheiro real.
* Não realiza investimentos reais.
* Não emite ativos financeiros.
* Não utiliza blockchain pública.
* Todas as operações são simuladas para fins educacionais.
* As transações de tokens são simuladas e não possuem valor jurídico ou financeiro fora do ambiente do projeto.
  
O MesclaInvest não constitui recomendação financeira, corretora de valores ou plataforma de investimentos real.

---

## 🎓 Projeto Acadêmico

Desenvolvido para a disciplina Projeto Integrador III do curso de Engenharia de Software da Pontifícia Universidade Católica de Campinas (PUC-Campinas).

Professor Orientador: Prof. Me. Mateus Pereira Dias

---

## 🛣️ Como iniciar o projeto MesclaInvest

Passo-a-passo para realizar as instalações dos pacotes e ferramentas necessárias para a inicialização do aplicativo.

## 1. Instalação manual do Flutter SDK no Windows
- **Baixar o Flutter SDK (zip)**: Acesse a documentação oficial: https://docs.flutter.dev/get-started/install/windows e baixe o pacote .zip do Flutter SDK para Windows.
- **Extrair em pasta apropriada**: Crie (se necessário) a pasta C:\development e depois sdks. Extraia o zip para C:\development\sdks\flutter.
  
Estrutura esperada:
```
C:\development\sdks\flutter\bin
```
- **Configurar PATH no sistema**: Abra o menu iniciar e pesquise por **Variáveis de Ambiente para a sua Conta** e clique em Editar as variáveis de ambiente do sistema. Abra Variáveis de Ambiente e depois em Variáveis do usuário (ou do sistema), selecione Path e clique em Editar.

Adicione a entrada:
```
C:\dev\flutter\bin
```
- Confirme com OK em todas as janelas.

## 2. Importar Node.js
- **Instalação do Pacote Node.js**: Acesse https://nodejs.org/pt-br e clique em "Baixar Node.js". 
- Baixe o instalador para Windows (.msi).
- Execute o instalador e mantenha as opções padrão.
- Finalize a instalação.

Após concluir, abra o Prompt de Comando ou PowerShell e verifique se a instalação foi realizada corretamente:

```bash
node -v
npm -v
```

## 3. Instalar o Git
- Acesse o site oficial do Git: https://git-scm.com/downloads e baixe a versão para Windows.
- Durante a instalação, mantenha as opções padrão e conclua o processo.
- Após instalar, abra o terminal e verifique se o Git foi instalado corretamente:

```bash
git --version
```

## 4. Clonar o repositório do projeto
- Após instalar o Git, abra o terminal na pasta onde deseja salvar o projeto e execute:

git clone https://github.com/zarpela/ES-PI3-2026-T3-G18.git

- Depois, entre na pasta do projeto:

cd ES-PI3-2026-T3-G18

## 5. Instalar as dependências do Flutter
- Na raiz do projeto, execute:
  
```bash
flutter pub get
```

- Esse comando baixa todos os pacotes utilizados pelo aplicativo.

## 6. Configurar o Firebase
- O projeto utiliza Firebase Authentication, Cloud Firestore e Firebase Functions.

- Para utilizar o Firebase, é necessário ter o Firebase CLI instalado. Execute:
  
```bash
npm install -g firebase-tools
```

- Depois, faça login na sua conta Firebase:

firebase login

- Caso seja necessário vincular o projeto local ao Firebase, execute:

```bash
firebase use --add
```

- E selecione o projeto correspondente ao MesclaInvest.

## 7. Instalar dependências das Firebase Functions
- Entre na pasta functions:
  
```bash
cd functions
```

- Instale as dependências:

```bash
npm install
```

- Depois, volte para a raiz do projeto:

```bash
cd ..
```

## 8. Rodar o projeto no Chrome
- Com tudo configurado, execute:

```bash
flutter run -d chrome
```

- O aplicativo será iniciado no navegador Google Chrome.

## 9. Rodar o projeto em um emulador ou celular Android

- Caso deseje executar em um dispositivo Android, conecte o celular ou abra um emulador e execute:

```bash
flutter devices
```

- Depois rode:

```bash
flutter run
```

## 10. Comandos úteis durante o desenvolvimento

- Atualizar pacotes:

```bash
flutter pub get
```

- Verificar problemas no ambiente Flutter:

```bash
flutter doctor
```

- Limpar arquivos temporários do projeto:

```bash
flutter clean
```

- Rodar novamente após limpar:

```bash
flutter pub get
flutter run -d chrome
```

## 11. Fluxo principal de uso

- O fluxo principal do MesclaInvest funciona da seguinte forma:

1. O usuário cria uma conta ou realiza login.
2. Acessa o catálogo de startups disponíveis.
3. Visualiza os detalhes de uma startup.
4. Analisa informações como descrição, tokens disponíveis e valor unitário.
5. Realiza a compra simulada de tokens.
6. Acompanha seus ativos na carteira.
7. Visualiza indicadores no dashboard.
8. Pode negociar tokens no Balcão de Tokens com outros usuários.
9. Regras de negócio principais
* Apenas usuários cadastrados podem realizar transações.
* O saldo da carteira é simulado.
* O usuário só pode comprar tokens se possuir saldo suficiente.
* O usuário só pode vender tokens que possui.
* As transações devem ser registradas no histórico.
* Ordens abertas podem ser visualizadas no Balcão de Tokens.
* As operações não possuem valor financeiro real.

## 12. Considerações finais

O MesclaInvest foi desenvolvido como uma solução acadêmica para simular investimentos em startups por meio de tokens digitais.

A proposta busca unir tecnologia, inovação e educação financeira, permitindo que os usuários compreendam melhor o funcionamento de investimentos, valorização de ativos e negociação em mercado secundário.

Mesmo sendo uma simulação, o projeto foi estruturado com foco em boas práticas de desenvolvimento, organização de código, segurança, experiência do usuário e integração com serviços em nuvem.

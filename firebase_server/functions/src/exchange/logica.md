# Estruturando a Lógica: O Funcionamento do Balcão

O balcão de tokens do **MesclaInvest** funcionará como um **Motor de Correspondência de Ordens (Order Matching Engine)**. Suas principais funções são permitir que usuários abram ordens de compra e venda, realizando-as entre si através de um sistema que analisa a compatibilidade e efetua as transações de forma automatizada.

---

## 1. Modelando o Banco de Dados (Firestore)

Antes de nos aprofundarmos na lógica do motor, precisamos organizar como os dados serão gerenciados no Firestore.

### Coleção `users`

Todo documento de usuário deverá receber novos campos e uma estrutura de subcoleção:

* **`balanceAvailable` (double):** Saldo disponível do usuário que pode ser usado para abrir novas ordens de compra.


* **`balanceFrozen` (double):** Saldo congelado do usuário, que está injetado em ofertas de compra ainda não realizadas.


* **Subcoleção `wallet`:** Localizada no caminho `users/{userId}/wallet/{startupId}/`. O ID de cada documento dentro dela será o próprio ID da startup da qual o usuário possui tokens. Seus campos serão:


* `startupId` (String): ID da startup para facilitar buscas, se necessário.


* `startupName` (String): Nome da startup para fins de exibição na interface.


* `tokenName` (String): Nome do token para fins de exibição.


* `availableQuantity` (int): Quantidade de tokens livres que o usuário possui e pode colocar à venda.


* `lockedQuantity` (int): Quantidade de tokens reservados (presos em ordens de venda ainda não realizadas).





### Coleção `startups`

O que precisaremos adicionar de novo no documento de cada startup é:

* **`tokenName` (String):** Nome que representa a moeda digital da startup.


* **`investors` (array):** Lista contendo os IDs de todos os usuários que possuem tokens daquela startup no momento.



### Coleção `offers`

Esta é a principal coleção do balcão. No caminho `offers/{offerId}/`, teremos os seguintes campos:

* `userId` (String): ID do usuário que abriu a ordem.


* `startupId` (String): ID da startup à qual os tokens pertencem.


* `type` (String): Tipo da ordem, variando estritamente entre `"buy"` ou `"sell"`.


* `priceCents` (double): Preço unitário divulgado na oferta.


* `quantity` (int): Quantidade total de tokens divulgados na oferta.


* `remainingQuantity` (int): Quantidade de tokens restante, caso a oferta tenha sido realizada parcialmente.


* `status` (String): Status da oferta no balcão, variando entre `"open"`, `"partial"`, `"completed"` ou `"canceled"`. *Nota: Uma oferta só pode ser realizada se possuir status "open" ou "partial".*


* `createdAt` (ServerTimestamp): Data e hora de criação da oferta (essencial para a ordenação da fila).



### Coleção `blockchain`

Armazenará o histórico imutável das transações quando uma ordem for realizada. No caminho `blockchain/{transactionId}/`, teremos:

* `buyerId` (String): ID do usuário que pagou pelos tokens e os recebeu.


* `sellerId` (String?): Atributo *nullable* contendo o ID do usuário que vendeu os tokens (será `null` em compras direto da startup).


* `startupId` (String): ID da startup dona dos tokens.


* `quantity` (int): Quantidade exata de tokens envolvidos nesta transação específica.


* `unitPriceCents` (double): Preço unitário do token nesta transação.


* `totalPriceCents` (double): Valor total da transação ($quantity \times unitPrice$) para evitar erros de arredondamento.


* `buyOrderId` (String?): ID da ordem de compra que gerou a transação (`null` se for compra a mercado).


* `sellOrderId` (String?): ID da ordem de venda que gerou a transação (`null` se for compra a mercado).


* `registeredAt` (ServerTimestamp): Data e hora exata do registro da transação.



---

## 2. Destrinchando a Lógica (Smart Contracts via Servidor)

Como os smart contracts reais fogem do escopo, simularemos suas ações via lógica de servidor usando **Callable Functions** (chamadas diretamente pelo Flutter para criar/cancelar ordens) e a execução de **`runTransaction`** no SDK Admin do Firebase para garantir a atomicidade das operações.

> **O que é uma Transaction (Transação Atômica)?**
> É um conjunto de operações de leitura e gravação executadas sob a regra do "tudo ou nada". Se qualquer etapa falhar ou for interrompida, a operação inteira é abortada, evitando inconsistências em saldos ou inventários.
> 
> 

### A. Criação de Ordem de Compra (`createBuyOrder` - Callable Function)

1. Verifica a autenticação do usuário.


2. Obtém os dados do documento do usuário no Firestore.


3. Verifica se o `balanceAvailable` é maior ou igual ao valor total da ordem ($\text{quantidade de tokens} \times \text{preço unitário}$).


* *Se o saldo for insuficiente:* Lança um erro do tipo `FailedPrecondition`.




4. Subtrai o valor total do `balanceAvailable` e o adiciona ao `balanceFrozen`.


5. Cria um documento na coleção `offers` com status `"open"` e `remainingQuantity` igual à quantidade total definida.


6. Encerra a transação (se houver erro em qualquer etapa, lança suas exceções).



### B. Criação de Ordem de Venda (`createSellOrder` - Callable Function)

1. Verifica a autenticação do usuário.


2. Lê o caminho `wallet/{startupId}/` do usuário.


3. Verifica e subtrai a quantidade de tokens da carteira (alterando de `availableQuantity` para `lockedQuantity`), impedindo que o usuário venda duas vezes o mesmo token.


4. Cria um documento na coleção `offers` com status `"open"` e `remainingQuantity` igual à quantidade definida.


5. Encerra a transação e lança exceções caso ocorram erros.

### C. Cancelamento de Ordem (`cancelOrder` - Callable Function)

1. Verifica a autenticação do usuário.


2. Verifica se o status atual da ordem ainda é `"open"` ou `"partial"`.


3. Altera o status da ordem para `"canceled"`.


4. 
**Se for uma ordem de compra (Estorno):** Calcula o valor correspondente a $\text{remainingQuantity} \times \text{price}$, retira esse valor do `balanceFrozen` e o devolve para o `balanceAvailable`.


5. 
**Se for uma ordem de venda (Estorno):** Devolve a quantidade contida em `remainingQuantity` de volta para o saldo disponível (`availableQuantity`) da wallet do usuário.


6. Encerra a transação e lança as devidas exceções em caso de falha.



---

## 3. O Motor de Correspondência (`orderMatchingEngine` - Trigger Function)

Para evitar que o aplicativo trave, o motor rodará em segundo plano através de um Cloud Function Trigger alocado na coleção `offers`, sendo acionado nos eventos `onDocumentCreated` e `onDocumentUpdated`. Sempre que uma oferta com status `"open"` surgir, o motor acorda para buscar um par compatível.

### Lógica do Algoritmo:

1. **Identifica o tipo da ordem:** Se é `"buy"` ou `"sell"`.


2. **Consulta a fila de ofertas em busca de um oposto:** 


* **Se a ordem for de COMPRA (Ex: quer pagar R$ 2,00):**
* Busca na coleção `offers` onde `type == 'sell'`, mesmo `startupId`, status seja `'open'` ou `'partial'` e `price` $\le 2.00$.


* **Ordenação da busca:** Ordenado de forma **crescente de preço** (traz os vendedores mais baratos primeiro) e **crescente de data** (prioridade por ordem de chegada/FIFO).




* **Se a ordem for de VENDA (Ex: quer vender por R$ 1,50):**
* Busca na coleção `offers` onde `type == 'buy'`, mesmo `startupId`, status seja `'open'` ou `'partial'` e `price` $\ge 1.50$.


* **Ordenação da busca:** Ordenado de forma **decrescente de preço** (traz os compradores dispostos a pagar mais caro primeiro) e **crescente de data** (prioridade por ordem de chegada/FIFO).






3. **Loop de Realizações:** Com base nos resultados, o sistema itera pelos itens encontrados. Para cada combinação válida (*match*), ele abre uma `runTransaction` individual para processar as seguintes ações atômicas:


* **Cálculo do Preço Final:** A regra do mercado dita que a **ordem passiva** (a que já estava registrada no *book*) define o preço da transação. Se o comprador ofereceu R$ 2,00 mas a venda disponível era de R$ 1,50, o negócio fecha a R$ 1,50. O comprador recebe de volta a diferença como "troco".


* **Cálculo da Quantidade:** A quantidade de tokens transferida será o **menor valor** entre a `remainingQuantity` da Ordem A e a `remainingQuantity` da Ordem B.


* **Ações do "Smart Contract" Simulado:** 


1. *Parte Financeira:* Desconta o valor final calculado do `balanceFrozen` do comprador e adiciona ao `balanceAvailable` do vendedor. Se houver troco, o saldo remanescente do comprador volta para o seu `balanceAvailable`.


2. *Troca de Tokens:* Soma os tokens negociados na `wallet` do comprador (do vendedor não precisa tirar agora, pois já foi debitado ao criar a oferta).


3. *Registro na Blockchain:* Grava um novo documento na coleção `blockchain` documentando IDs, startup, volume, preço e carimbo de data/hora.


4. *Revisão dos Investidores:* Adiciona o ID do comprador ao array `investors` da startup (caso não esteja lá). Se a quantidade total de tokens do vendedor zerar e ele não tiver nenhuma outra ordem de venda aberta, remove o ID dele do array `investors` da startup.


5. *Atualização das Ofertas:* Subtrai a quantidade negociada do campo `remainingQuantity` de ambas as ordens. Se alguma atingir `0`, seu status muda para `"completed"`; se ainda restarem tokens, muda para `"partial"`.






4. **Condição de Parada:** O loop continua consumindo as ordens compatíveis da fila até que a ordem recém-criada mude para o status `"completed"`, ou até que acabem todas as ofertas compatíveis no *book*.



---

## 4. Compra a Mercado (`buyFromStartupMarket` - Callable Function)

Esta modalidade é a mais direta por não passar pelo livro de ofertas nem criar ordens cruzadas. A compra ocorre diretamente com a startup emissora:

1. Verifica a autenticação do usuário.


2. Obtém os dados do documento do usuário.


3. Verifica se a startup possui a quantidade de tokens desejada em seu estoque disponível para venda.


4. Verifica se o `balanceAvailable` do usuário é maior ou igual ao custo total ($\text{quantidade desejada} \times \text{preço unitário da startup}$).


* *Se for insuficiente:* Retorna um erro do tipo `FailedPrecondition`.




5. Subtrai o valor total do `balanceAvailable` do usuário.


6. **Aumenta o capital aportado da Startup** no documento correspondente.


7. Adiciona os tokens comprados diretamente à `wallet` do usuário.


8. Subtrai os tokens vendidos do estoque disponível da startup.


9. Encerra a transação e reporta exceções em caso de falhas.
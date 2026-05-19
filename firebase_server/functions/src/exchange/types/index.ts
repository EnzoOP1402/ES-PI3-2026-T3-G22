/* Autor: Enzo Olivato Pazian */

import {FieldValue} from "firebase-admin/firestore";

/**
 * Representa o tipo de ordem criada.
 *
 * - `buy`: indica que é uma ordem de compra.
 * - `sell`: indica que é uma ordem de venda.
 *
 * Os valores usam snake_case para facilitar armazenamento, filtros
 * e comparação direta no Firestore e nas chamadas callable.
 */
export type OrderType = "buy" | "sell";

/**
 * Representa o status de uma ordem.
 *
 * - `open`: indica que a ordem foi aberta e ainda não foi realizada.
 * - `partial`: indica que a ordem está aberta e foi realizada parcialmente.
 * - `completed`: indica que a ordem foi realizada e está fechada.
 * - `canceled`: indica que a ordem foi cancelada e está fechada.
 */
export type OrderStatus = "open" | "partial" | "completed" | "canceled";

/**
 * Dados mínimos do usuário autenticado necessários para regras de negócio.
 *
 * Este tipo é derivado do `request.auth` das Callable Functions. Ele evita que
 * os handlers dependam diretamente do formato completo do token Firebase e
 * preserva apenas o que o domínio precisa: UID e e-mail, quando disponível.
*/
export type AuthenticatedUser = {
    uid: string;
    email?: string;
};

/**
 * Documento de Oferta/Ordem armazenado na coleção offers do Firestore.
 *
 * Cada propriedade representa um campo no documento que representa uma
 * ordem no Firebase. Os campos `startupName` e `tokenName` são necessários
 * para fins puramente estéticos, de modo a não exigir que uma busca por
 * esses dados precise ser feita todas as vezes que uma oferta for
 * carregada na interface.
 */
export type OfferDocument = {
    userId: string;
    startupId: string;
    startupName: string;
    tokenName: string;
    type: OrderType;
    priceCents: number;
    quantity: number;
    remainingQuantity: number;
    status: OrderStatus;
    createdAt: FieldValue
};


/* Autor: Enzo Olivato Pazian */

import {Timestamp, FieldValue} from "firebase-admin/firestore";

// Definindo o tipo que representa o documento de um
// usuário
export type UserDocument = {
  fullName: string;
  cpf: string;
  email: string;
  phone: string;
  balanceAvailableCents: number;
  balanceFrozenCents: number;
  twoFAOn: boolean;
  // Permite a escrita com serverTimestamp e leitura com Timestamp
  createdAt: Timestamp | FieldValue;
};

// Interface auxiliar para quando lemos do banco e
// precisamos do ID acoplado
export interface UserWithId extends UserDocument {
  // Armazena o UID que veio do path do documento
  id: string;
  // Quando lemos dados, a data já foi registrada, então
  // usamos Timestamp
  createdAt: Timestamp;
}

// Definindo o tipo que representa o documento da Wallet
// de um usuário
export type WalletDocument = {
  startupId: string,
  startupName: string,
  tokenName: string,
  availableQuantity: number,
  lockedQuantity: number,
  totalQuantity: number,
}
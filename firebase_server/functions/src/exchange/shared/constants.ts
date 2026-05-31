/* Autor: Enzo Olivato Pazian - 25001654 */

import {OrderStatus, OrderType} from "../types";

export const allowedTypes: OrderType[] = [
  "buy",
  "sell",
];

export const allowedStatus: OrderStatus[] = [
  "open",
  "partial",
  "completed",
  "canceled",
];

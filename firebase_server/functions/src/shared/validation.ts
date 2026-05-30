/* eslint-disable require-jsdoc */
export function normalizeString(value: unknown): string | undefined {
  if (typeof value !== "string") {
    return undefined;
  }
  const trimmed = value.trim();
  return trimmed.length > 0 ? trimmed : undefined;
}

/* Trecho escrito por: Enzo Olivato Pazian */

/**
 * Função responsável por normalizar e converter campos para dados numéricos
 *
 * @param {unknown} value - O valor que será verificado
 * @return {undefined | number} um undefined ou o número convertido
 */
export function normalizeNumber(value: unknown): number | undefined {
  if (
    // Verifica se o tipo do dado é diferente de `number`
    typeof value !== "number" ||
    // Verifica se o valor não é numérico
    isNaN(Number(value)) ||
    // Verifica se o valor não é um número finito (válido)
    !Number.isFinite(value)
  ) {
    // Se qualquer uma das condições for verdadeira, retorna undefined
    return undefined;
  }
  // Se ele for um número, retorna sua versão convertida
  return Number(value);
}

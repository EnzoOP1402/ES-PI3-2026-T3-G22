/* Autor: Enzo Olivato Pazian */

/**
 * Normaliza e formata um número de telefone brasileiro
 * para o padrão internacional E.164.
 * Remove máscaras como (XX) XXXXX-XXXX e adiciona o
 * código +55 se necessário.
 * @param {string} phoneString O telefone bruto enviado pelo cliente
 * @return {string | null} O telefone formatado
 * (Ex: +5511999999999) ou null se for inválido
 */
export function normalizePhoneToE164(
  phoneString: unknown
): string | null {
  // Verifica se o telefone recebido é uma string
  if (!phoneString || typeof phoneString !== "string") {
    return null;
  }

  // Remove todos os caracteres não numéricos
  const cleanPhone = phoneString.replace(/\D/g, "");

  // Caso o número limpo já comece com "55" e tenha 12 ou 13 dígitos,
  // significa que o código do país já foi enviado e ele está válido
  if (
    cleanPhone.startsWith("55") &&
    (cleanPhone.length === 12 || cleanPhone.length === 13)
  ) {
    return `+${cleanPhone}`;
  }

  // Validando o tamanho para números brasileiros comuns (com DDD)
  // Celulares têm 11 dígitos (DDD + 9 + 8 dígitos)
  // Telefones fixos têm 10 dígitos (DDD + 8 dígitos)
  if (cleanPhone.length !== 10 && cleanPhone.length !== 11) {
    // Se não atender ao tamanho mínimo, está incompleto
    return null;
  }

  // Injetando o código do país padrão (Brasil = +55) e retornando
  // o número formatado
  return `+55${cleanPhone}`;
}

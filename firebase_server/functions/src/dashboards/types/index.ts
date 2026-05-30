/* Autor: Enzo Olivato Pazian */

import {Timestamp} from "firebase-admin/firestore";


/**
 * Tipo que define os períodos possíveis de serem
 * utilizados como filtros para os dashboards.
 */
export type DashboardPeriod = "24h" | "7d" | "1m" | "6m" | "1y";

/**
 * Tipo que representa a requisição vinda do Flutter para
 * o acesso à Function que renderiza os dados para a
 * plotagem dos gráficos, contendo o filtro dos períodos
 * e o texto do campo de busca.
 */
export type DashboardRequest = {
  period?: DashboardPeriod;
  searchQuery?: string;
}

/**
 * Tipo que representa o par ordenado que será utilizado
 * para alimentar o fl_chart no Flutter.
 *
 * `x` representa a Timestamp em milissegundos
 * `y` representa o preço em reais (convertido de
 * centavos para o gráfico)
*/
export type ChartPoint = {
  x: number;
  y: number;
}

/**
 * Tipo que representa a resposta retornada pela Function
 * getUserDashboardData que servirá como base para as
 * renderizações em Flutter.
 */
export type StartupDashboardData = {
  startupId: string;
  startupName: string;
  logoUrl?: string;
  currentPrice: number;
  variationPercentage: number;
  isPositive: boolean;
  chartData: ChartPoint[];
}

/**
 * Tipo que representa o documento das coleções de histórico
 * de preço.
 */
export type PriceHistoryDocument = {
  averagePriceCents: number;
  timestamp: Timestamp;
}

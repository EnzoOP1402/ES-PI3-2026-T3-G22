/* Autor: Mateus Dias */

export {addBatchStartups} from "./handlers/addBatchStartups";
export {listStartups} from "./handlers/listStartups";
export {createStartupQuestion} from "./handlers/createStartupQuestion";
export {getStartupDetails} from "./handlers/getStartupDetails";

export {getStartupsForBuyOrders} from "./handlers/getStartupsForBuyOrders";

export {getStartupsForSellOrders} from "./handlers/getStartupsForSellOrders";

/* Modificado por: Enzo Olivato Pazian - 25001654 */
// Exportando a função de obtenção dos dados de uma startup
// para que ela possa ser acessada por outros arquivos
export {getStartupById} from "./repositories/startupRepository";

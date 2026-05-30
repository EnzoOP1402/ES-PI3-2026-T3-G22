export {addBatchStartups} from "./handlers/addBatchStartups";
export {getStartups} from "./handlers/getStartups";
export {getStartupsTest} from "./handlers/getStartupsTest";
export {listStartups} from "./handlers/listStartups";
export {createStartupQuestion} from "./handlers/createStartupQuestion";
export {getStartupDetails} from "./handlers/getStartupDetails";

export {getStartupsForBuyOrders} from "./handlers/getStartupsForBuyOrders";

export {getStartupsForSellOrders} from "./handlers/getStartupsForSellOrders";

// Exportando a função de obtenção dos dados de uma startup
// para que ela possa ser acessada por outros arquivos
export {getStartupById} from "./repositories/startupRepository";

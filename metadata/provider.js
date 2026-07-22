import "dotenv/config";
import { JsonRpcProvider } from "ethers";

export const provider = new JsonRpcProvider(process.env.RPC_URL);

import { network } from "hardhat";

const { viem } = await network.connect("mainnet");
const [wallet] = await viem.getWalletClients();

const pizzaSlices = await viem.deployContract("PizzaSlices", [
  wallet.account.address,
]);

console.log("PizzaSlices:", pizzaSlices.address);
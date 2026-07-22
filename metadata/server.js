import "dotenv/config";
import express from "express";
import { Contract } from "ethers";
import { provider } from "./provider.js";
import { ABI } from "./abi.js";
import { LEVELS } from "./levels.js";

const app = express();

const contract = new Contract(
  process.env.CONTRACT_ADDRESS,
  ABI,
  provider
);

app.get("/metadata/:id", async (req, res) => {
  try {
    const tokenId = req.params.id;

    const level = Number(await contract.sliceLevel(tokenId));
    const slice = LEVELS[level] ?? LEVELS[0];

    res.json({
      name: `Pizza Slice #${String(tokenId).padStart(5, "0")}`,
      description: "Dynamic PizzaSlices NFT",
      image: `https://satopizza.xyz/${slice.image}`,
      attributes: [
        {
          trait_type: "Slice",
          value: slice.name
        },
        {
          trait_type: "Level",
          value: level
        }
      ]
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.listen(process.env.PORT, () => {
  console.log(`Metadata server running on port ${process.env.PORT}`);
});

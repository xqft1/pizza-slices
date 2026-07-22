import "dotenv/config";
import express from "express";
import { Contract } from "ethers";
import { provider } from "./provider.js";
import { ABI } from "./abi.js";
import { LEVELS } from "./levels.js";
import fs from "fs";
import path from "path";

const app = express();

const contract = new Contract(
  process.env.CONTRACT_ADDRESS,
  ABI,
  provider
);

// Metadata endpoint
app.get("/metadata/:id", async (req, res) => {
  try {
    const tokenId = req.params.id;

    const level = Number(await contract.sliceLevel(tokenId));
    const slice = LEVELS[level] ?? LEVELS[0];

    res.json({
      name: `Pizza Slice #${String(tokenId).padStart(5, "0")}`,
      description: "Dynamic PizzaSlices NFT",
      image: `https://metadata.satopizza.xyz/image/${tokenId}`,
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

// Dynamic SVG image endpoint
app.get("/image/:id", async (req, res) => {
  try {
    const tokenId = req.params.id;

    const level = Number(await contract.sliceLevel(tokenId));
    const slice = LEVELS[level] ?? LEVELS[0];

    const svgPath = path.join(
  process.cwd(),
  "images",
  `${slice.name}.svg`
);

    let svg = fs.readFileSync(svgPath, "utf8");

    svg = svg
      .replace("{{IMAGE}}", `https://satopizza.xyz/${slice.image}`)
      .replace("{{TOKEN}}", String(tokenId).padStart(5, "0"));

    res.setHeader("Content-Type", "image/svg+xml");
    res.send(svg);
  } catch (err) {
    res.status(500).send(err.message);
  }
});

app.listen(process.env.PORT, () => {
  console.log(`Metadata server running on port ${process.env.PORT}`);
});

/* eslint-disable no-undef */
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const axios = require('axios');
const { ethers } = require('ethers');
const contractABI = require('./PlayerProgress.json');
const contractAddress = process.env.CONTRACT_ADDRESS;

const app = express();
const port = 3000;

app.use(cors());
app.use(express.json());

app.get('/', (req, res) => {
  res.send('🧠 Groq AI Game Server is running!');
});

// ✅ GROQ LLM Enemy Stats Route
const getEnemyStatsFromGroqLLM = async (level) => {
  try {
    const groqAPIUrl = 'https://api.groq.com/openai/v1/chat/completions';

    const requestBody = {
      model: 'llama-3.3-70b-versatile',
      messages: [
        {
          role: 'user',
          content: `Generate unique JSON for 4 enemies: skeleton, eye, mushroom, goblin at level ${level}. Include health, damage, and orb value for each. Format as JSON.`
        }
      ],
      max_tokens: 200,
      temperature: 0.9,
      top_p: 0.9
    };

    const response = await axios.post(groqAPIUrl, requestBody, {
      headers: {
        'Authorization': `Bearer ${process.env.GROQ_API_KEY}`,
        'Content-Type': 'application/json'
      }
    });

    const content = response.data.choices[0].message.content;
    const cleaned = content.replace(/```json|```/g, '').trim();
    return JSON.parse(cleaned);

  } catch (error) {
    console.error("Error fetching data from Groq LLM:", error.response?.data || error.message);
    return null;
  }
};

app.get('/enemy-stats/:level', async (req, res) => {
  console.log("request recieved")
  const level = parseInt(req.params.level, 10);

  if (isNaN(level)) {
    return res.status(400).json({ error: 'Invalid level' });
  }

  const enemyStats = await getEnemyStatsFromGroqLLM(level);

  if (enemyStats) {
    return res.json(enemyStats);
  } else {
    return res.status(500).json({ error: 'Failed to fetch enemy stats from Groq LLM' });
  }
});

app.post('/update', async (req, res) => {
  console.log("Request received", req.body);
  const { address, orbs, level } = req.body;

  try {
    const provider = new ethers.JsonRpcProvider(process.env.RPC_URL);
    const signer = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
    const contract = new ethers.Contract(contractAddress, contractABI, signer);

    console.log(`Updating progress for ${address}, Score: ${orbs}, Level: ${level}`);

    const tx = await contract.updateProgress(address, orbs, level);
    const receipt = await tx.wait();

    if (receipt.status === 0) {
      console.error("Transaction failed.");
      return res.status(500).json({ error: "Transaction failed" });
    }

    console.log(`✅ Score ${orbs} and level ${level} updated on-chain!`);

    return res.status(200).json({ message: "Progress updated successfully", txHash: tx.hash });
  } catch (error) {
    console.error("❌ Error updating score on-chain:", error);
    return res.status(500).json({ error: "Failed to update on-chain progress" });
  }
});


// ✅ Fetch player stats from the blockchain
app.get("/player/:address", async (req, res) => {
  const provider = new ethers.JsonRpcProvider(process.env.RPC_URL);
  const contract = new ethers.Contract(contractAddress, contractABI, provider);
  const address = req.params.address;

  try {
    // Correctly calling the 'getStats' function from the contract
    const [orbs, level] = await contract.getStats(address);

    // Convert BigNumber to string (if necessary) to avoid any issues with large numbers
    const orbsString = orbs?.toString() || "0";
    const levelString = level?.toString() || "0";

    // Send the player stats as JSON response
    res.json({ address, orbs: orbsString, level: levelString });
  } catch (e) {
    console.error("Error fetching player progress:", e);
    res.status(500).json({ error: "Could not fetch progress" });
  }
});


// ✅ Start the server
app.listen(port, () => {
  console.log(`Server is running at http://localhost:${port}`);
});

app.use((req, res, next) => {
  console.log("👉 Incoming Request:", req.method, req.url);
  next();
});

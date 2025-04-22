const { ethers } = require("ethers");
require("dotenv").config(); // Loads the .env variables

// Import ABI
const abi = require('./PlayerProgress.json'); // Adjust the path if needed

// Set up provider and signer from environment
const provider = new ethers.JsonRpcProvider(process.env.RPC_URL);
const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);

// Replace this with your actual deployed contract address
const contractAddress = process.env.CONTRACT_ADDRESS;

const contract = new ethers.Contract(contractAddress, abi, wallet);

module.exports = contract;

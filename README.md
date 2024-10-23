# Green-Blockchain-Ecosystem

## Overview

This repository contains smart contracts for a blockchain-based network designed for product ordering, last-mile delivery optimization, and confirmation. The network involves multiple stakeholders: customers, retailers, miners (optimizing delivery), and fleet carriers.

## Smart Contracts

The smart contracts are written in Solidity and cover the following phases:
1. **Ordering Product**: Contract between customer and retailer.
2. **Optimization**: Contract between retailer and miner to optimize last-mile delivery.
3. **Delivery**: Contract between retailer and fleet carrier to manage delivery.
4. **Confirmation**: Contract between customer, retailer, and fleet carrier to confirm delivery and handle disputes.

## Files

- **contracts/**
    - `OrderingContract.sol`: Product ordering and payment.
    - `OptimizationContract.sol`: Delivery optimization by miners.
    - `DeliveryContract.sol`: Delivery by fleet carriers.
    - `ConfirmationContract.sol`: Confirmation and dispute handling.
  
- **migrations/**
    - `deploy_and_interact.js`: Script for deploying and interacting with smart contracts.

## Prerequisites

- [Node.js](https://nodejs.org/)
- [Web3.js](https://web3js.readthedocs.io/)
- [Solidity Compiler (solc)](https://soliditylang.org/)

## Installation

1. Clone the repository:
    ```bash
    git clone https://github.com/your-username/blockchain-network.git
    cd blockchain-network
    ```

2. Install dependencies:
    ```bash
    npm install
    ```

3. Compile, deploy, and interact with contracts:
    ```bash
    npm start
    ```
    
## Running a Local Ethereum Network

To interact with the contracts, you'll need to run a local Ethereum blockchain node (e.g., Ganache) or connect to an external testnet like Rinkeby.

## License

This project is licensed under the MIT License.

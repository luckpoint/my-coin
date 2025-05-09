# My Coin DApp - Smart Contracts

This project contains the Hardhat environment and Solidity smart contracts for a simple Decentralized Application (DApp) called "TokenShop". The DApp allows users to acquire a custom ERC-20 token (`MyToken`) and use it to "purchase" virtual products from a `Shop` contract. This project is designed for learning purposes, demonstrating basic tokenomics and smart contract interactions.

This repository focuses on the **smart contract backend** and deployment scripts. A separate frontend application (e.g., using ethers.js and Bootstrap as described in `Spec.md`) would be required to interact with these contracts through a user interface.

## Table of Contents

- [My Coin DApp - Smart Contracts](#my-coin-dapp---smart-contracts)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Contracts](#contracts)
    - [`MyToken.sol`](#mytokensol)
    - [`Shop.sol`](#shopsol)
  - [Features](#features)
  - [Technology Stack](#technology-stack)
  - [Prerequisites](#prerequisites)
  - [Setup and Installation](#setup-and-installation)
  - [Environment Variables](#environment-variables)
  - [Deployment](#deployment)
    - [Local Hardhat Network](#local-hardhat-network)
    - [Sepolia Testnet](#sepolia-testnet)
  - [Core Workflow \& Usage (Interacting with Contracts)](#core-workflow--usage-interacting-with-contracts)
    - [1. Deploying Contracts](#1-deploying-contracts)
    - [2. MyToken Operations](#2-mytoken-operations)
    - [3. Shop Operations](#3-shop-operations)
  - [Scripts](#scripts)

## Overview

The TokenShop DApp consists of two main smart contracts:

*   **`MyToken.sol`**: An ERC-20 compliant token with additional features like a faucet and a system for the owner to allocate tokens to "child" addresses.
*   **`Shop.sol`**: A contract that lists products and allows users to purchase them using `MyToken`.

The primary learning objectives are to understand ERC-20 token mechanics, contract ownership, token approval/transfer flows, and basic DApp interactions.

## Contracts

### `MyToken.sol`

*   **Type**: ERC-20 Token, Ownable
*   **Symbol**: MUC (configurable at deployment)
*   **Name**: MyUserCoin (configurable at deployment)
*   **Decimals**: 18 (standard ERC20)
*   **Functionality**:
    *   Standard ERC20 functions (`transfer`, `balanceOf`, `approve`, `transferFrom`, etc.).
    *   An initial supply is minted to the contract deployer (owner) upon deployment.
    *   `faucet()`: Allows any user to claim a small, fixed amount of tokens (newly minted).
    *   `setPendingTokens(address child, uint256 amount)`: Owner can designate a certain amount of tokens for a specific "child" address.
    *   `claimMyTokens()`: A "child" address can claim the tokens previously set for them by the owner (newly minted).
    *   `getMyPendingTokens()`: Allows a user to check their pending token amount.

### `Shop.sol`

*   **Type**: Ownable
*   **Depends on**: `MyToken.sol` (address of `MyToken` is passed to the constructor)
*   **Functionality**:
    *   Manages a list of `Product` structs (id, name, price, isActive).
    *   The constructor initializes the shop with two sample products. Prices are set considering the token's decimals.
    *   `addProduct(string memory _name, uint256 _price)`: Owner can add new products.
    *   `getProduct(uint256 _productId)`: View product details.
    *   `updateProductPrice(uint256 _productId, uint256 _newPrice)`: Owner can update product prices.
    *   `purchaseProduct(uint256 _productId)`: Allows users to buy a product.
        *   **Requires prior approval**: The user must first `approve` the Shop contract to spend the required amount of `MyToken` on their behalf.
        *   Transfers `MyToken` from the buyer to the Shop contract.
    *   `withdrawTokens()`: Owner can withdraw all `MyToken` balance held by the Shop contract.

## Features

*   Deployment of a custom ERC-20 token (`MyToken`).
*   Deployment of a `Shop` contract that uses `MyToken` as its currency.
*   Faucet mechanism in `MyToken` for users to get free tokens.
*   Owner-controlled token allocation system in `MyToken` for "child" users.
*   Product management (add, update price) in `Shop` by the owner.
*   Product purchase flow involving ERC-20 `approve` and `transferFrom`.
*   Owner ability to withdraw accumulated tokens from the `Shop`.

## Technology Stack

*   **Solidity**: `^0.8.20` (specifically `0.8.28` in `hardhat.config.js`)
*   **Hardhat**: Ethereum development environment
*   **ethers.js**: For interacting with Ethereum (used by Hardhat tasks)
*   **OpenZeppelin Contracts**: For standard ERC20 and Ownable implementations
*   **dotenv**: For managing environment variables

## Prerequisites

*   Node.js (v18.x or later recommended)
*   npm or yarn
*   MetaMask browser extension (for interacting with a deployed DApp on a testnet/mainnet or a local GUI like Ganache)

## Setup and Installation

1.  **Clone the repository:**
    ```bash
    git clone <repository-url>
    cd hardhat-project
    ```

2.  **Install dependencies:**
    ```bash
    npm install
    ```
    or
    ```bash
    yarn install
    ```

## Environment Variables

You'll need to set up environment variables for deploying to testnets like Sepolia. Create a `.env` file in the root of the project:

```bash
cp .env.example .env
```

Then, edit `.env` with your specific values:

```
# .env

# RPC URL for the Sepolia testnet (e.g., from Infura, Alchemy)
SEPOLIA_RPC_URL="YOUR_SEPOLIA_RPC_URL"

# Private key of the account you want to use for deployment on Sepolia
# IMPORTANT: Do not commit this file with a real private key for a mainnet account holding actual value.
SEPOLIA_PRIVATE_KEY="YOUR_SEPOLIA_WALLET_PRIVATE_KEY"
```

**Note:** `SEPOLIA_RPC_URL` and `SEPOLIA_PRIVATE_KEY` are only required if you intend to deploy to the Sepolia testnet. For local Hardhat network deployment, they are not needed.

## Deployment

The `scripts/deploy.js` script handles the deployment of both `MyToken` and `Shop` contracts. It first deploys `MyToken` and then passes its address to the `Shop` contract's constructor.

### Local Hardhat Network

1.  **Start a local Hardhat node (optional, if you want a persistent local chain):**
    In one terminal:
    ```bash
    npx hardhat node
    ```
    This will start a local Ethereum node and provide you with several funded accounts.

2.  **Deploy contracts to the local Hardhat network:**
    In another terminal (or the same one if you didn't start `hardhat node`):
    ```bash
    npx hardhat run scripts/deploy.js --network localhost
    ```
    If you are not running a separate `npx hardhat node`, you can deploy directly to the default in-memory Hardhat Network:
    ```bash
    npx hardhat run scripts/deploy.js --network hardhat
    ```
    The script will output the addresses of the deployed `MyToken` and `Shop` contracts.

### Sepolia Testnet

Ensure your `.env` file is correctly configured with `SEPOLIA_RPC_URL` and `SEPOLIA_PRIVATE_KEY`, and your deployment account has Sepolia ETH for gas fees.

1.  **Deploy contracts to Sepolia:**
    ```bash
    npx hardhat run scripts/deploy.js --network sepolia
    ```
    The script will output the addresses of the deployed `MyToken` and `Shop` contracts on the Sepolia testnet.

## Core Workflow & Usage (Interacting with Contracts)

Once deployed (either locally or on a testnet), you would typically interact with these contracts via a frontend DApp or using Hardhat tasks/console. Here's a conceptual flow:

### 1. Deploying Contracts

*   The `deploy.js` script deploys `MyToken` first (e.g., "MyUserCoin", "MUC", with an initial supply of 1,000,000 tokens minted to the deployer/owner).
*   Then, it deploys `Shop`, providing the newly deployed `MyToken` address to its constructor.
*   The `Shop` constructor automatically adds two sample products ("SampleProductA", "SampleProductB") with prices calculated based on `MyToken`'s decimals.

### 2. MyToken Operations

*   **Getting Tokens (Faucet):** Any user can call `MyToken.faucet()` to receive 100 MUC (this amount is minted directly to the caller).
*   **Owner Allocating Tokens to Child:**
    1.  The owner of `MyToken` calls `MyToken.setPendingTokens(childAddress, amount)` to allocate tokens for `childAddress`.
    2.  The `childAddress` user then calls `MyToken.claimMyTokens()` to receive the allocated tokens (these are newly minted).
*   **Checking Balance:** Any user can check their MUC balance using `MyToken.balanceOf(userAddress)`.
*   **Standard ERC-20 Transfers:** Users can transfer MUC to each other using `MyToken.transfer(recipientAddress, amount)`.

### 3. Shop Operations

*   **Owner - Managing Products:**
    *   The owner of `Shop` can call `Shop.addProduct(name, priceInSmallestUnit)` to add new products.
    *   The owner can call `Shop.updateProductPrice(productId, newPriceInSmallestUnit)` to change a product's price.
*   **User - Purchasing a Product:**
    1.  **View Products:** A user would first view available products (e.g., using `Shop.getProduct(productId)` or a function that returns all active products).
    2.  **Approve Token Spending:** Before purchasing, the user *must* call `MyToken.approve(shopContractAddress, priceOfTheProduct)` to allow the `Shop` contract to withdraw the product's price from their MUC balance.
    3.  **Purchase:** After the `approve` transaction is confirmed, the user calls `Shop.purchaseProduct(productId)`. This transfers the MUC from the user to the `Shop` contract.
*   **Owner - Withdrawing Funds:**
    *   The owner of `Shop` can call `Shop.withdrawTokens()` to transfer all MUC held by the `Shop` contract to their own address.

## Scripts

*   **`scripts/deploy.js`**:
    *   Deploys the `MyToken` contract with a specified name, symbol, and initial supply for the owner.
    *   Deploys the `Shop` contract, passing the address of the deployed `MyToken` contract to its constructor.
    *   Logs the addresses of the deployed contracts.
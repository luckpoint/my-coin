```
## Application Design Proposal

### 1. Overview

* **Application Name:** (Example) TokenShop DApp
* **Purpose:** A learning web application to experience the process of obtaining ERC-20 tokens and using them to exchange for (hypothetical) physical asset products.
* **Key Features:**
    1.  Connection with an Ethereum wallet (MetaMask).
    2.  Acquisition of custom ERC-20 tokens from a smart contract (Faucet function).
    3.  Display of custom token balance.
    4.  Display of a product list (product name, price).
    5.  Product purchase process using custom tokens.
* **Target Users:** Beginners in blockchain and DApp development.

### 2. System Architecture

* **Frontend:**
    * **Frameworks/Libraries:** Bootstrap 5 (UI design), JavaScript (Logic)
    * **Ethereum Integration:** ether.js
    * **Role:** Provides the user interface, interacts with the wallet, executes read and write operations on smart contracts.
* **Smart Contracts (on Ethereum):**
    * **Language:** Solidity
    * **Contract 1: `MyToken.sol` (ERC-20 compliant token)**
        * Issuance and management of custom tokens.
        * Faucet function (allows users to get test tokens).
    * **Contract 2: `Shop.sol` (Product exchange contract)**
        * A list of products (simple).
        * Product purchase process using tokens.
* **Blockchain Network:**
    * Local environments (Ganache, Hardhat Network, etc.) are recommended for development and testing.
    * Can be deployed to a testnet (Sepolia, Goerli, etc.) in the future.
* **Backend:**
    * **Principally unnecessary** for a learning application. Product information will be hardcoded in the smart contract or frontend. Management of physical asset shipping and detailed order management are outside the scope.

### 3. Frontend Design (Bootstrap, ether.js)

* **Screen Structure (assuming Single Page Application):**
    * **Header:**
        * Application name
        * Wallet connect/disconnect button
        * Display of the connected account address
        * Display of the current network
    * **Main Content:**
        * **Section 1: Token Management**
            * Display of token name and symbol
            * Display of user's token balance
            * "Get Tokens" button (calls the Faucet function)
        * **Section 2: Product List**
            * Display each product in a card format (using Bootstrap Card component)
                * Product image (a dummy image is acceptable)
                * Product name
                * Price (in custom tokens)
                * "Purchase" button
        * **Section 3: Transaction Information**
            * Simple display of the status of executed transactions (e.g., Pending, Success, Failed)
* **Key JavaScript (ether.js) Functions:**
    * **Wallet Integration (modularized in `wallet.js`, etc.):**
        * Detects providers like MetaMask.
        * Requests connection to accounts (`provider.send("eth_requestAccounts", [])`).
        * Obtains the Signer (`provider.getSigner()`).
        * Sets up event listeners for network and account changes.
    * **ERC-20 Token Operations (in `myTokenService.js`, etc.):**
        * Holds the ABI and contract address of `MyToken.sol`.
        * Creates a contract instance using `ethers.Contract`.
        * Get balance: `contract.balanceOf(userAddress)`.
        * Call Faucet function: `contract.connect(signer).faucet()` (hypothetical function name).
    * **Product Purchase Operations (in `shopService.js`, etc.):**
        * Holds the ABI and contract address of `Shop.sol`.
        * Creates a contract instance using `ethers.Contract`.
        * Get product list (if retrieved from the contract): `contract.getProducts()` (hypothetical function name).
        * Purchase process:
            1.  Token approval: `myTokenContract.connect(signer).approve(shopContractAddress, price)`.
            2.  Product purchase: `shopContract.connect(signer).purchaseProduct(productId)` (hypothetical function name).
    * **UI Updates:**
        * Reflect acquired information (balance, product list, etc.) in the HTML.
        * Provide user feedback according to transaction progress.

### 4. Smart Contract Design (Solidity)

#### 4.1. `MyToken.sol` (ERC-20 Compliant Token)

(Details to be added)

#### 4.2. `Shop.sol` (Product Exchange Contract)

(Details to be added)

### 5. Key User Stories/Flows

Roles:
* **Administrator (Parent):** Role is to distribute tokens to children. Cannot purchase products.
* **Child:** Role is to receive tokens from the administrator and purchase products.

1.  **Common: User (Administrator or Child) Connects Wallet:**
    * Open the app → Click the "Connect Wallet" button → MetaMask launches and requests connection → User approves → Account address and network are displayed in the app.
    * The app identifies whether the connected account is an administrator or a child (identification method to be defined separately, e.g., a list of addresses registered in the contract).

2.  **Administrator: Sends Tokens to a Child Account:**
    * Connect wallet as an administrator.
    * In the token management screen (or a dedicated sending screen), enter the child's wallet address to send to and the amount of tokens to send.
    * Click the "Send" button.
    * MetaMask requests approval for the token transfer transaction (assuming the `transfer` function of `MyToken.sol`).
    * Administrator approves → Transaction succeeds.
    * The child's token balance increases, and the administrator's token balance decreases. This can be confirmed in the app.

3.  **Child: Checks Token Balance:**
    * Connect wallet as a child.
    * Check their token balance on the token management screen. Confirm that the tokens sent from the administrator are reflected.
    * (Note: The traditional Faucet function is discontinued, or modified so that only the administrator Mints initial tokens and distributes them to children).

4.  **Child: Purchases a Product:**
    * Connect wallet as a child.
    * Select the desired product from the "Product List" → Click the "Purchase" button.
    * **Step 1: Approve (First time or insufficient allowance):**
        * The app prompts for approval to spend the required amount of tokens by the Shop contract (using the `approve` function of `MyToken.sol`).
        * MetaMask requests approval for the `approve` transaction → Child approves → Transaction succeeds.
    * **Step 2: Purchase:**
        * (After Approval) The app calls the `purchaseProduct` function of `Shop.sol` (assuming a purchase function specifically for children).
        * MetaMask requests approval for the `purchaseProduct` transaction → Child approves → Transaction succeeds.
        * The child's token balance decreases, and the Shop contract's token balance increases (or the tokens are burned).
        * Display a message in the app such as "Purchase completed."
        * (As a real-world process) An off-chain system monitors for `ProductPurchased` events and starts preparing for product shipping (this part is outside the app's scope).

5.  **Administrator: Views Product List (Cannot Purchase):**
    * Connect wallet as an administrator.
    * Can view the product list, but the "Purchase" button is hidden or disabled.
    * The `Shop.sol` purchase function implements control (e.g., `modifier onlyChild`) to only allow calls from child accounts.

### 6. Suggested Development Steps

1.  **Environment Setup:** Install Node.js, npm/yarn, Hardhat (for smart contract development).
2.  **Smart Contract Development:** Create and compile `MyToken.sol` and `Shop.sol`, and deploy them to a local network (e.g., Hardhat Network).
3.  **Frontend Basic Structure:** Create the basic layout using HTML with Bootstrap.
4.  **Wallet Connection Functionality Implementation:** Implement the connection functionality with MetaMask using ether.js.
5.  **Token Acquisition Functionality Implementation:** Implement the UI and logic to call the Faucet function of the deployed `MyToken` contract. Implement balance display as well.
6.  **Product Display Functionality Implementation:** Implement the UI to retrieve (from `Shop.sol` or hardcoded) and display product information.
7.  **Product Purchase Functionality Implementation:** Implement the UI and logic to call `approve` and `purchaseProduct`. Implement feedback display for transactions.
8.  **Testing and Debugging:** Test each function and fix issues.

### 7. Considerations (for Learning Purposes)

* **Error Handling:** Implement basic error handling for ether.js calls and transaction failures (e.g., `try...catch`, user notifications).
* **Security:** Since this is for learning, advanced security measures (detailed reentrancy guards, etc.) are simplified, but it is important to correctly understand the mechanism of `approve` and the behavior of `transferFrom`.
* **Gas Fees:** This is less of a concern on local or testnets, but be aware that gas optimization becomes important on the actual mainnet.
* **UI/UX:** While Bootstrap provides a basic appearance, it is important to clearly communicate status changes (loading, success, failure, etc.) to the user for ease of operation.
```
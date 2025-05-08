// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title MyToken
 * @dev This contract implements a custom ERC20 token with additional features
 * for learning and demonstration purposes.
 *
 * Key functionalities include:
 * 1. Standard ERC20 token features (transfer, balanceOf, etc.).
 * 2. Ownership control, where certain actions are restricted to the owner.
 * 3. An initial supply of tokens can be minted to the contract deployer (owner).
 * 4. A public faucet function (`faucet`) that allows any user to claim a small,
 * fixed amount of tokens by minting them.
 * 5. A system for the owner to allocate tokens to specific "child" addresses
 * (`setPendingTokens`), which these children can then claim for themselves (`claimMyTokens`).
 * The pending amounts are tracked, and claimed tokens are newly minted.
 *
 * This contract demonstrates token creation, access control, and custom minting logic.
 */
contract MyToken is ERC20, Ownable {
    // --- State Variables ---
    mapping(address => uint256) public pendingTokensForChild;

    // --- Events ---
    event TokensPendingForChild(address indexed child, uint256 amountPrepared, uint256 newTotalPending);
    event TokensClaimedByChild(address indexed child, uint256 amountClaimed);
    event FaucetFunded(address indexed funder, uint256 amount); // For Faucet (might already exist)
    event FaucetTokensTaken(address indexed recipient, uint256 amount); // For Faucet (might already exist)

    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupplyToOwner // Initial supply to the owner (used for Faucet, etc.)
    ) ERC20(name, symbol) Ownable(msg.sender) { // Set the initial owner for Ownable
        if (initialSupplyToOwner > 0) {
            _mint(msg.sender, initialSupplyToOwner * (10**decimals()));
        }
    }

    /**
     * @dev Faucet function for learning purposes: Anyone can get a small amount of tokens.
     * Tokens need to have been sent (minted) to this contract beforehand.
     * Note: This is for learning purposes, so rate limiting (usage restrictions, etc.) is omitted.
     */
    function faucet() external {
        uint256 faucetAmount = 100 * (10**decimals()); // Amount obtainable at one time (e.g., 100 tokens)
        // require(balanceOf(address(this)) >= faucetAmount, "MyToken: Faucet is empty or low on funds");
        // _transfer(address(this), msg.sender, faucetAmount);
        // The above is for when the contract holds tokens. Minting directly is simpler here.
        _mint(msg.sender, faucetAmount);
        emit FaucetTokensTaken(msg.sender, faucetAmount);
    }

    /**
     * @dev (Optional) The owner mints tokens to this contract for the Faucet.
     * If the faucet function mints directly, this function is not essential,
     * but it can be used if you want the contract address to have an initial supply.
     */
    function fundFaucetSupply(uint256 amount) external onlyOwner {
        _mint(address(this), amount); // Mint to the contract itself
        emit FaucetFunded(msg.sender, amount);
    }

    /**
     * @dev The administrator (owner of this token contract) prepares to grant tokens
     * to a specified child address. The amount is added to any existing pending balance.
     * @param child The address of the child who will receive tokens.
     * @param amount The amount of tokens to prepare (in the smallest unit. For example, if decimals is 18, to grant 1 token, specify 1 * 10**18).
     */
    function setPendingTokens(address child, uint256 amount) external onlyOwner {
        require(child != address(0), "MyToken: Cannot set pending tokens for the zero address");
        require(amount > 0, "MyToken: Amount must be greater than zero");

        pendingTokensForChild[child] += amount;
        emit TokensPendingForChild(child, amount, pendingTokensForChild[child]);
    }

    /**
     * @dev The child user claims the tokens pending for their address.
     * On success, the pending balance is reset, and tokens are minted to the child.
     */
    function claimMyTokens() external {
        uint256 amountToClaim = pendingTokensForChild[msg.sender];
        require(amountToClaim > 0, "MyToken: You have no tokens pending to claim");

        pendingTokensForChild[msg.sender] = 0; // Update state first (re-entrancy guard)
        _mint(msg.sender, amountToClaim);      // Mint new tokens and grant them

        emit TokensClaimedByChild(msg.sender, amountToClaim);
    }

    /**
     * @dev The calling user (child) can check the amount of tokens currently pending for them.
     * @return uint256 The amount of pending tokens.
     */
    function getMyPendingTokens() external view returns (uint256) {
        return pendingTokensForChild[msg.sender];
    }

    // ERC20 decimals defaults to 18, but it could be made configurable in the constructor.
    // function decimals() public view virtual override returns (uint8) {
    //     return 18;
    // }
}

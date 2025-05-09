// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol"; // For debugging, can be removed for production

contract Shop is Ownable {
    IERC20Metadata public immutable token; // The ERC20 token (with metadata) used in this shop

    struct Product {
        uint256 id;
        string name;
        uint256 price; // Price in token's smallest unit
        bool isActive; // Is the product available for purchase?
    }

    mapping(uint256 => Product) public products;
    uint256 public nextProductId;

    event ProductAdded(uint256 id, string name, uint256 price);
    event ProductPurchased(address indexed buyer, uint256 indexed productId, uint256 price);
    event TokensWithdrawn(address indexed owner, uint256 amount);
    event ProductPriceUpdated(uint256 indexed productId, uint256 newPrice);

    constructor(address tokenAddress) Ownable(msg.sender) {
        require(tokenAddress != address(0), "Shop: Token address cannot be zero");
        token = IERC20Metadata(tokenAddress);

        _addProduct("SampleProductA", 10 * (10**token.decimals()));
        _addProduct("SampleProductB", 50 * (10**token.decimals()));
    }

    function addProduct(string memory _name, uint256 _price) external onlyOwner {
        _addProduct(_name, _price);
    }

    function _addProduct(string memory _name, uint256 _price) internal {
        require(bytes(_name).length > 0, "Shop: Product name cannot be empty");
        require(_price > 0, "Shop: Product price must be greater than zero");

        products[nextProductId] = Product(nextProductId, _name, _price, true);
        emit ProductAdded(nextProductId, _name, _price);
        nextProductId++;
    }

    function getProduct(uint256 _productId) external view returns (uint256 id, string memory name, uint256 price, bool isActive) {
        Product storage product = products[_productId];
        return (product.id, product.name, product.price, product.isActive);
    }

    function updateProductPrice(uint256 _productId, uint256 _newPrice) external onlyOwner {
        require(products[_productId].id == _productId || (products[_productId].id == 0 && _productId == 0), "Shop: Product does not exist"); // Check if product exists
        require(_newPrice > 0, "Shop: Product price must be greater than zero");

        products[_productId].price = _newPrice;
        emit ProductPriceUpdated(_productId, _newPrice);
    }

    function purchaseProduct(uint256 _productId) external {
        Product storage product = products[_productId];
        require(product.isActive, "Product is not available");
        require(product.price > 0, "Product price must be valid");

        // --- "Approach: Approve just before purchase" ---
        // The DApp/client interacting with this Shop contract is responsible for
        // ensuring that the user (msg.sender) has approved this Shop contract
        // to spend at least `product.price` of the specified ERC20 token.
        // This typically involves the following client-side steps before calling `purchaseProduct`:
        // 1. User indicates intent to purchase.
        // 2. Client checks `token.allowance(userAddress, address(this))`.
        // 3. If allowance is less than `product.price`, client prompts user to call
        //    `token.approve(address(this), product.price)` (or a sufficient amount).
        // 4. After the `approve` transaction succeeds, client calls this `purchaseProduct` function.
        //
        // This function (`purchaseProduct`) only validates that sufficient allowance
        // has ALREADY been granted by the user to this Shop contract.
        uint256 currentAllowance = token.allowance(msg.sender, address(this));
        console.log("currentAllowance", currentAllowance, "price", product.price); // For debugging
        require(currentAllowance >= product.price, "Shop: Insufficient token allowance. User must approve tokens for the Shop before purchasing.");

        // State changes before external call (re-entrancy guard example)
        // if (product.isSinglePurchase) { product.isActive = false; }

        token.transferFrom(msg.sender, address(this), product.price);

        emit ProductPurchased(msg.sender, _productId, product.price);
    }

    /**
     * @dev Allows the owner to withdraw tokens stored in this contract.
     */
    function withdrawTokens() external onlyOwner {
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, "Shop: No tokens to withdraw");

        bool success = token.transfer(owner(), balance);
        require(success, "Shop: Token withdrawal failed");

        emit TokensWithdrawn(owner(), balance);
    }
}

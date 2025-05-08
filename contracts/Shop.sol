// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/access/Ownable.sol"; // 商品追加の管理用

contract Shop is Ownable {
    IERC20 public immutable token; // 使用するERC20トークン

    struct Product {
        uint256 id;
        string name;
        uint256 price; // トークン建ての価格
        bool isActive; // 商品が購入可能か
    }

    mapping(uint256 => Product) public products;
    uint256 public nextProductId;

    event ProductAdded(uint256 id, string name, uint256 price);
    event ProductPurchased(address indexed buyer, uint256 indexed productId, uint256 price);

    constructor(address tokenAddress) Ownable(msg.sender) {
        token = IERC20Metadata(tokenAddress);
        // 学習用に初期商品をいくつか登録
        _addProduct("SampleProductA", 10 * (10**token.decimals())); // 例: 10トークン (decimalsを考慮)
        _addProduct("SampleProductB", 50 * (10**token.decimals())); // 例: 50トークン
    }

    // オーナーが商品を追加する (学習用なので簡易的に)
    function addProduct(string memory _name, uint256 _price) external onlyOwner {
       _addProduct(_name, _price);
    }

    function _addProduct(string memory _name, uint256 _price) internal {
        products[nextProductId] = Product(nextProductId, _name, _price, true);
        emit ProductAdded(nextProductId, _name, _price);
        nextProductId++;
    }

    // 商品情報を取得するビュー関数 (フロントエンドが商品リストを表示するため)
    // 全商品を取得するのはガス効率が悪い場合があるため、ID指定やページネーションを検討するが、今回はシンプルに
    function getProduct(uint256 _productId) external view returns (uint256 id, string memory name, uint256 price, bool isActive) {
        Product storage product = products[_productId];
        return (product.id, product.name, product.price, product.isActive);
    }

    function purchaseProduct(uint256 _productId) external {
        Product storage product = products[_productId];
        require(product.isActive, "Product is not available");
        require(product.price > 0, "Product price must be greater than 0"); // 念のため

        uint256 currentAllowance = token.allowance(msg.sender, address(this));
        require(currentAllowance >= product.price, "Check token allowance");

        // トークンをユーザーからこのコントラクトへ転送
        // require(token.transferFrom(msg.sender, address(this), product.price), "Token transfer failed");
        // transferFromの戻り値はboolではない場合もあるので注意（OpenZeppelinはvoid）
        // エラー時はrevertするので、戻り値チェックは不要なことが多い
        token.transferFrom(msg.sender, address(this), product.price);

        // (実物資産の処理はこのスコープ外。イベントを発行してオフチェーンで検知・処理)
        emit ProductPurchased(msg.sender, _productId, product.price);

        // (任意) 購入されたら商品を非アクティブにするなど
        // product.isActive = false;
    }
}

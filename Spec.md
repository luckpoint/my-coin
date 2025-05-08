## アプリケーション設計案

### 1. 概要

* **アプリケーション名:** (例) TokenShop DApp
* **目的:** ERC-20トークンを取得し、そのトークンを使用して（架空の）実物資産商品と交換するプロセスを体験する学習用ウェブアプリケーション。
* **主要機能:**
    1.  Ethereumウォレット (MetaMask) との接続。
    2.  スマートコントラクトからの独自ERC-20トークンの取得 (Faucet機能)。
    3.  独自トークン残高の表示。
    4.  商品リストの表示（商品名、価格）。
    5.  独自トークンを使用した商品の購入処理。
* **ターゲットユーザー:** ブロックチェーンおよびDApp開発初学者。

### 2. システムアーキテクチャ

* **フロントエンド:**
    * **フレームワーク/ライブラリ:** Bootstrap 5 (UIデザイン), JavaScript (ロジック)
    * **Ethereum連携:** ether.js
    * **役割:** ユーザーインターフェースの提供、ウォレットとの連携、スマートコントラクトの読み取りと書き込み操作の実行。
* **スマートコントラクト (Ethereum上):**
    * **言語:** Solidity
    * **コントラクト1: `MyToken.sol` (ERC-20準拠トークン)**
        * 独自トークンの発行、管理。
        * Faucet機能（ユーザーがテスト用トークンを取得できる）。
    * **コントラクト2: `Shop.sol` (商品交換コントラクト)**
        * 商品のリスト（簡易的なもの）。
        * トークンでの商品購入処理。
* **ブロックチェーンネットワーク:**
    * 開発・テスト時はローカル環境 (Ganache, Hardhat Networkなど) を推奨。
    * 将来的にはテストネット (Sepolia, Goerliなど) にデプロイ可能。
* **バックエンド:**
    * 学習用のため、**原則不要**。商品情報はスマートコントラクトまたはフロントエンドにハードコードします。実物資産の発送管理や詳細な注文管理はスコープ外とします。

### 3. フロントエンド設計 (Bootstrap, ether.js)

* **画面構成 (シングルページアプリケーションを想定):**
    * **ヘッダー:**
        * アプリケーション名
        * ウォレット接続/切断ボタン
        * 接続中のアカウントアドレス表示
        * 現在のネットワーク表示
    * **メインコンテンツ:**
        * **セクション1: トークン管理**
            * トークン名、シンボル表示
            * 自分のトークン残高表示
            * 「トークンを取得する」ボタン (Faucet機能呼び出し)
        * **セクション2: 商品リスト**
            * 各商品をカード形式で表示 (Bootstrap Cardコンポーネント利用)
                * 商品画像 (ダミー画像で可)
                * 商品名
                * 価格 (独自トークン建て)
                * 「購入する」ボタン
        * **セクション3: トランザクション情報**
            * 実行したトランザクションのステータス（例: 承認待ち、成功、失敗）を簡易表示
* **主要なJavaScript (ether.js) 機能:**
    * **ウォレット連携 (`wallet.js` などにモジュール化):**
        * MetaMaskなどのプロバイダの検出。
        * アカウントへの接続要求 (`provider.send("eth_requestAccounts", [])`)。
        * 署名者 (Signer) の取得 (`provider.getSigner()`)。
        * ネットワーク変更、アカウント変更のイベントリスナー設定。
    * **ERC-20トークン操作 (`myTokenService.js` など):**
        * `MyToken.sol` のABIとコントラクトアドレスを保持。
        * `ethers.Contract` を使用してコントラクトインスタンスを作成。
        * 残高取得: `contract.balanceOf(userAddress)`。
        * Faucet機能呼び出し: `contract.connect(signer).faucet()` (仮の関数名)。
    * **商品購入操作 (`shopService.js` など):**
        * `Shop.sol` のABIとコントラクトアドレスを保持。
        * `ethers.Contract` を使用してコントラクトインスタンスを作成。
        * 商品リスト取得 (もしコントラクトから取得する場合): `contract.getProducts()` (仮の関数名)。
        * 購入処理:
            1.  トークン利用許可: `myTokenContract.connect(signer).approve(shopContractAddress, price)`。
            2.  商品購入: `shopContract.connect(signer).purchaseProduct(productId)` (仮の関数名)。
    * **UI更新:**
        * 取得した情報 (残高、商品リストなど) をHTMLに反映。
        * トランザクションの進捗に応じてユーザーにフィードバック。

### 4. スマートコントラクト設計 (Solidity)

#### 4.1. `MyToken.sol` (ERC-20準拠トークン)

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol"; // Faucetの管理用（任意）

contract MyToken is ERC20, Ownable {
    constructor(string memory name, string memory symbol, uint256 initialSupply) ERC20(name, symbol) {
        // 初期供給量をデプロイ者にミントする (任意)
        if (initialSupply > 0) {
            _mint(msg.sender, initialSupply * (10**decimals()));
        }
    }

    // 学習用のFaucet機能: 誰でも少量のトークンを取得可能
    function faucet() external {
        // 1回に取得できる量 (例: 100トークン)
        // 頻度制限などを入れる場合はより複雑になるが、今回はシンプルに
        require(balanceOf(address(this)) >= 100 * (10**decimals()), "Faucet is empty"); // コントラクトがトークンを持っているか
        _transfer(address(this), msg.sender, 100 * (10**decimals())); // もしコントラクトがトークンを保持している場合
        // もしくは、mintで新規発行する形でも良い (その場合はOwnableである必要性は薄れるかも)
        // _mint(msg.sender, 100 * (10**decimals()));
    }

    // Faucetにトークンを供給する関数 (オーナーのみ)
    // Faucetをmintで実装する場合は不要
    function fundFaucet(uint256 amount) external onlyOwner {
        _mint(address(this), amount);
    }
}
```

* **備考:** OpenZeppelinのERC20実装を継承することで、標準機能は網羅されます。`faucet()`関数は、呼び出し元に一定量のトークンを送付します。Faucetのトークン供給源として、コントラクト自体がトークンを保持する（デプロイ時や`fundFaucet`で供給）か、`faucet`関数内で直接`_mint`するかを選択できます。

#### 4.2. `Shop.sol` (商品交換コントラクト)

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
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

    constructor(address tokenAddress) {
        token = IERC20(tokenAddress);
        // 学習用に初期商品をいくつか登録
        _addProduct("学習用商品A", 10 * (10**token.decimals())); // 例: 10トークン (decimalsを考慮)
        _addProduct("学習用商品B", 50 * (10**token.decimals())); // 例: 50トークン
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
```

* **備考:** 商品情報はコントラクト内に`struct`と`mapping`で保持します。`purchaseProduct`関数は、ユーザーが事前にShopコントラクトに対してトークンの使用を`approve`していることを前提とします。購入が成功すると`ProductPurchased`イベントが発行されます。

### 5. 主要なユーザーストーリー/フロー

1.  **ユーザーがウォレットを接続する:**
    * アプリを開く → 「ウォレット接続」ボタンをクリック → MetaMaskが起動し接続を要求 → ユーザーが承認 → アカウントアドレスとネットワークがアプリに表示される。
2.  **ユーザーが独自トークンを取得する:**
    * 「トークン管理」セクションの「トークンを取得する」ボタンをクリック → MetaMaskがトランザクション（Faucet関数の呼び出し）の承認を要求 → ユーザーが承認 → トランザクションが成功 → ユーザーのトークン残高が増加し、アプリに反映される。
3.  **ユーザーが商品を購入する:**
    * 「商品リスト」から欲しい商品を選ぶ → 「購入する」ボタンをクリック。
    * **Step 1: Approve (初回または上限不足時):**
        * アプリがShopコントラクトに必要な額のトークン使用許可（`approve`）を促す。
        * MetaMaskが`approve`トランザクションの承認を要求 → ユーザーが承認 → トランザクション成功。
    * **Step 2: Purchase:**
        * （Approve後）アプリが`purchaseProduct`関数を呼び出す。
        * MetaMaskが`purchaseProduct`トランザクションの承認を要求 → ユーザーが承認 → トランザクション成功。
        * ユーザーのトークン残高が減少し、Shopコントラクトのトークン残高が増加。
        * アプリに「購入処理が完了しました」などのメッセージを表示。
        * （実世界の処理として）オフチェーンシステムが`ProductPurchased`イベントを監視し、商品の発送準備を開始する（この部分はアプリのスコープ外）。

### 6. 開発ステップの提案

1.  **環境構築:** Node.js, npm/yarn, Hardhat/Truffle (スマートコントラクト開発用) をインストール。
2.  **スマートコントラクト開発:** `MyToken.sol` と `Shop.sol` を作成・コンパイルし、ローカルネットワーク (例: Hardhat Network) にデプロイ。
3.  **フロントエンド基礎構築:** HTMLで基本的なレイアウトをBootstrapで作成。
4.  **ウォレット接続機能実装:** ether.jsを使ってMetaMaskとの接続機能を実装。
5.  **トークン取得機能実装:** デプロイした`MyToken`コントラクトのFaucet機能を呼び出すUIとロジックを実装。残高表示も実装。
6.  **商品表示機能実装:** `Shop.sol` から（またはハードコードで）商品情報を取得し、表示するUIを実装。
7.  **商品購入機能実装:** `approve`と`purchaseProduct`を呼び出すUIとロジックを実装。トランザクションのフィードバック表示も実装。
8.  **テストとデバッグ:** 各機能をテストし、問題を修正。

### 7. 考慮事項（学習用として）

* **エラーハンドリング:** ether.jsの呼び出しやトランザクションの失敗など、基本的なエラーハンドリングを実装する（例: `try...catch`、ユーザーへの通知）。
* **セキュリティ:** 学習用なので高度なセキュリティ対策（リエントランシーガードの詳細な実装など）は簡略化しますが、`approve`の仕組みや`transferFrom`の動作は正しく理解することが重要です。
* **ガス代:** ローカルやテストネットではあまり気になりませんが、実際のメインネットではガス代最適化も重要になることを意識しておくと良いでしょう。
* **UI/UX:** Bootstrapで基本的な見た目は整いますが、ユーザーが操作しやすいように、状態変化（ローディング中、成功、失敗など）を明確に伝えることが大切です。

この設計案が、学習用アプリケーション開発の一助となれば幸いです。

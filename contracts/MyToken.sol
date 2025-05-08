// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol"; // Ownable2Stepにすることも検討

contract MyToken is ERC20, Ownable {
    // --- 状態変数 ---
    mapping(address => uint256) public pendingTokensForChild;

    // --- イベント ---
    event TokensPendingForChild(address indexed child, uint256 amountPrepared, uint256 newTotalPending);
    event TokensClaimedByChild(address indexed child, uint256 amountClaimed);
    event FaucetFunded(address indexed funder, uint256 amount); // Faucet用 (既存の可能性あり)
    event FaucetTokensTaken(address indexed recipient, uint256 amount); // Faucet用 (既存の可能性あり)

    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupplyToOwner // オーナーへの初期供給量 (Faucetなどに使用)
    ) ERC20(name, symbol) Ownable(msg.sender) { // Ownableの初期オーナーを設定
        if (initialSupplyToOwner > 0) {
            _mint(msg.sender, initialSupplyToOwner * (10**decimals()));
        }
    }

    /**
     * @dev 学習用のFaucet機能: 誰でも少量のトークンを取得可能。
     * このコントラクトに事前にトークンが送られている（ミントされている）必要がある。
     */
    function faucet() external {
        uint256 faucetAmount = 100 * (10**decimals()); // 1回に取得できる量 (例: 100トークン)
        // require(balanceOf(address(this)) >= faucetAmount, "MyToken: Faucet is empty or low on funds");
        // _transfer(address(this), msg.sender, faucetAmount);
        // 上記はコントラクトがトークンを保持している場合。ここでは直接ミントする方がシンプル。
        _mint(msg.sender, faucetAmount);
        emit FaucetTokensTaken(msg.sender, faucetAmount);
    }

    /**
     * @dev (オプション) オーナーがFaucet用のトークンをこのコントラクトにミントする。
     * faucet関数が直接ミントする場合、この関数は必須ではないが、
     * コントラクトアドレスに初期供給を持たせたい場合に利用。
     */
    function fundFaucetSupply(uint256 amount) external onlyOwner {
        _mint(address(this), amount); // コントラクト自体にミント
        emit FaucetFunded(msg.sender, amount);
    }

    /**
     * @dev 管理者（このトークンコントラクトのオーナー）が、指定した子どもアドレスに対して
     * トークンを付与する準備をする。既存の保留額に加算される。
     * @param child トークンを受け取る子どものアドレス。
     * @param amount 付与準備するトークンの量 (最小単位ではない、例: 1トークンなら 1 * 10**decimals)。
     */
    function setPendingTokens(address child, uint256 amount) external onlyOwner {
        require(child != address(0), "MyToken: Cannot set pending tokens for the zero address");
        require(amount > 0, "MyToken: Amount must be greater than zero");

        pendingTokensForChild[child] += amount;
        emit TokensPendingForChild(child, amount, pendingTokensForChild[child]);
    }

    /**
     * @dev 子どもユーザーが、自身のアドレスに保留されているトークンを受け取る。
     * 成功すると、保留額はリセットされ、トークンが子どもにミントされる。
     */
    function claimMyTokens() external {
        uint256 amountToClaim = pendingTokensForChild[msg.sender];
        require(amountToClaim > 0, "MyToken: You have no tokens pending to claim");

        pendingTokensForChild[msg.sender] = 0; // 先に状態を更新（リエントランシー対策）
        _mint(msg.sender, amountToClaim); // 新しくトークンをミントして付与

        emit TokensClaimedByChild(msg.sender, amountToClaim);
    }

    /**
     * @dev 呼び出し元ユーザー（子ども）が、現在自身に保留されているトークン額を確認できる。
     * @return uint256 保留されているトークンの量。
     */
    function getMyPendingTokens() external view returns (uint256) {
        return pendingTokensForChild[msg.sender];
    }

    // ERC20のdecimalsはデフォルトで18だが、コンストラクタで設定できるようにしても良い
    // function decimals() public view virtual override returns (uint8) {
    //     return 18;
    // }
}


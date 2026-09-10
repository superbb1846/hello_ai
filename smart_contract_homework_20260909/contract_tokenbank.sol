
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 导入 OpenZeppelin 的 IERC20 接口，用于与 ABBA 代币进行安全交互
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenBank {
    // 记录 ABBA 代币的合约实例
    IERC20 public immutable abbaToken;

    // 1. 记录每个 EOA 用户存入的 token 数量
    mapping(address => uint256) public balances;

    // 存款事件，方便前端监听
    event Deposited(address indexed user, uint256 amount);
    // 提款事件
    event Withdrawn(address indexed user, uint256 amount);

    /**
     * @dev 构造函数，初始化时传入 ABBA 代币的合约地址
     * @param _abbaTokenAddress ABBA 代币在区块链上的地址
     */
    constructor(address _abbaTokenAddress) {
        require(_abbaTokenAddress != address(0), "Invalid token address");
        abbaToken = IERC20(_abbaTokenAddress);
    }

    /**
     * @dev 存款函数
     * @param amount 要存入的代币数量（注意：需要包含精度，例如 1个ABBA通常是 10**18）
     */
    function deposit(uint256 amount) external {
        require(amount > 0, "Cannot deposit 0");
        
        // 将代币从用户钱包转移到本合约
        // 注意：用户在调用此函数前，必须先对 TokenBank 合约进行 approve 授权
        require(abbaToken.transferFrom(msg.sender, address(this), amount), "Deposit failed");
        
        // 更新用户的存款记录
        balances[msg.sender] += amount;
        
        emit Deposited(msg.sender, amount);
    }

    /**
     * @dev 提款函数
     * @param amount 要提取的代币数量
     */
    function withdraw(uint256 amount) external {
        require(amount > 0, "Cannot withdraw 0");
        require(balances[msg.sender] >= amount, "Insufficient balance in bank");
        
        // 先扣减用户的存款记录（遵循 Checks-Effects-Interactions 模式，防止重入攻击）
        balances[msg.sender] -= amount;
        
        // 将代币从本合约转回给用户
        require(abbaToken.transfer(msg.sender, amount), "Withdraw failed");
        
        emit Withdrawn(msg.sender, amount);
    }

    /**
     * @dev 查询用户在银行中的存款余额
     * @param user 用户的地址
     * @return 用户的存款数量
     */
    function getBalance(address user) external view returns (uint256) {
        return balances[user];
    }
}

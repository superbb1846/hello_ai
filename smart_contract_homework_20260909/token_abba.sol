
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 导入 OpenZeppelin 的 ERC20 基础合约
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ABBA is ERC20 {
    /**
     * @dev 构造函数：初始化代币的名称、符号以及初始供应量
     * @param initialSupply 初始发行的代币数量（包含精度）
     */
    constructor(uint256 initialSupply) ERC20("ABBA", "ABBA") {
        // 将初始代币全部铸造给部署该合约的账户
        // 这里假设精度为默认的18位，所以乘以 10**18
        _mint(msg.sender, initialSupply * 10 ** decimals());
    }
}

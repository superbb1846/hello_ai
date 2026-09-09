// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract bank_demo {
    // 1. 记录每个 EOA 账户的存款金额
    mapping(address => uint256) public balances;
    
    // 2. 记录存款金额前3名的 EOA 账户地址
    address[3] public topThree;
    
    // 3. 记录管理员地址
    address public admin;
    
    // 4. 管理员权限修饰器
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can withdraw");
        _;
    }
    
    // 构造函数：部署合约时设置管理员
    constructor() {
        admin = msg.sender;
    }
    
    // 5. 存款函数：通过 Metamask 主动调用 deposit() 存款
    function deposit() public payable {
        require(msg.value > 0, "Deposit amount must be greater than 0");
        
        // 更新用户的存款余额
        balances[msg.sender] += msg.value;
        
        // 更新前3名排行榜
        updateTopThree(msg.sender);
    }
    
    // 6. 接收纯 ETH 转账（无需调用任何函数直接转账）
    receive() external payable {
        require(msg.value > 0, "Deposit amount must be greater than 0");
        
        balances[msg.sender] += msg.value;
        updateTopThree(msg.sender);
    }
    
    // 7. 内部函数：更新前3名账户地址（优化版逻辑）
    function updateTopThree(address user) internal {
        uint256 userBalance = balances[user];
        
        // 如果用户已经在榜单中，先将其移出，腾出空间
        for (uint8 i = 0; i < 3; i++) {
            if (topThree[i] == user) {
                for (uint8 j = i; j < 2; j++) {
                    topThree[j] = topThree[j + 1];
                }
                topThree[2] = address(0); // 将空出的最后一位清零
                break;
            }
        }
        
        // 如果当前用户的余额大于榜单上的最低金额，则插入
        if (userBalance > balances[topThree[2]]) {
            topThree[2] = user;
            // 简单冒泡排序，将新插入的用户向上移动
            for (uint8 i = 2; i > 0; i--) {
                if (balances[topThree[i]] > balances[topThree[i - 1]]) {
                    address temp = topThree[i];
                    topThree[i] = topThree[i - 1];
                    topThree[i - 1] = temp;
                } else {
                    break; // 如果不需要继续交换，提前退出循环，节省 Gas
                }
            }
        }
    }
    
    // 8. 管理员提取所有余额函数
    function withdraw() public onlyAdmin {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");
        
        // 使用 call 方法转账，安全性更高
        (bool success, ) = admin.call{value: balance}("");
        require(success, "Transfer failed");
    }
    
    // 查询合约总余额
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}

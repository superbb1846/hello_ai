
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
    
    // 5. 存款函数：通过 Metamask 发送 ETH 时调用
    function deposit() public payable {
        require(msg.value > 0, "Deposit amount must be greater than 0");
        
        // 更新用户的存款余额
        balances[msg.sender] += msg.value;
        
        // 更新前3名排行榜
        updateTopThree(msg.sender);
    }
    
    // 6. 内部函数：更新前3名账户地址
    function updateTopThree(address user) internal {
        uint256 userBalance = balances[user];
        
        // 遍历前3名数组，找到当前用户应该插入的位置
        for (uint8 i = 0; i < 3; i++) {
            if (topThree[i] == user) {
                // 如果用户已经在榜单中，只需重新排序
                sortTopThree();
                return;
            }
            
            // 如果当前用户的余额大于榜单上的用户，则插入
            if (userBalance > balances[topThree[i]]) {
                // 将后面的元素依次往后移
                for (uint8 j = 2; j > i; j--) {
                    topThree[j] = topThree[j - 1];
                }
                topThree[i] = user;
                return;
            }
        }
    }
    
    // 内部辅助函数：对前3名进行去重和排序（简单冒泡）
    function sortTopThree() internal {
        for (uint8 i = 0; i < 2; i++) {
            for (uint8 j = 0; j < 2 - i; j++) {
                if (balances[topThree[j]] < balances[topThree[j + 1]]) {
                    address temp = topThree[j];
                    topThree[j] = topThree[j + 1];
                    topThree[j + 1] = temp;
                }
            }
        }
    }
    
    // 7. 管理员提取所有余额函数
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

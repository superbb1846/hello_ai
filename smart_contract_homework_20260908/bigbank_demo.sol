
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 引入父合约（假设 bank_demo 在同一文件中，或者通过 import 引入）
// import "./bank_demo.sol"; 

// 1. Admin 合约：作为新的管理员
contract Admin {
    // 记录这个 Admin 合约的管理员（人类EOA）
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    // 只有 Admin 合约的 owner 才能调用此函数
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner of Admin contract");
        _;
    }

    // 提供提取资金的接口（调用 bigbank_demo 的 withdraw）
    // 注意：由于 bigbank_demo 的 withdraw 是 public，Admin 合约可以直接调用
    function emergencyWithdraw(address payable bankAddress) external onlyOwner {
        // 调用 bigbank_demo 的 withdraw 函数
        // 因为 bigbank_demo 里的 withdraw 检查的是 msg.sender == admin
        // 所以这里必须是 Admin 合约的地址去调用
        bigbank_demo(bankAddress).withdraw();
    }
}

// 2. bigbank_demo 合约：继承自 bank_demo
contract bigbank_demo is bank_demo {
    
    // 定义存款门槛：0.001 ETH
    uint256 public constant MIN_DEPOSIT = 0.001 ether;

    // 权限修饰器：只有余额 > 0.001 ETH 的 EOA 账户才能存款
    modifier minBalanceRequired() {
        require(msg.sender.balance > MIN_DEPOSIT, "EOA balance must be > 0.001 ETH");
        _;
    }

    // 重写（Override）父合约的 deposit 函数，加入权限控制
    // 注意：父合约的 deposit 是 public，这里必须使用 override
    function deposit() public payable override minBalanceRequired {
        // 调用父合约的 deposit 逻辑
        super.deposit();
    }

    // 重写（Override）父合约的 receive 函数，同样加入权限控制
    receive() external payable override minBalanceRequired {
        require(msg.value > 0, "Deposit amount must be greater than 0");
        balances[msg.sender] += msg.value;
        updateTopThree(msg.sender);
    }

    // 转移管理员权限给 Admin 合约
    function transferAdmin(address newAdmin) public onlyAdmin {
        require(newAdmin != address(0), "Invalid admin address");
        admin = newAdmin;
    }
}

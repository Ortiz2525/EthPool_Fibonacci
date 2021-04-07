// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.7.6;

import "@openzeppelin/contracts/math/SafeMath.sol";

contract EthPool_Fibonacci {
    using SafeMath for uint256;

    struct UserBalance {
        uint256 totalAmount; // Total amount of deposited tokens.
        uint256 amountWithdrawn; // The amount that has been withdrawn.
    }

    mapping(address => UserBalance) public balances;
    address payable[] public depositors;
    uint256 public totalBalance;

    function deposit() external payable {
        require(msg.value > 0, "amount shouldnt be zero");

        if (balances[msg.sender].totalAmount > 0) {
            balances[msg.sender].totalAmount = balances[msg.sender]
                .totalAmount
                .add(msg.value);
        } else {
            require(
                depositors.length < 200,
                "exceeds the maximum number of different accounts"
            );
            balances[msg.sender] = UserBalance({
                totalAmount: msg.value,
                amountWithdrawn: 0
            });
            depositors.push(msg.sender);
        }
        totalBalance = totalBalance.add(msg.value);
    }

    function _withdraw(address payable depositor, uint256 amount) internal {
        require(amount != 0, "amount shouldnt be zero");
        require(
            withdrawable(depositor) >= amount,
            "the amount exceeds the available balance"
        );

        depositor.transfer(amount);
        balances[depositor].amountWithdrawn = balances[depositor]
            .amountWithdrawn
            .add(amount);
    }

    function withdraw(uint256 amount) public {
        require(totalBalance <= 20 * (10**18), "you can only withdraw all");
        _withdraw(msg.sender, amount);
    }

    function withdrawable(address depositor) public view returns (uint256) {
        return
            balances[depositor].totalAmount.sub(
                balances[depositor].amountWithdrawn
            );
    }

    function withdrawn(address depositor) public view returns (uint256) {
        return balances[depositor].amountWithdrawn;
    }

    function withdrawAll() public {
        require(
            totalBalance != 0 && depositors.length != 0,
            "no ETH to withdraw"
        );

        for (uint8 i = 0; i < depositors.length; i++) {
            _withdraw(depositors[i], withdrawable(depositors[i]));
        }
    }

    function fibonacci(uint256 n) public pure returns (uint256) {
        if (n <= 1) return n;
        uint256 a = 0;
        uint256 b = 1;

        for (uint256 i = 2; i <= n; i++) {
            uint256 c = a.add(b);
            a = b;
            b = c;
        }

        return b;
    }
}

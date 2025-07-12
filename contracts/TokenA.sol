
// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract tokenA is ERC20{
    constructor ERC20("TokenA", "TKA"){

    }
    function mint(uint256 amount) public {
        _mint(msg.sender, amount*10);
    }
}
// contracts/MyNFT.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Capped.sol";


contract Spay is ERC20, ERC20Capped {
    constructor() public
        ERC20("SpaceY Token", "SPAY")
        ERC20Capped(25000000 * (10**uint256(18)))
    {
        _mint(msg.sender, 25000000 * (10 ** uint256(decimals())));
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override(ERC20, ERC20Capped) {
        super._beforeTokenTransfer(from, to, amount);
    }
}
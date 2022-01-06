// contracts/MyNFT.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

import "@openzeppelin/contracts/presets/ERC20PresetMinterPauser.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Capped.sol";

contract Metamars is ERC20PresetMinterPauser, ERC20Capped {
    constructor() public
        ERC20PresetMinterPauser("Metamars", "METAMARS")
        ERC20Capped(1000000000)
    {
        _setupDecimals(0);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override(ERC20PresetMinterPauser, ERC20Capped) {
        super._beforeTokenTransfer(from, to, amount);
    }
}
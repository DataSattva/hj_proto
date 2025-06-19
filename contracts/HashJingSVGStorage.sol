// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./SSTORE2.sol";

contract HashJingSVGStorage1 {
    address public immutable svgPointer;

    constructor() {
        svgPointer = SSTORE2.write(hex"3c737667207072657365727665417370656374526174696f3d22784d6964594d6964206d656574222076696577426f78...");
    }

    function getPointer() external view returns (address) {
        return svgPointer;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./SSTORE2.sol";

contract HashJingSVGStorage2 {
    address public immutable svgChunk2;

    constructor() {
        svgChunk2 = SSTORE2.write(
            hex"12345678"
        );
    }

    function getChunk() external view returns (address) {
        return svgChunk2;
    }
}

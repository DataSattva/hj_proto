// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./SSTORE2.sol";

contract HashJingSVGStorage2 {
    address public immutable svgChunk2;

    constructor() {
        svgChunk2 = SSTORE2.write(
            hex"0a20203c636972636c652063783d22323530222063793d223235302220723d22313030222066696c6c3d22626c61636b22202f3e0a3c2f7376673e"
        );
    }

    function getChunk() external view returns (address) {
        return svgChunk2;
    }
}

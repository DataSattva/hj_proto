// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./SSTORE2.sol";
import "./HashJingSVGStorage1.sol";
import "./HashJingSVGStorage2.sol";

contract HashJingViewer {
    address public immutable chunk1;
    address public immutable chunk2;

    constructor(address _chunk1, address _chunk2) {
        chunk1 = _chunk1;
        chunk2 = _chunk2;
    }

    function getSVG() external view returns (string memory) {
        bytes memory part1 = SSTORE2.read(chunk1);
        bytes memory part2 = SSTORE2.read(chunk2);
        return string(abi.encodePacked(part1, part2));
    }
}

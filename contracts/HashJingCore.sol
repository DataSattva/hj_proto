// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./SSTORE2.sol";

contract HashJingMain {
    address[] public svgPointers;

    constructor(address[] memory _pointers) {
        svgPointers = _pointers;
    }

    function tokenURI(uint256 tokenId) public view returns (string memory) {
        string memory svg;
        for (uint256 i = 0; i < svgPointers.length; ++i) {
            svg = string(abi.encodePacked(svg, SSTORE2.read(svgPointers[i])));
        }
        return string(abi.encodePacked("data:image/svg+xml;utf8,", svg));
    }
}

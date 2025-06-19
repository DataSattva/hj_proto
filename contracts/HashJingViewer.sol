// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./SSTORE2.sol";

interface IStorage {
    function getPointer() external view returns (address);
}

contract HashJingViewer {
    address public immutable storageContract;

    constructor(address _storageContract) {
        storageContract = _storageContract;
    }

    function getSVG() external view returns (string memory) {
        address pointer = IStorage(storageContract).getPointer();
        return string(SSTORE2.read(pointer));
    }
}

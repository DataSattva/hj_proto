// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./SSTORE2.sol";

contract HashJingViewer {
    address public immutable chunk1;

    constructor(address _chunk1) {
        chunk1 = _chunk1;
    }

    function getSVG() external view returns (string memory) {
        string memory raw = string(SSTORE2.read(chunk1));

        raw = substitute(raw, "c_1", "white");
        raw = substitute(raw, "c_2", "black");
        raw = substitute(raw, "c_3", "white");
        raw = substitute(raw, "c_4", "black");

        return raw;
    }

    function substitute(string memory input, string memory key, string memory value) internal pure returns (string memory) {
        bytes memory inputBytes = bytes(input);
        bytes memory keyBytes = bytes(key);
        bytes memory valueBytes = bytes(value);

        bytes memory result = new bytes(inputBytes.length + 64);
        uint256 resultIndex = 0;

        for (uint256 i = 0; i < inputBytes.length; ) {
            bool matchFound = true;
            if (i + keyBytes.length > inputBytes.length) {
                matchFound = false;
            } else {
                for (uint256 j = 0; j < keyBytes.length; j++) {
                    if (inputBytes[i + j] != keyBytes[j]) {
                        matchFound = false;
                        break;
                    }
                }
            }

            if (matchFound) {
                for (uint256 j = 0; j < valueBytes.length; j++) {
                    result[resultIndex++] = valueBytes[j];
                }
                i += keyBytes.length;
            } else {
                result[resultIndex++] = inputBytes[i++];
            }
        }

        bytes memory finalResult = new bytes(resultIndex);
        for (uint256 k = 0; k < resultIndex; k++) {
            finalResult[k] = result[k];
        }

        return string(finalResult);
    }
}

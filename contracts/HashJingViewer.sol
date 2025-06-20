// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./SSTORE2.sol";
import "./HashJingSVGStorage1.sol";

contract SingleSectorRenderer {
    HashJingSVGStorage1 immutable store;

    bytes constant TAIL = '"/>';              // закрываем path

    constructor(address storageAddr) {
        store = HashJingSVGStorage1(storageAddr);
    }

    /// @dev возвращает SVG-фрагмент одного сектора:
    ///      c1 = black, c2 = white, c3 = black, c4 = white
    function getSVG() external view returns (string memory) {
        uint8 bits = 0x0A;                    // 1010 (c1-1, c2-0, c3-1, c4-0)

        bytes memory svg;
        unchecked {
            for (uint8 ring; ring < 4; ++ring) {
                bytes  memory pref = store.prefix(ring);              // префикс path
                string memory col  = _col((bits >> (3 - ring)) & 1);  // цвет
                svg = bytes.concat(svg, pref, bytes(col), TAIL);      // prefix+color+"/>"
            }
        }
        return string(svg);
    }

    /*──── helper: 0 → white, 1 → black ───*/
    function _col(uint8 bit) private pure returns (string memory) {
        return bit == 0 ? "#ffffff" : "#000000";
    }
}

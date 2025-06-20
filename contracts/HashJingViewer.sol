// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./HashJingSVGStorage1.sol";

contract FullMandalaRenderer {
    /* ─── константы ─── */

    uint256 constant SECTORS   = 64;      // 64 × 5.625°
    uint256 constant DPHI_MDEG = 5625;    // угол в ‰ градуса
    uint256 constant BITS =
        0x478affc447283c7cd1bb68a514243f4c139860bd048217a4b7e7eb7a51855eff;

    bytes  constant G_OPEN   = '<g transform="rotate(';
    bytes  constant G_MID    = ' 512 512)">';
    bytes  constant G_CLOSE  = '</g>';
    bytes  constant PATH_END = '"/>';     // …fill="COLOR"/>

    HashJingSVGStorage1 immutable store;  // 4 префикса path-ов

    constructor(address storageAddr) {
        store = HashJingSVGStorage1(storageAddr);
    }

    /* ─── публичный вывод ─── */

    function getSVG() external view returns (string memory) {
        /** 1. собираем элементы */
        bytes[] memory part = new bytes[](SECTORS * 16);  // ← исправлено
        uint256 idx;
        uint256 total;

        for (uint256 s; s < SECTORS; ++s) {
            /* 1-а) <g …> */
            bytes memory ang = _angleBytes(s * DPHI_MDEG);
            part[idx++] = G_OPEN;  total += G_OPEN.length;
            part[idx++] = ang;     total += ang.length;
            part[idx++] = G_MID;   total += G_MID.length;

            /* 1-б) четыре кольца */
            for (uint8 r; r < 4; ++r) {
                bytes memory pref = store.prefix(r);

                bool black = (BITS >> ((63 - s) * 4 + r)) & 1 == 0;
                bytes memory col = black ? bytes("#000000") : bytes("#ffffff");

                part[idx++] = pref;      total += pref.length;
                part[idx++] = col;       total += 7;              // «#rrggbb»
                part[idx++] = PATH_END;  total += PATH_END.length;
            }
            /* 1-в) </g> */
            part[idx++] = G_CLOSE;  total += G_CLOSE.length;
        }

        /** 2. однократное выделение памяти + копирование */
        bytes memory svg = new bytes(total);
        uint256 offset;

        for (uint256 i; i < part.length; ++i) {
            bytes memory p = part[i];
            uint256 len = p.length;
            if (len == 0) continue;

            assembly {
                // dst = svg.data + offset
                let dst := add(add(svg, 32), offset)
                let src := add(p, 32)
                for { let j := 0 } lt(j, len) { j := add(j, 32) } {
                    mstore(add(dst, j), mload(add(src, j)))
                }
            }
            offset += len;
        }
        return string(svg);
    }

    /* ─── helpers ─── */

    // угол в тысячных градуса → ASCII-bytes («0», «5.625», …)
    function _angleBytes(uint256 v) private pure returns (bytes memory) {
        uint256 ip = v / 1000;
        uint256 fp = v % 1000;
        if (fp == 0) return _uDecBytes(ip);

        // убираем хвостовые нули 625 → «625», 500 → «5», 250 → «25»
        uint8 digs = 3;
        while (fp % 10 == 0) { fp /= 10; --digs; }

        return abi.encodePacked(_uDecBytes(ip), ".", _uDecBytes(fp, digs));
    }

    // uint → ASCII-bytes; width — минимальная ширина (ведущие нули)
    function _uDecBytes(uint256 v, uint8 width)
        private
        pure
        returns (bytes memory out)
    {
        while (width > 0 || v > 0) {
            out = abi.encodePacked(bytes1(uint8(48 + (v % 10))), out);
            v /= 10;
            if (width > 0) --width;
        }
        if (out.length == 0) out = "0";
    }
    function _uDecBytes(uint256 v) private pure returns (bytes memory) {
        return _uDecBytes(v, 0);
    }
}

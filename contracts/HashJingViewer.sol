// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./HashJingSVGStorage1.sol";

contract FullMandalaRenderer {
    /* ───────── geometry ───────── */

    uint256 constant SECTORS   = 64;      // 64 × 5 5⁄8°
    uint256 constant DPHI_MDEG = 5625;    // угол в ‰ градуса

    /* ───────── единственный 256-битовый шаблон ───────── */

    bytes32 constant HASH =
        0x478affc447283c7cd1bb68a514243f4c139860bd048217a4b7e7eb7a51855eff;

    /* ───────── часто повторяющиеся кусочки ───────── */

    bytes constant G_OPEN   = '<g transform="rotate(';
    bytes constant G_MID    = ' 512 512)">';
    bytes constant G_CLOSE  = '</g>';
    bytes constant PATH_END = '"/>';
    bytes constant WHITE    = "#ffffff";
    bytes constant BLACK    = "#000000";
    bytes constant TEXT_END = "</text>";

    /* ───────── SSTORE2-хранилище шаблонов ───────── */

    HashJingSVGStorage1 immutable store;
    constructor(address storageAddr) { store = HashJingSVGStorage1(storageAddr); }

    /* ────────────────────────────────────────────── */

    function getSVG() external view returns (string memory) {
        /*
           1 head   +
           64·16 sector-chunks =
           4 text-lines · 3 chunks +
           1 tail
        */
        bytes[] memory part = new bytes[](1 + 64 * 16 + 4 * 3 + 1);
        uint256 idx;
        uint256 total;

        /* 0) <svg …><rect …/> */
        {
            bytes memory head = store.head();
            part[idx++] = head;      total += head.length;
        }

        /* 1) 64 секторов */
        for (uint256 s; s < SECTORS; ++s) {
            /* <g transform="rotate(… 512 512)"> */
            {
                bytes memory ang = _angleBytes(s * DPHI_MDEG);
                part[idx++] = G_OPEN; total += G_OPEN.length;
                part[idx++] = ang;    total += ang.length;
                part[idx++] = G_MID;  total += G_MID.length;
            }

            /* четыре кольца */
            for (uint8 r; r < 4; ++r) {
                bytes memory pref = store.prefix(r);

                bool black = (HASH >> ((63 - s) * 4 + r)) & bytes32(uint256(1)) == 0;
                bytes memory col = black ? BLACK : WHITE;

                part[idx++] = pref;     total += pref.length;
                part[idx++] = col;      total += 7;                  // «#rrggbb»
                part[idx++] = PATH_END; total += PATH_END.length;
            }

            part[idx++] = G_CLOSE; total += G_CLOSE.length;
        }

        /* 2) четыре текст-строки хэша */
        for (uint8 line; line < 4; ++line) {
            bytes memory pre  = store.textPrefix(line);
            bytes memory data = _hex16(HASH, line);   // ровно 16 байт

            part[idx++] = pre;      total += pre.length;
            part[idx++] = data;     total += 16;
            part[idx++] = TEXT_END; total += TEXT_END.length;
        }

        /* 3) </svg> */
        {
            bytes memory tail = store.tail();
            part[idx++] = tail;     total += tail.length;
        }

        /* 4) одно копирование всех кусков в итоговый буфер */
        bytes memory svg = new bytes(total);
        uint256 offset;

        for (uint256 i; i < part.length; ++i) {
            bytes memory p = part[i];
            uint256 len = p.length;
            if (len == 0) continue;

            assembly {
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

    /* ───────── helpers ───────── */

    // угол (‰°) → ASCII-bytes («0», «5.625», …)
    function _angleBytes(uint256 v) private pure returns (bytes memory) {
        uint256 ip = v / 1000;
        uint256 fp = v % 1000;
        if (fp == 0) return _uDecBytes(ip);

        uint8 digs = 3;
        while (fp % 10 == 0) { fp /= 10; --digs; }
        return abi.encodePacked(_uDecBytes(ip), ".", _uDecBytes(fp, digs));
    }

    // uint → ASCII-bytes (минимальная ширина = width)
    function _uDecBytes(uint256 v, uint8 width)
        private pure returns (bytes memory out)
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

    /* 16-символьный фрагмент хэша (строка 0-3) */
    function _hex16(bytes32 h, uint8 line) private pure returns (bytes memory) {
        bytes memory out = new bytes(16);
        unchecked {
            for (uint8 i; i < 16; ++i) {
                uint8 nib = uint8(uint256(h) >> ((63 - (line * 16 + i)) * 4)) & 0xF;
                out[i] = bytes1(nib + (nib < 10 ? 48 : 87)); // 0-9 / a-f
            }
        }
        return out;
    }
}

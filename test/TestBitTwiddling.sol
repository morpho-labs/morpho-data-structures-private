// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

import "./helpers/ConcreteBitTwiddling.sol";

contract TestBitTwiddling is Test {
    ConcreteBitTwiddling public bitTwiddling = new ConcreteBitTwiddling();
    bytes32 internal constant FIRST_MASK =
        0x00000000000000000000000000000000000000000000000000000000000000ff;
    bytes32 internal constant ONE =
        0x0000000000000000000000000000000000000000000000000000000000000001;

    function testComputeMask(uint256 x) public {
        (uint256 byte_offset, bytes32 y) = bitTwiddling.computeMask(x);

        for (uint256 i; i < 256; i++) {
            if (byte_offset * 8 <= i && i < (byte_offset + 1) * 8)
                assertTrue(y & (ONE << i) != 0, "bit should be 1");
            else assertTrue(y & (ONE << i) == 0, "bit should be 0");
        }
    }

    function testPrevBitMaskUp() public {
        uint256 byte_offset = 10;
        bytes32 bitMask = FIRST_MASK << (byte_offset * 8);
        bytes32 fullMask = FIRST_MASK << ((byte_offset + 1) * 8);

        bytes32 nextBit = bitTwiddling.prevBitMask(bitMask, byte_offset, fullMask);

        assertEq(nextBit, 0, "bitMask up is wrong");
    }

    function testPrevBitMaskEqual() public {
        uint256 byte_offset = 5;
        bytes32 bitMask = FIRST_MASK << (byte_offset * 8);
        bytes32 fullMask = bitMask;

        bytes32 nextBit = bitTwiddling.prevBitMask(bitMask, byte_offset, fullMask);

        assertEq(nextBit, bitMask, "bitMask up is wrong");
    }

    function testPrevBitMaskBelow() public {
        uint256 byte_offset = 6;
        bytes32 bitMask = FIRST_MASK << (byte_offset * 8);
        bytes32 fullMask = FIRST_MASK << ((byte_offset - 3) * 8);

        bytes32 nextBit = bitTwiddling.prevBitMask(bitMask, byte_offset, fullMask);

        assertEq(nextBit, fullMask, "bitMask up is wrong");
    }

    function testPrevBitMaskBelowTwo() public {
        uint256 byte_offset = 7;
        bytes32 bitMask = FIRST_MASK << (byte_offset * 8);
        bytes32 firstByte = FIRST_MASK << ((byte_offset - 3) * 8);
        bytes32 fullMask = firstByte | (FIRST_MASK << ((byte_offset - 5) * 8));

        bytes32 nextBit = bitTwiddling.prevBitMask(bitMask, byte_offset, fullMask);

        assertEq(nextBit, firstByte, "bitMask up two is wrong");
    }

    function testNextBitMaskUp() public {
        uint256 byte_offset = 10;
        bytes32 bitMask = FIRST_MASK << (byte_offset * 8);
        bytes32 fullMask = FIRST_MASK << ((byte_offset + 1) * 8);

        bytes32 nextBit = bitTwiddling.nextBitMask(bitMask, byte_offset, fullMask);

        assertEq(nextBit, fullMask, "bitMask up is wrong");
    }

    function testNextBitMaskUpTwo() public {
        uint256 byte_offset = 7;
        bytes32 bitMask = FIRST_MASK << (byte_offset * 8);
        bytes32 firstByte = FIRST_MASK << ((byte_offset + 3) * 8);
        bytes32 fullMask = firstByte | (FIRST_MASK << ((byte_offset + 12) * 8));

        bytes32 nextBit = bitTwiddling.nextBitMask(bitMask, byte_offset, fullMask);

        assertEq(nextBit, firstByte, "bitMask up two is wrong");
    }

    function testNextBitMaskEqual() public {
        uint256 byte_offset = 5;
        bytes32 bitMask = FIRST_MASK << (byte_offset * 8);
        bytes32 fullMask = bitMask;

        bytes32 nextBit = bitTwiddling.nextBitMask(bitMask, byte_offset, fullMask);

        assertEq(nextBit, 0, "bitMask up is wrong");
    }

    function testNextBitMaskBelow() public {
        uint256 byte_offset = 6;
        bytes32 bitMask = FIRST_MASK << (byte_offset * 8);
        bytes32 fullMask = FIRST_MASK << ((byte_offset - 3) * 8);

        bytes32 nextBit = bitTwiddling.nextBitMask(bitMask, byte_offset, fullMask);

        assertEq(nextBit, 0, "bitMask up is wrong");
    }
}

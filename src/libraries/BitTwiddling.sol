// SPDX-License-Identifier: GNU AGPLv3
pragma solidity ^0.8.0;

library BitTwiddling {
    /// CONSTANTS ///

    bytes32 internal constant FIRST_MASK =
        0x00000000000000000000000000000000000000000000000000000000000000ff;

    /// INTERNAL FUNCTIONS ///

    /// @notice Computes the mask and offset in bytes of the mask.
    /// @dev Masks are working on bytes (not bits), a byte toggled on is indicated by Oxff and a byte toggled off is indicated by 0x00
    function computeMask(uint256 x) internal pure returns (uint256 byte_offset, bytes32 y) {
        byte_offset = log256(x); // IMPORTANT: we could also use `min(31, log2(x))` or any function returning an integer strictly smaller than 32
        y = FIRST_MASK << (byte_offset * 8);
    }

    function nextBitMask(
        bytes32 bitMask,
        uint256 byte_offset,
        bytes32 fullMask
    ) internal pure returns (bytes32 nextBit) {
        assembly {
            bitMask := shl(8, signextend(byte_offset, bitMask))
            nextBit := and(bitMask, fullMask)
            nextBit := and(nextBit, add(not(nextBit), 1))
            nextBit := or(nextBit, shl(1, nextBit))
            nextBit := or(nextBit, shl(2, nextBit))
            nextBit := or(nextBit, shl(4, nextBit))
        }
    }

    function prevBitMask(
        bytes32 bitMask,
        uint256 byte_offset,
        bytes32 fullMask
    ) internal pure returns (bytes32 prevBit) {
        assembly {
            bitMask := shl(8, signextend(byte_offset, bitMask))
            prevBit := and(not(bitMask), fullMask)
            prevBit := or(prevBit, shr(8, prevBit))
            prevBit := or(prevBit, shr(16, prevBit))
            prevBit := or(prevBit, shr(32, prevBit))
            prevBit := or(prevBit, shr(64, prevBit))
            prevBit := or(prevBit, shr(128, prevBit))
            prevBit := xor(prevBit, shr(8, prevBit))
        }
    }

    /// @dev Returns the floor of log256(x) and returns 0 on input 0.
    function log256(uint256 x) internal pure returns (uint256) {
        return log2(x) / 8;
    }

    /// @dev Returns the floor of log2(x) and returns 0 on input 0.
    /// @dev This computation makes use of De Bruijn sequences, their usage for computing log2 is referenced here: http://supertech.csail.mit.edu/papers/debruijn.pdf
    function log2(uint256 x) internal pure returns (uint256 y) {
        assembly {
            // Use the highest set bit of x to set each of its lower bits
            x := or(x, shr(1, x))
            x := or(x, shr(2, x))
            x := or(x, shr(4, x))
            x := or(x, shr(8, x))
            x := or(x, shr(16, x))
            x := or(x, shr(32, x))
            x := or(x, shr(64, x))
            x := or(x, shr(128, x))
            // Take only the highest bit of x
            x := xor(x, shr(1, x))

            // Hash table associating the first 256 powers of 2 to their byte_offset
            // Let x be a power of 2, its hash is obtained by taking the first byte of x * deBruijnSeq
            let m := mload(0x40)
            mstore(m, 0x0001020903110a19042112290b311a3905412245134d2a550c5d32651b6d3a75)
            mstore(add(m, 0x20), 0x06264262237d468514804e8d2b95569d0d495ea533a966b11c886eb93bc176c9)
            mstore(add(m, 0x40), 0x071727374353637324837e9b47af86c7155181ad4fd18ed32c9096db57d59ee3)
            mstore(add(m, 0x60), 0x0e2e4a6a5f92a6be3498aae067ddb2eb1d5989b56fd7baf33ca0c2ee77e5caf7)
            mstore(add(m, 0x80), 0xff0810182028303840444c545c646c7425617c847f8c949c48a4a8b087b8c0c8)
            mstore(add(m, 0xa0), 0x16365272829aaec650acd0d28fdad4e22d6991bd97dfdcea58b4d6f29fede4f6)
            mstore(add(m, 0xc0), 0xfe0f1f2f3f4b5b6b607b8b93a3a7b7bf357199c5abcfd9e168bcdee9b3f1ecf5)
            mstore(add(m, 0xe0), 0xfd1e3e5a7a8aa2b670c4ced8bbe8f0f4fc3d79a1c3cde7effb78cce6facbf9f8)
            mstore(0x40, add(m, 0x100)) // Update the free memory pointer

            // This De Bruijn sequence begins with the byte 0, which is important to make shifting work like a rotation on the first byte
            let deBruijnSeq := 0x00818283848586878898a8b8c8d8e8f929395969799a9b9d9e9faaeb6bedeeff
            let key := shr(248, mul(x, deBruijnSeq)) // With the multiplication it works also for 0
            y := shr(248, mload(add(m, key))) // Look in the table and take the first byte
        }
    }
}

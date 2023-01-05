// SPDX-License-Identifier: GNU AGPLv3
pragma solidity ^0.8.0;

import "@morpho-dao/morpho-utils/math/Math.sol";

library BitTwiddling {
    /// CONSTANTS ///

    bytes32 internal constant FIRST_MASK =
        0x00000000000000000000000000000000000000000000000000000000000000ff;

    /// INTERNAL FUNCTIONS ///

    /// @notice Computes the mask and offset in bytes of the mask.
    /// @dev Masks are working on bytes (not bits), a byte toggled on is indicated by Oxff and a byte toggled off is indicated by 0x00.
    function computeMask(uint256 x) internal pure returns (uint256 byteOffset, bytes32 y) {
        byteOffset = _log256(x); // IMPORTANT: we could also use `min(31, log2(x))` or any function returning an integer strictly smaller than 32.
        y = FIRST_MASK << (byteOffset * 8);
    }

    /// @notice Returns the mask just above `bitMask` in `fullMask`. Returns 0 if there is none.
    /// @dev Masks are working on bytes (not bits), a byte toggled on is indicated by Oxff and a byte toggled off is indicated by 0x00.
    /// @param bitMask the mask in byte from which to search for the next mask.
    /// @param byteOffset the offset in bytes representing `bitMask`.
    /// @param fullMask the mask in byte on which to search the next mask. `fullMask` may have multiple bytes on.
    function nextBitMask(
        bytes32 bitMask,
        uint256 byteOffset,
        bytes32 fullMask
    ) internal pure returns (bytes32 nextBit) {
        assembly {
            // Get the mask to select all the bits strictly higher than bitMask.
            bitMask := shl(8, signextend(byteOffset, bitMask))
            // Select all the bits in fullMask higher than bitMask.
            nextBit := and(bitMask, fullMask)
            // Select the lower bit.
            nextBit := and(nextBit, add(not(nextBit), 1))
            // Set all the bits of the byte containing the bit set.
            nextBit := or(nextBit, shl(1, nextBit))
            nextBit := or(nextBit, shl(2, nextBit))
            nextBit := or(nextBit, shl(4, nextBit))
        }
    }

    /// @notice Returns the mask just below `bitMask` in `fullMask`. Returns 0 if there is none.
    /// @dev Masks are working on bytes (not bits), a byte toggled on is indicated by Oxff and a byte toggled off is indicated by 0x00.
    /// @param bitMask the mask in byte from which to search for the previous mask.
    /// @param byteOffset the offset in bytes representing `bitMask`.
    /// @param fullMask the mask in byte on which to search the previous mask. `fullMask` may have multiple bytes on.
    function prevBitMask(
        bytes32 bitMask,
        uint256 byteOffset,
        bytes32 fullMask
    ) internal pure returns (bytes32 prevBit) {
        assembly {
            // Get the mask to select all the bits strictly higher than bitMask.
            bitMask := shl(8, signextend(byteOffset, bitMask))
            // Select all the bits in fullMask smaller or equal to bitMask.
            prevBit := and(not(bitMask), fullMask)
            // Set all lower bits.
            prevBit := or(prevBit, shr(8, prevBit))
            prevBit := or(prevBit, shr(16, prevBit))
            prevBit := or(prevBit, shr(32, prevBit))
            prevBit := or(prevBit, shr(64, prevBit))
            prevBit := or(prevBit, shr(128, prevBit))
            // Select only the higher 8 bits.
            prevBit := xor(prevBit, shr(8, prevBit))
        }
    }

    /// PRIVATE FUNCTIONS ///

    /// @dev Returns the floor of log256(x) and returns 0 on input 0.
    function _log256(uint256 x) private pure returns (uint256) {
        return Math.log2(x) / 8;
    }
}

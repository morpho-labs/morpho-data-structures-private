// SPDX-License-Identifier: GNU AGPLv3
pragma solidity ^0.8.0;

import "src/BitTwiddling.sol";

contract ConcreteBitTwiddling {
    function firstMask() public pure returns (bytes32) {
        return BitTwiddling.FIRST_MASK;
    }

    function computeMask(uint256 x) public pure returns (uint256 byteOffset, bytes32 y) {
        return BitTwiddling.computeMask(x);
    }

    function nextBitMask(
        bytes32 bitMask,
        uint256 byteOffset,
        bytes32 fullMask
    ) public pure returns (bytes32 nextBit) {
        return BitTwiddling.nextBitMask(bitMask, byteOffset, fullMask);
    }

    function prevBitMask(
        bytes32 bitMask,
        uint256 byteOffset,
        bytes32 fullMask
    ) public pure returns (bytes32 prevBit) {
        return BitTwiddling.prevBitMask(bitMask, byteOffset, fullMask);
    }
}

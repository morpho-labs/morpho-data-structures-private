// SPDX-License-Identifier: GNU AGPLv3
pragma solidity ^0.8.0;

import "src/libraries/BitTwiddling.sol";

contract ConcreteBitTwiddling {
    function firstMask() public pure returns (bytes32) {
        return BitTwiddling.FIRST_MASK;
    }

    function computeMask(uint256 x) public pure returns (uint256 byte_offset, bytes32 y) {
        return BitTwiddling.computeMask(x);
    }

    function nextBitMask(
        bytes32 bitMask,
        uint256 byte_offset,
        bytes32 fullMask
    ) public pure returns (bytes32 nextBit) {
        return BitTwiddling.nextBitMask(bitMask, byte_offset, fullMask);
    }

    function prevBitMask(
        bytes32 bitMask,
        uint256 byte_offset,
        bytes32 fullMask
    ) public pure returns (bytes32 prevBit) {
        return BitTwiddling.prevBitMask(bitMask, byte_offset, fullMask);
    }

    function log256(uint256 x) public pure returns (uint256) {
        return BitTwiddling.log256(x);
    }

    function log2(uint256 x) public pure returns (uint256 y) {
        return BitTwiddling.log2(x);
    }
}

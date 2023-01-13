// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import "src/LogarithmicBuckets.sol";

contract LogarithmicBucketsMock {
    using BucketDLL for BucketDLL.List;
    using LogarithmicBuckets for LogarithmicBuckets.BucketList;

    LogarithmicBuckets.BucketList public bucketList;

    function update(bytes32 _id, uint256 _newValue) public virtual {
        bucketList.update(_id, _newValue);
    }

    function getValueOf(bytes32 _id) public view returns (uint256) {
        return bucketList.getValueOf(_id);
    }

    function _setLowerBits(uint256 x) private pure returns (uint256 y) {
        assembly {
            x := or(x, shr(1, x))
            x := or(x, shr(2, x))
            x := or(x, shr(4, x))
            x := or(x, shr(8, x))
            x := or(x, shr(16, x))
            x := or(x, shr(32, x))
            x := or(x, shr(64, x))
            y := or(x, shr(128, x))
        }
    }

    function maxBucket() public view returns (uint256) {
        uint256 lowerMask = _setLowerBits(bucketList.bucketsMask);
        return lowerMask ^ (lowerMask >> 1);
    }

    function getMatch(uint256 _value, bool _fifo) public view returns (bytes32) {
        return bucketList.getMatch(_value, _fifo);
    }

    function verifyStructure() public view returns (bool) {
        for (uint256 i; i < 256; i++) {
            uint256 lowerValue = 2**i;
            uint256 higherValue;
            unchecked {
                higherValue = 2**(i + 1) - 1;
            }

            BucketDLL.List storage list = bucketList.getBucketOf(lowerValue);

            for (bytes32 id = list.getHead(); id != 0; id = list.getNext(id)) {
                uint256 value = bucketList.getValueOf(id);
                if (value < lowerValue || value > higherValue) return false;
            }
        }
        return true;
    }
}

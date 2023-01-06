// SPDX-License-Identifier: GNU AGPLv3
pragma solidity ^0.8.0;

import "src/BucketLib.sol";
import "src/BitBucketsLib.sol";

contract ConcreteBitBuckets {
    using BitTwiddling for uint256;
    using BucketLib for BucketLib.Bucket;
    using BitBucketsLib for BitBucketsLib.BitBuckets;

    BitBucketsLib.BitBuckets internal bitBuckets;

    function update(address _id, uint256 _newValue) public {
        bitBuckets.update(_id, _newValue);
    }

    function getValueOf(address _id) public view returns (uint256) {
        return bitBuckets.getValueOf(_id);
    }

    function getHead(uint96 _value) public view returns (address) {
        return bitBuckets.getHead(_value);
    }

    function getMaskOf(address _id) public view returns (bytes32) {
        (, bytes32 mask) = bitBuckets.balanceOf[_id].computeMask();
        return mask;
    }

    function getBucketsMask() public view returns (bytes32) {
        return bitBuckets.bucketsMask;
    }

    function verifyStructure() public view returns (bool) {
        for (uint256 i; i < 32; i++) {
            uint256 lowerValue = 2**(8 * i);
            uint256 higherValue;
            if (i == 31) higherValue = type(uint256).max;
            else higherValue = 2**(8 * (i + 1)) - 1;
            bytes32 mask = BitTwiddling.FIRST_MASK << (8 * i);
            BucketLib.Bucket storage bucket = bitBuckets.buckets[mask];
            for (uint256 j; j < bucket.getLength(); j++) {
                uint256 value = bitBuckets.balanceOf[bucket.accounts[j].id];
                if (value < lowerValue || value > higherValue) return false;
            }
        }
        return true;
    }
}

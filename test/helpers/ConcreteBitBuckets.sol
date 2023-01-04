// SPDX-License-Identifier: GNU AGPLv3
pragma solidity ^0.8.0;

import "src/BucketLib.sol";
import "src/BitBucketsLib.sol";

contract ConcreteBitBuckets {
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
}

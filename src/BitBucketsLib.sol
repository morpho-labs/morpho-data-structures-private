// SPDX-License-Identifier: GNU AGPLv3
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeCast.sol";
import "./libraries/BitTwiddling.sol";
import "./BucketLib.sol";

library BitBucketsLib {
    using BitTwiddling for uint256;
    using BucketLib for BucketLib.Bucket;

    struct BitBuckets {
        mapping(bytes32 => BucketLib.Bucket) buckets;
        mapping(address => bytes32) maskOf;
        bytes32 bucketsMask; // bitmask for all used buckets
    }

    /// ERRORS ///

    /// @notice Thrown when the address is zero at insertion.
    error AddressIsZero();
    /// @notice Thrown when 0 value is inserted.
    error ZeroValue();

    /// INTERNAL ///

    /// @notice Updates an account in the `_bitBuckets`.
    function update(
        BitBuckets storage _bitBuckets,
        address _id,
        uint256 _newValue
    ) internal {
        bytes32 formerMask = _bitBuckets.maskOf[_id];
        BucketLib.Bucket storage formerBucket = _bitBuckets.buckets[formerMask];
        uint96 formerValue = formerBucket.getValueOf(_id);
        uint96 newValue = SafeCast.toUint96(_newValue);

        if (formerValue == newValue) return;

        if (newValue == 0) remove(_bitBuckets, formerMask, _id);
        else {
            bytes32 newMask = _newValue.computeMask();
            if (formerValue == 0) insert(_bitBuckets, newMask, _id, newValue);
            else if (newMask == formerMask) formerBucket.changeValue(_id, newValue);
            else {
                remove(_bitBuckets, formerMask, _id);
                insert(_bitBuckets, newMask, _id, newValue);
            }
        }
    }

    /// PRIVATE ///

    function remove(
        BitBuckets storage _bitBuckets,
        bytes32 _formerMask,
        address _id
    ) private {
        BucketLib.Bucket storage formerBucket = _bitBuckets.buckets[_formerMask];
        formerBucket.remove(_id);
        delete _bitBuckets.maskOf[_id];
        _bitBuckets.bucketsMask &= ~_formerMask;
    }

    function insert(
        BitBuckets storage _bitBuckets,
        bytes32 _newMask,
        address _id,
        uint96 _newValue
    ) private {
        BucketLib.Bucket storage newBucket = _bitBuckets.buckets[_newMask];
        newBucket.insert(_id, _newValue);
        _bitBuckets.maskOf[_id] = _newMask;
        _bitBuckets.bucketsMask |= _newMask;
    }
}

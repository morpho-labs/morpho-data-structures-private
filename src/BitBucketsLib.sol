// SPDX-License-Identifier: GNU AGPLv3
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeCast.sol";
import "./libraries/BitTwiddling.sol";
import "./BucketLib.sol";

library BitBucketsLib {
    using BitTwiddling for uint256;
    using BitTwiddling for bytes32;
    using BucketLib for BucketLib.Bucket;

    struct BitBuckets {
        mapping(bytes32 => BucketLib.Bucket) buckets;
        mapping(address => bytes32) maskOf;
        bytes32 bucketsMask; // bitmask for all used buckets
    }

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

        if (newValue == 0) _remove(_bitBuckets, formerMask, _id);
        else {
            (, bytes32 newMask) = _newValue.computeMask();
            if (formerValue == 0) _insert(_bitBuckets, newMask, _id, newValue);
            else if (newMask == formerMask) formerBucket.changeValue(_id, newValue);
            else {
                _remove(_bitBuckets, formerMask, _id);
                _insert(_bitBuckets, newMask, _id, newValue);
            }
        }
    }

    function getValueOf(BitBuckets storage _bitBuckets, address _id)
        internal
        view
        returns (uint256)
    {
        bytes32 formerMask = _bitBuckets.maskOf[_id];
        return _bitBuckets.buckets[formerMask].getValueOf(_id);
    }

    function getHead(BitBuckets storage _bitBuckets, uint96 _value)
        internal
        view
        returns (BucketLib.Account memory)
    {
        (uint256 log256, bytes32 mask) = uint256(_value).computeMask();
        bytes32 fullMask = _bitBuckets.bucketsMask;
        bytes32 nextMask = mask.nextBitMask(log256, fullMask);

        if (nextMask != 0) return _bitBuckets.buckets[nextMask].getHead();

        bytes32 prevMask = mask.prevBitMask(log256, fullMask);

        if (prevMask != 0) return _bitBuckets.buckets[prevMask].getHead();
        else return BucketLib.Account(address(0), 0);
    }

    /// PRIVATE ///

    function _remove(
        BitBuckets storage _bitBuckets,
        bytes32 _formerMask,
        address _id
    ) private {
        BucketLib.Bucket storage formerBucket = _bitBuckets.buckets[_formerMask];
        formerBucket.remove(_id);
        delete _bitBuckets.maskOf[_id];
        _bitBuckets.bucketsMask &= ~_formerMask;
    }

    function _insert(
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

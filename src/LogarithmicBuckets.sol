// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import "./BucketDLL.sol";

library LogarithmicBuckets {
    using BucketDLL for BucketDLL.List;

    struct BucketList {
        mapping(uint256 => BucketDLL.List) lists;
        mapping(bytes32 => uint256) valueOf;
        uint256 bucketsMask;
    }

    /// ERRORS ///

    /// @notice Thrown when the address is zero at insertion.
    error AddressIsZero();

    /// @notice Thrown when 0 value is inserted.
    error ZeroValue();

    /// INTERNAL ///

    /// @notice Updates an account in the `_buckets`.
    function update(
        BucketList storage _buckets,
        bytes32 _id,
        uint256 _newValue
    ) internal {
        if (_id == 0) revert AddressIsZero();
        uint256 value = _buckets.valueOf[_id];
        _buckets.valueOf[_id] = _newValue;

        if (value == 0) {
            if (_newValue == 0) revert ZeroValue();
            _insert(_buckets, _id, _computeBucket(_newValue));
            return;
        }

        uint256 currentBucket = _computeBucket(value);
        if (_newValue == 0) {
            _remove(_buckets, _id, currentBucket);
            return;
        }

        uint256 newBucket = _computeBucket(_newValue);
        if (newBucket != currentBucket) {
            _remove(_buckets, _id, currentBucket);
            _insert(_buckets, _id, newBucket);
        }
    }

    /// PRIVATE ///

    /// @notice Removes an account in the `_buckets`.
    /// @dev Does not update the value.
    /// @param _buckets The buckets to modify.
    /// @param _id The address of the account to remove.
    /// @param _bucket The mask of the bucket where to remove.
    function _remove(
        BucketList storage _buckets,
        bytes32 _id,
        uint256 _bucket
    ) private {
        if (_buckets.lists[_bucket].remove(_id))
            _buckets.bucketsMask &= _bucket ^ type(uint256).max;
    }

    /// @notice Inserts an account in the `_buckets`.
    /// @dev Expects that `_id` != 0 and `_value` != 0.
    /// @dev Does not update the value.
    /// @param _buckets The buckets to modify.
    /// @param _id The address of the account to update.
    /// @param _bucket The mask of the bucket where to insert.
    function _insert(
        BucketList storage _buckets,
        bytes32 _id,
        uint256 _bucket
    ) private {
        if (_buckets.lists[_bucket].insert(_id)) _buckets.bucketsMask |= _bucket;
    }

    /// @notice Returns the bucket in which the given value would fall.
    function _computeBucket(uint256 _value) private pure returns (uint256) {
        uint256 lowerMask = _setLowerBits(_value);
        return lowerMask ^ (lowerMask >> 1);
    }

    /// @notice Sets all the bits lower than (or equal to) the highest bit in the input.
    /// @dev This is the same as rounding the input the nearest upper value of the form `2 ** n - 1`.
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

    /// @notice Returns the following bucket which contains greater values.
    /// @dev The bucket returned is the lowest that is in `bucketsMask` and not in `lowerMask`.
    function _nextBucket(uint256 lowerMask, uint256 bucketsMask)
        private
        pure
        returns (uint256 bucket)
    {
        assembly {
            let higherBucketsMask := and(not(lowerMask), bucketsMask)
            bucket := and(higherBucketsMask, add(not(higherBucketsMask), 1))
        }
    }

    /// @notice Returns the preceding bucket which contains smaller values.
    /// @dev The bucket returned is the highest that is in both `bucketsMask` and `lowerMask`.
    function _prevBucket(uint256 lowerMask, uint256 bucketsMask) private pure returns (uint256) {
        uint256 lowerBucketsMask = _setLowerBits(lowerMask & bucketsMask);
        return lowerBucketsMask ^ (lowerBucketsMask >> 1);
    }

    /// @notice Returns the address at the head or at the tail of the double linked list.
    /// @param _list The list from which to get the first address.
    /// @param _getHead True to return the head, false to return the tail.
    function _getFirst(BucketDLL.List storage _list, bool _getHead) private view returns (bytes32) {
        if (_getHead) return _list.getHead();
        return _list.getTail();
    }

    /// GETTERS ///

    /// @notice Returns the value of `_id`.
    /// @param _buckets The buckets to search in.
    /// @param _id The address of the account.
    function getValueOf(BucketList storage _buckets, bytes32 _id) internal view returns (uint256) {
        return _buckets.valueOf[_id];
    }

    /// @notice Returns the bucket in which to look for `_value`.
    /// @param _buckets The buckets to search in.
    /// @param _value The value to look for.
    function getBucketOf(BucketList storage _buckets, uint256 _value)
        internal
        view
        returns (BucketDLL.List storage)
    {
        uint256 bucket = _computeBucket(_value);
        return _buckets.lists[bucket];
    }

    /// @notice Returns the address in `_buckets` that is a candidate for matching the value `_value`.
    /// @param _buckets The buckets to get the head.
    /// @param _value The value to match.
    /// @param _fifo Whether to treat the underlying data-structure as a FIFO (as opposed to a LIFO).
    /// @return The address of the head.
    function getMatch(
        BucketList storage _buckets,
        uint256 _value,
        bool _fifo
    ) internal view returns (bytes32) {
        uint256 bucketsMask = _buckets.bucketsMask;
        if (bucketsMask == 0) return 0;
        uint256 lowerMask = _setLowerBits(_value);

        uint256 next = _nextBucket(lowerMask, bucketsMask);
        if (next != 0) return _getFirst(_buckets.lists[next], _fifo);

        uint256 prev = _prevBucket(lowerMask, bucketsMask);
        return _getFirst(_buckets.lists[prev], _fifo);
    }
}

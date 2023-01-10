// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import "./UnsortedDLL.sol";

library LogarithmicBuckets {
    using UnsortedDLL for UnsortedDLL.List;

    struct BucketList {
        mapping(uint256 => UnsortedDLL.List) lists;
        mapping(address => uint256) valueOf;
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
        address _id,
        uint256 _newValue
    ) internal {
        uint256 value = _buckets.valueOf[_id];
        _buckets.valueOf[_id] = _newValue;

        if (value == 0) {
            // `_buckets` cannot contain the 0 address.
            if (_newValue == 0) revert ZeroValue();
            if (_id == address(0)) revert AddressIsZero();
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
        address _id,
        uint256 _bucket
    ) private {
        if (_buckets.lists[_bucket].remove(_id))
            _buckets.bucketsMask &= _bucket ^ type(uint256).max;
    }

    /// @notice Inserts an account in the `_buckets`.
    /// @dev Expects that `_id` != 0 and if `_value` != 0.
    /// @dev Does not update the value.
    /// @param _buckets The buckets to modify.
    /// @param _id The address of the account to update.
    /// @param _bucket The mask of the bucket where to insert.
    function _insert(
        BucketList storage _buckets,
        address _id,
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

    /// GETTERS ///

    /// @notice Returns the value of the account linked to `_id`.
    /// @param _buckets The buckets to search in.
    /// @param _id The address of the account.
    function getValueOf(BucketList storage _buckets, address _id) internal view returns (uint256) {
        return _buckets.valueOf[_id];
    }

    /// @notice Returns the bucket of the bucket linked to `_id`.
    /// @param _buckets The buckets to search in.
    /// @param _id The address of the account.
    function getBucketOf(BucketList storage _buckets, address _id) internal view returns (uint256) {
        return _computeBucket(_buckets.valueOf[_id]);
    }

    /// @notice Returns the value of the account linked to `_id`.
    /// @param _buckets The buckets to search in.
    function getMaxBucket(BucketList storage _buckets) internal view returns (uint256) {
        return _computeBucket(_buckets.bucketsMask);
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
    ) internal view returns (address) {
        uint256 lowerMask = _setLowerBits(_value);

        uint256 bucketsMask = _buckets.bucketsMask;
        uint256 next = _nextBucket(lowerMask, bucketsMask);

        if (next != 0) return _buckets.lists[next].getFirst(_fifo);

        uint256 prev = _prevBucket(lowerMask, bucketsMask);

        if (prev != 0) return _buckets.lists[prev].getFirst(_fifo);

        return address(0);
    }

    /// @notice Returns the account following `_id` in `_buckets`.
    /// @param _buckets The buckets to get the following account.
    /// @param _id The current address.
    /// @param _increasing True if starting from the lower buckets and going up to the higher buckets.
    /// @return The address of the next account.
    function getFollowing(
        BucketList storage _buckets,
        address _id,
        bool _increasing
    ) internal view returns (address) {
        uint256 value = _buckets.valueOf[_id];
        if (!_increasing && value == 0) value = type(uint256).max;
        uint256 bucket = _computeBucket(value);
        address following = _buckets.lists[bucket].getFollowing(_id, _increasing);

        if (following != address(0)) return following;

        uint256 bucketsMask = _buckets.bucketsMask;
        uint256 lowerMask = _setLowerBits(value);
        uint256 followingBucket;
        if (_increasing) followingBucket = _nextBucket(lowerMask, bucketsMask);
        else {
            lowerMask >>= 1;
            followingBucket = _prevBucket(lowerMask, bucketsMask);
        }

        return _buckets.lists[followingBucket].getFirst(_increasing);
    }
}

// SPDX-License-Identifier: GNU AGPLv3
pragma solidity ^0.8.0;

import "../lib/openzeppelin-contracts/contracts/utils/math/SafeCast.sol";
import "./BitTwiddling.sol";
import "./BucketLib.sol";

/// @title Bit buckets.
/// @author Morpho Labs.
/// @custom:contact security@morpho.xyz
/// @notice Buckets data-structure using bit tricks to achieve constant complexity.
library BitBucketsLib {
    using BitTwiddling for uint256;
    using BitTwiddling for bytes32;
    using BucketLib for BucketLib.Bucket;

    // Buckets are indexed by bit masks for efficiency. Valid bit masks 'byte addressed', meaning that valid masks are of the form '0xff << n' where n is a multiple of 8.
    struct BitBuckets {
        mapping(bytes32 => BucketLib.Bucket) buckets; // All the buckets indexed by their corresponding mask.
        mapping(address => uint256) balanceOf; // The mask of a given account.
        bytes32 bucketsMask; // The disjunction of the masks of all the buckets used.
    }

    /// ERRORS ///

    /// @notice Thrown when the address is zero at insertion.
    error AddressIsZero();

    /// INTERNAL ///

    /// @notice Updates an account in the `_bitBuckets`.
    /// @param _bitBuckets The bit buckets to modify.
    /// @param _id The address of the account to update.
    /// @param _newValue The new value of the account to update.
    function update(
        BitBuckets storage _bitBuckets,
        address _id,
        uint256 _newValue
    ) internal {
        if (_id == address(0)) revert AddressIsZero();

        (, bytes32 formerMask) = _bitBuckets.balanceOf[_id].computeMask();
        uint256 formerValue = _bitBuckets.balanceOf[_id];
        uint96 newValue = SafeCast.toUint96(_newValue);

        if (formerValue == newValue) return;

        if (_newValue == 0) _remove(_bitBuckets, formerMask, _id);
        else {
            (, bytes32 newMask) = _newValue.computeMask();
            if (formerValue == 0) _insert(_bitBuckets, newMask, _id, newValue);
            else if (newMask == formerMask) _bitBuckets.balanceOf[_id] = _newValue;
            else {
                _remove(_bitBuckets, formerMask, _id);
                _insert(_bitBuckets, newMask, _id, newValue);
            }
        }
    }

    /// @notice Returns the value of the account linked to `_id`.
    /// @param _bitBuckets The bit buckets to search in.
    /// @param _id The address of the account.
    /// @return The value of the account.
    function getValueOf(BitBuckets storage _bitBuckets, address _id)
        internal
        view
        returns (uint256)
    {
        return _bitBuckets.balanceOf[_id];
    }

    /// @notice Returns an address with value matching the input value.
    /// @param _bitBuckets The bit buckets to search in.
    /// @param _value The input value.
    /// @return The address of the with matching value.
    function getHead(BitBuckets storage _bitBuckets, uint96 _value)
        internal
        view
        returns (address)
    {
        (uint256 byte_offset, bytes32 mask) = uint256(_value).computeMask();
        bytes32 fullMask = _bitBuckets.bucketsMask;
        bytes32 nextMask = mask.nextBitMask(byte_offset, fullMask);

        if (nextMask != 0) return _bitBuckets.buckets[nextMask].getHead().id;

        bytes32 prevMask = mask.prevBitMask(byte_offset, fullMask);

        if (prevMask != 0) return _bitBuckets.buckets[prevMask].getHead().id;
        else return address(0);
    }

    /// PRIVATE ///

    /// @notice Removes an account in the `_bitBuckets`.
    /// @dev Only call when this function when `_id` is in the `_bitBuckets` with mask `_formerMask`.
    /// @param _bitBuckets The bit buckets in which to remove the account.
    /// @param _formerMask The mask of the account to remove.
    /// @param _id The address of the account to remove.
    function _remove(
        BitBuckets storage _bitBuckets,
        bytes32 _formerMask,
        address _id
    ) private {
        BucketLib.Bucket storage formerBucket = _bitBuckets.buckets[_formerMask];
        formerBucket.remove(_id);
        delete _bitBuckets.balanceOf[_id];
        if (formerBucket.getLength() == 0) _bitBuckets.bucketsMask &= ~_formerMask;
    }

    /// @notice Adds an account in the `_bitBuckets`.
    /// @dev Only call when this function when `_id` is not in the `_bitBuckets` and when the mask `_newMask` corresponds to value `_newValue`.
    /// @param _bitBuckets The bit buckets in which to add the account.
    /// @param _newMask The mask of the account to insert.
    /// @param _id The address of the account to insert.
    /// @param _newValue The value of the account to insert.
    function _insert(
        BitBuckets storage _bitBuckets,
        bytes32 _newMask,
        address _id,
        uint96 _newValue
    ) private {
        BucketLib.Bucket storage newBucket = _bitBuckets.buckets[_newMask];
        newBucket.insert(_id);
        _bitBuckets.balanceOf[_id] = _newValue;
        _bitBuckets.bucketsMask |= _newMask;
    }
}

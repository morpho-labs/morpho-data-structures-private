// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.13;

import "./Random.sol";
import "forge-std/Test.sol";
import "./ConcreteBitBuckets.sol";

abstract contract TestRandomBuckets is Test, Random {
    ConcreteBitBuckets public bitBuckets;

    address[] public ids;

    uint256 public n = 50000;
    uint256 public maxSortedUsers;

    function insert() public {
        address id = randomAddress();
        ids.push(id);
        uint256 rdm = randomUint256(type(uint96).max);
        if (rdm == 0) revert("Random gave back 0.");

        bitBuckets.update(id, rdm);
    }

    function remove() public {
        uint256 index = randomUint256(ids.length);
        address toRemove = ids[index];

        bitBuckets.update(toRemove, 0);

        ids[index] = ids[ids.length - 1];
        ids.pop();
    }

    function increase() public {
        uint256 index = randomUint256(ids.length);
        address toUpdate = ids[index];
        uint256 formerValue = bitBuckets.getValueOf(toUpdate);

        uint256 rdm = formerValue + randomUint256(type(uint96).max - formerValue);
        if (rdm == 0) revert("Random gave back 0.");

        bitBuckets.update(toUpdate, rdm);
    }

    function decrease() public {
        uint256 index = randomUint256(ids.length);
        address toUpdate = ids[index];
        uint256 formerValue = bitBuckets.getValueOf(toUpdate);

        uint256 rdm = randomUint256(formerValue);
        if (rdm == 0) revert("Random gave back 0.");

        bitBuckets.update(toUpdate, rdm);
    }

    function testBitBucketsStructure() public {
        for (uint256 i; i < n; i++) {
            if (ids.length == 0) insert();
            else {
                uint256 r = randomUint256(5);
                if (r < 2) insert();
                else if (r == 2) remove();
                else if (r == 3) increase();
                else decrease();
            }
        }

        bitBuckets.verifyStructure();
    }
}

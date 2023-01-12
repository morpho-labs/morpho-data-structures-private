// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "./mocks/LogarithmicBucketsMock.sol";

contract TestLogarithmicBuckets is LogarithmicBucketsMock, Test {
    using BucketDLL for BucketDLL.List;
    using LogarithmicBuckets for LogarithmicBuckets.BucketList;

    uint256 public NDS = 50;
    uint128[] public accounts;
    uint128 public ADDR_ZERO = uint128(0);

    function setUp() public {
        accounts = new uint128[](NDS);
        accounts[0] = uint128(bytes16(keccak256("TestLogarithmicBuckets.accounts")));
        for (uint256 i = 1; i < NDS; i++) {
            accounts[i] = accounts[i - 1] + 1;
        }
    }

    function testEmpty(uint256 _value, bool _fifo) public {
        assertEq(bucketList.getMatch(_value, _fifo), uint128(0));
    }

    function testInsertOneSingleAccount() public {
        bucketList.update(accounts[0], 3);

        assertEq(bucketList.getValueOf(accounts[0]), 3);
        assertEq(bucketList.getMatch(0, true), accounts[0]);
        assertEq(bucketList.getBucketOf(3).getHead(), accounts[0]);
        assertEq(bucketList.getBucketOf(2).getHead(), accounts[0]);
    }

    function testUpdatingFromZeroToZeroShouldRevert() public {
        vm.expectRevert(abi.encodeWithSignature("ZeroValue()"));
        bucketList.update(accounts[0], 0);
    }

    function testShouldNotInsertZeroAddress() public {
        vm.expectRevert(abi.encodeWithSignature("AddressIsZero()"));
        bucketList.update(uint128(0), 10);
    }

    function testShouldHaveTheRightOrderWithinABucket() public {
        bucketList.update(accounts[0], 16);
        bucketList.update(accounts[1], 16);
        bucketList.update(accounts[2], 16);

        BucketDLL.List storage list = bucketList.getBucketOf(16);
        uint128 head = list.getNext(uint128(0));
        uint128 next1 = list.getNext(head);
        uint128 next2 = list.getNext(next1);
        assertEq(head, accounts[0]);
        assertEq(next1, accounts[1]);
        assertEq(next2, accounts[2]);
    }

    function testInsertRemoveOneSingleAccount() public {
        bucketList.update(accounts[0], 1);
        bucketList.update(accounts[0], 0);

        assertEq(bucketList.getValueOf(accounts[0]), 0);
        assertEq(bucketList.getMatch(0, true), uint128(0));
        assertEq(bucketList.getBucketOf(1).getHead(), uint128(0));
    }

    function testShouldInsertTwoAccounts() public {
        bucketList.update(accounts[0], 16);
        bucketList.update(accounts[1], 4);

        assertEq(bucketList.getMatch(16, true), accounts[0]);
        assertEq(bucketList.getMatch(2, true), accounts[1]);
        assertEq(bucketList.getBucketOf(4).getHead(), accounts[1]);
    }

    function testShouldRemoveOneAccountOverTwo() public {
        bucketList.update(accounts[0], 4);
        bucketList.update(accounts[1], 16);
        bucketList.update(accounts[0], 0);

        assertEq(bucketList.getMatch(4, true), accounts[1]);
        assertEq(bucketList.getValueOf(accounts[0]), 0);
        assertEq(bucketList.getValueOf(accounts[1]), 16);
        assertEq(bucketList.getBucketOf(16).getHead(), accounts[1]);
        assertEq(bucketList.getBucketOf(4).getHead(), uint128(0));
    }

    function testShouldRemoveBothAccounts() public {
        bucketList.update(accounts[0], 4);
        bucketList.update(accounts[1], 4);
        bucketList.update(accounts[0], 0);
        bucketList.update(accounts[1], 0);

        assertEq(bucketList.getMatch(4, true), uint128(0));
    }

    function testGetMatch() public {
        assertEq(bucketList.getMatch(0, true), uint128(0));
        assertEq(bucketList.getMatch(1000, true), uint128(0));

        bucketList.update(accounts[0], 16);
        assertEq(bucketList.getMatch(1, true), accounts[0], "head before");
        assertEq(bucketList.getMatch(16, true), accounts[0], "head equal");
        assertEq(bucketList.getMatch(32, true), accounts[0], "head above");
    }
}

// SPDX-License-Identifier: GNU AGPLv3
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "./helpers/ConcreteBitBuckets.sol";

contract TestBitBuckets is Test {
    ConcreteBitBuckets public bitBuckets = new ConcreteBitBuckets();

    uint256 public NDS = 50;
    address[] public accounts;
    address public ADDR_ZERO = address(0);

    function setUp() public {
        accounts = new address[](NDS);
        accounts[0] = address(this);
        for (uint256 i = 1; i < NDS; i++) {
            accounts[i] = address(uint160(accounts[i - 1]) + 1);
        }
    }

    function testInsertOneSingleAccount() public {
        bitBuckets.update(accounts[0], 1);

        assertEq(bitBuckets.getValueOf(accounts[0]), 1);
        assertEq(bitBuckets.getHead(0), accounts[0]);
        // assertEq(bitBuckets.getMaxIndex(), 0);
        // assertEq(bitBuckets.getBucketOf(accounts[0]), 0);
    }

    function testUpdatingFromZeroToZeroShouldNotInsert() public {
        bitBuckets.update(accounts[0], 0);
        assertEq(bitBuckets.getHead(0), address(0));
    }

    function testShouldNotInsertZeroAddress() public {
        vm.expectRevert(abi.encodeWithSignature("AddressIsZero()"));
        bitBuckets.update(address(0), 10);
    }

    function testInsertRemoveOneSingleAccount() public {
        bitBuckets.update(accounts[0], 1);
        bitBuckets.update(accounts[0], 0);

        // assertEq(bitBuckets.getValueOf(accounts[0]), 0);
        assertEq(bitBuckets.getHead(0), address(0));
        // assertEq(bitBuckets.getMaxIndex(), 0);
        // assertEq(bitBuckets.getBucketOf(accounts[0]), 0);
    }

    function testShouldInsertTwoAccounts() public {
        bitBuckets.update(accounts[0], 16);
        bitBuckets.update(accounts[1], 4);

        assertEq(bitBuckets.getHead(16), accounts[0]);
        assertEq(bitBuckets.getHead(4), accounts[1]);
        // assertEq(bitBuckets.getMaxIndex(), 2);
    }

    function testShouldRemoveOneAccountOverTwo() public {
        bitBuckets.update(accounts[0], 4);
        bitBuckets.update(accounts[1], 16);
        bitBuckets.update(accounts[0], 0);

        assertEq(bitBuckets.getHead(4), accounts[1]);
        assertEq(bitBuckets.getValueOf(accounts[0]), 0);
        assertEq(bitBuckets.getValueOf(accounts[1]), 16);
        // assertEq(bitBuckets.getMaxIndex(), 2);
    }

    function testShouldRemoveBothAccounts() public {
        bitBuckets.update(accounts[0], 4);
        bitBuckets.update(accounts[1], 4);
        bitBuckets.update(accounts[0], 0);
        bitBuckets.update(accounts[1], 0);

        assertEq(bitBuckets.getHead(4), address(0));
    }

    // function testGetMaxIndex() public {
    //     bitBuckets.update(accounts[0], 1);
    //     assertEq(bitBuckets.getMaxIndex(), 0);
    //     bitBuckets.update(accounts[1], 2);
    //     assertEq(bitBuckets.getMaxIndex(), 0);
    //     bitBuckets.update(accounts[2], 4);
    //     assertEq(bitBuckets.getMaxIndex(), 1);
    //     bitBuckets.update(accounts[3], 16);
    //     assertEq(bitBuckets.getMaxIndex(), 2);
    //     bitBuckets.update(accounts[3], 0);
    //     assertEq(bitBuckets.getMaxIndex(), 1);
    //     bitBuckets.update(accounts[2], 0);
    //     assertEq(bitBuckets.getMaxIndex(), 0);
    //     bitBuckets.update(accounts[1], 0);
    //     assertEq(bitBuckets.getMaxIndex(), 0);
    // }

    function testGetHead() public {
        assertEq(bitBuckets.getHead(0), address(0));
        assertEq(bitBuckets.getHead(1000), address(0));

        bitBuckets.update(accounts[0], 16);
        assertEq(bitBuckets.getHead(1), accounts[0]);
        assertEq(bitBuckets.getHead(16), accounts[0]);
        assertEq(bitBuckets.getHead(32), accounts[0]);
    }
}

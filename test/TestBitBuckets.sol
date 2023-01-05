// SPDX-License-Identifier: GNU AGPLv3
pragma solidity ^0.8.0;

import "./helpers/TestRandomBuckets.sol";

contract TestBitBuckets is TestRandomBuckets {
    uint256 public accountsLength = 50;
    address[] public accounts;
    address public constant ADDR_ZERO = address(0);
    bytes32 public firstMask;

    function setUp() public {
        bitBuckets = new ConcreteBitBuckets();
        accounts = new address[](accountsLength);
        accounts[0] = address(this);
        for (uint256 i = 1; i < accountsLength; i++) {
            accounts[i] = address(uint160(accounts[i - 1]) + 1);
        }
        firstMask = BitTwiddling.FIRST_MASK;
    }

    function testInsertOneSingleAccount() public {
        bitBuckets.update(accounts[0], 1);

        assertEq(bitBuckets.getValueOf(accounts[0]), 1);
        assertEq(bitBuckets.getHead(0), accounts[0]);
        assertEq(bitBuckets.getBucketsMask(), firstMask);
        assertEq(bitBuckets.getMaskOf(accounts[0]), firstMask);
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

        assertEq(bitBuckets.getValueOf(accounts[0]), 0);
        assertEq(bitBuckets.getHead(0), address(0));
        assertEq(bitBuckets.getBucketsMask(), 0);
        assertEq(bitBuckets.getMaskOf(accounts[0]), 0);
    }

    function testShouldInsertTwoAccounts() public {
        bitBuckets.update(accounts[0], 2**16);
        bitBuckets.update(accounts[1], 2**8);

        assertEq(bitBuckets.getHead(2**8), accounts[0], "fetch big account");
        assertEq(bitBuckets.getHead(2**4), accounts[1], "fetch small account");
        assertEq(bitBuckets.getBucketsMask(), (firstMask << 16) | (firstMask << 8));
    }

    function testShouldRemoveOneAccountOverTwo() public {
        bitBuckets.update(accounts[0], 4);
        bitBuckets.update(accounts[1], 16);
        bitBuckets.update(accounts[0], 0);

        assertEq(bitBuckets.getHead(4), accounts[1]);
        assertEq(bitBuckets.getValueOf(accounts[0]), 0);
        assertEq(bitBuckets.getValueOf(accounts[1]), 16);
    }

    function testShouldRemoveBothAccounts() public {
        bitBuckets.update(accounts[0], 4);
        bitBuckets.update(accounts[1], 4);
        bitBuckets.update(accounts[0], 0);
        bitBuckets.update(accounts[1], 0);

        assertEq(bitBuckets.getHead(4), address(0));
    }

    function testBucketsMask() public {
        bitBuckets.update(accounts[0], 2**0);
        bytes32 firstExpectedMask = firstMask;
        assertEq(bitBuckets.getBucketsMask(), firstExpectedMask);

        bitBuckets.update(accounts[1], 2**8);
        bytes32 secondExpectedMask = firstExpectedMask | (firstMask << 8);
        assertEq(bitBuckets.getBucketsMask(), secondExpectedMask);

        bitBuckets.update(accounts[2], 2**16);
        bytes32 thirdExpectedMask = secondExpectedMask | (firstMask << 16);
        assertEq(bitBuckets.getBucketsMask(), thirdExpectedMask);

        bitBuckets.update(accounts[2], 0);
        assertEq(bitBuckets.getBucketsMask(), secondExpectedMask);

        bitBuckets.update(accounts[1], 0);
        assertEq(bitBuckets.getBucketsMask(), firstExpectedMask);

        bitBuckets.update(accounts[0], 0);
        assertEq(bitBuckets.getBucketsMask(), 0);
    }

    function testGetHead() public {
        assertEq(bitBuckets.getHead(0), address(0));
        assertEq(bitBuckets.getHead(1000), address(0));

        bitBuckets.update(accounts[0], 1000);
        assertEq(bitBuckets.getHead(1), accounts[0]);
        assertEq(bitBuckets.getHead(1000), accounts[0]);
        assertEq(bitBuckets.getHead(32), accounts[0]);
    }
}

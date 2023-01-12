// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/BucketDLL.sol";

contract TestBucketDLL is Test {
    using BucketDLL for BucketDLL.List;

    uint256 internal numberOfAccounts = 50;
    bytes32[] public accounts;

    BucketDLL.List internal list;

    function setUp() public {
        accounts = new bytes32[](numberOfAccounts);
        accounts[0] = bytes32(bytes16(keccak256("TestBucketDLL.accounts")));
        for (uint256 i = 1; i < numberOfAccounts; i++) {
            accounts[i] = bytes32(uint256(accounts[i - 1]) + 1);
        }
    }

    function testInsertOneSingleAccount(bytes32 _account) public {
        vm.assume(_account != 0);

        list.insert(_account);
        assertEq(list.getHead(), _account);
        assertEq(list.getTail(), _account);
        assertEq(list.getPrev(_account), 0);
        assertEq(list.getNext(_account), 0);
    }

    function testShouldRemoveOneSingleAccount(bytes32 _account) public {
        vm.assume(_account != 0);

        list.insert(_account);
        list.remove(_account);

        assertEq(list.getHead(), 0);
        assertEq(list.getTail(), 0);
        assertEq(list.getPrev(_account), 0);
        assertEq(list.getNext(_account), 0);
    }

    function testShouldInsertTwoAccounts(bytes32 _account0, bytes32 _account1) public {
        vm.assume(_account0 != 0 && _account1 != 0);
        vm.assume(_account0 != _account1);

        list.insert(_account0);
        list.insert(_account1);

        assertEq(list.getHead(), _account0);
        assertEq(list.getTail(), _account1);
        assertEq(list.getPrev(_account0), 0);
        assertEq(list.getNext(_account0), _account1);
        assertEq(list.getPrev(_account1), _account0);
        assertEq(list.getNext(_account1), 0);
    }

    function testShouldInsertThreeAccounts(
        bytes32 _account0,
        bytes32 _account1,
        bytes32 _account2
    ) public {
        vm.assume(_account0 != 0 && _account1 != 0 && _account2 != 0);
        vm.assume(_account0 != _account1 && _account1 != _account2 && _account2 != _account0);

        list.insert(_account0);
        list.insert(_account1);
        list.insert(_account2);

        assertEq(list.getHead(), _account0);
        assertEq(list.getTail(), _account2);
        assertEq(list.getPrev(_account0), 0);
        assertEq(list.getNext(_account0), _account1);
        assertEq(list.getPrev(_account1), _account0);
        assertEq(list.getNext(_account1), _account2);
        assertEq(list.getPrev(_account2), _account1);
        assertEq(list.getNext(_account2), 0);
    }

    function testShouldRemoveOneAccountOverTwo(bytes32 _account0, bytes32 _account1) public {
        vm.assume(_account0 != 0 && _account1 != 0);
        vm.assume(_account0 != _account1);

        list.insert(_account0);
        list.insert(_account1);
        list.remove(_account0);

        assertEq(list.getHead(), _account1);
        assertEq(list.getTail(), _account1);
        assertEq(list.getPrev(_account0), 0);
        assertEq(list.getNext(_account0), 0);
        assertEq(list.getPrev(_account1), 0);
        assertEq(list.getNext(_account1), 0);
    }

    function testShouldRemoveBothAccounts(bytes32 _account0, bytes32 _account1) public {
        vm.assume(_account0 != 0 && _account1 != 0);
        vm.assume(_account0 != _account1);

        list.insert(_account0);
        list.insert(_account1);
        list.remove(_account0);
        list.remove(_account1);

        assertEq(list.getHead(), 0);
        assertEq(list.getTail(), 0);
    }

    function testShouldInsertThreeAccountsAndRemoveThem(
        bytes32 _account0,
        bytes32 _account1,
        bytes32 _account2
    ) public {
        vm.assume(_account0 != 0 && _account1 != 0 && _account2 != 0);
        vm.assume(_account0 != _account1 && _account1 != _account2 && _account2 != _account0);

        list.insert(_account0);
        list.insert(_account1);
        list.insert(_account2);

        assertEq(list.getHead(), _account0);
        assertEq(list.getTail(), _account2);

        // Remove account 1.
        list.remove(_account1);
        assertEq(list.getHead(), _account0);
        assertEq(list.getTail(), _account2);
        assertEq(list.getPrev(_account0), 0);
        assertEq(list.getNext(_account0), _account2);

        assertEq(list.getPrev(_account2), _account0);
        assertEq(list.getNext(_account2), 0);

        // Remove account 0.
        list.remove(_account0);
        assertEq(list.getHead(), _account2);
        assertEq(list.getTail(), _account2);
        assertEq(list.getPrev(_account2), 0);
        assertEq(list.getNext(_account2), 0);

        // Remove account 2.
        list.remove(_account2);
        assertEq(list.getHead(), 0);
        assertEq(list.getTail(), 0);
    }

    function testShouldInsertAccountsInFIFOOrder() public {
        for (uint256 i = 0; i < accounts.length; i++) {
            list.insert(accounts[i]);
        }

        assertEq(list.getHead(), accounts[0]);
        assertEq(list.getTail(), accounts[accounts.length - 1]);

        bytes32 nextAccount = accounts[0];
        for (uint256 i = 0; i < accounts.length - 1; i++) {
            nextAccount = list.getNext(nextAccount);
            assertEq(nextAccount, accounts[i + 1]);
        }

        bytes32 prevAccount = accounts[accounts.length - 1];
        for (uint256 i = accounts.length - 2; i > 0; i--) {
            prevAccount = list.getPrev(prevAccount);
            assertEq(prevAccount, accounts[i]);
        }
    }

    function testShouldRemoveAllAccounts() public {
        for (uint256 i = 0; i < accounts.length; i++) {
            list.insert(accounts[i]);
        }

        for (uint256 i = 0; i < accounts.length; i++) {
            list.remove(accounts[i]);
        }

        assertEq(list.getHead(), 0);
        assertEq(list.getTail(), 0);
    }
}

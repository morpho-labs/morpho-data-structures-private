// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/DoubleLinkedList.sol";

contract TestDoubleLinkedList is Test {
    using DoubleLinkedList for DoubleLinkedList.List;

    uint256 public NDS = 50;
    address[] public accounts;
    address public ADDR_ZERO = address(0);

    DoubleLinkedList.List public list;

    function setUp() public {
        accounts = new address[](NDS);
        accounts[0] = address(bytes20(keccak256("TestDoubleLinkedList.accounts")));
        for (uint256 i = 1; i < NDS; i++) {
            accounts[i] = address(uint160(accounts[i - 1]) + 1);
        }
    }

    function testInsertOneSingleAccount() public {
        list.insertSorted(accounts[0], 1, NDS);

        assertEq(list.getHead(), accounts[0]);
        assertEq(list.getTail(), accounts[0]);
        assertEq(list.getValueOf(accounts[0]), 1);
        assertEq(list.getPrev(accounts[0]), ADDR_ZERO);
        assertEq(list.getNext(accounts[0]), ADDR_ZERO);
    }

    function testShouldNotInsertAccountWithZeroValue() public {
        vm.expectRevert(abi.encodeWithSignature("ValueIsZero()"));
        list.insertSorted(accounts[0], 0, NDS);
    }

    function testShouldNotInsertZeroAddress() public {
        vm.expectRevert(abi.encodeWithSignature("AddressIsZero()"));
        list.insertSorted(address(0), 10, NDS);
    }

    function testShouldNotRemoveAccountThatDoesNotExist() public {
        vm.expectRevert(abi.encodeWithSignature("AccountDoesNotExist()"));
        list.remove(accounts[0]);
    }

    function testShouldInsertSeveralTimesTheSameAccount() public {
        list.insertSorted(accounts[0], 1, NDS);
        vm.expectRevert(abi.encodeWithSignature("AccountAlreadyInserted()"));
        list.insertSorted(accounts[0], 2, NDS);
    }

    function testShouldHaveTheRightOrder() public {
        list.insertSorted(accounts[0], 20, NDS);
        list.insertSorted(accounts[1], 40, NDS);
        assertEq(list.getHead(), accounts[1]);
        assertEq(list.getTail(), accounts[0]);
    }

    function testShouldRemoveOneSingleAccount() public {
        list.insertSorted(accounts[0], 1, NDS);
        list.remove(accounts[0]);

        assertEq(list.getHead(), ADDR_ZERO);
        assertEq(list.getTail(), ADDR_ZERO);
        assertEq(list.getValueOf(accounts[0]), 0);
        assertEq(list.getPrev(accounts[0]), ADDR_ZERO);
        assertEq(list.getNext(accounts[0]), ADDR_ZERO);
    }

    function testShouldInsertTwoAccounts() public {
        list.insertSorted(accounts[0], 2, NDS);
        list.insertSorted(accounts[1], 1, NDS);

        assertEq(list.getHead(), accounts[0]);
        assertEq(list.getTail(), accounts[1]);
        assertEq(list.getValueOf(accounts[0]), 2);
        assertEq(list.getValueOf(accounts[1]), 1);
        assertEq(list.getPrev(accounts[0]), ADDR_ZERO);
        assertEq(list.getNext(accounts[0]), accounts[1]);
        assertEq(list.getPrev(accounts[1]), accounts[0]);
        assertEq(list.getNext(accounts[1]), ADDR_ZERO);
    }

    function testShouldInsertThreeAccounts() public {
        list.insertSorted(accounts[0], 3, NDS);
        list.insertSorted(accounts[1], 2, NDS);
        list.insertSorted(accounts[2], 1, NDS);

        assertEq(list.getHead(), accounts[0]);
        assertEq(list.getTail(), accounts[2]);
        assertEq(list.getValueOf(accounts[0]), 3);
        assertEq(list.getValueOf(accounts[1]), 2);
        assertEq(list.getValueOf(accounts[2]), 1);
        assertEq(list.getPrev(accounts[0]), ADDR_ZERO);
        assertEq(list.getNext(accounts[0]), accounts[1]);
        assertEq(list.getPrev(accounts[1]), accounts[0]);
        assertEq(list.getNext(accounts[1]), accounts[2]);
        assertEq(list.getPrev(accounts[2]), accounts[1]);
        assertEq(list.getNext(accounts[2]), ADDR_ZERO);
    }

    function testShouldRemoveOneAccountOverTwo() public {
        list.insertSorted(accounts[0], 2, NDS);
        list.insertSorted(accounts[1], 1, NDS);
        list.remove(accounts[0]);

        assertEq(list.getHead(), accounts[1]);
        assertEq(list.getTail(), accounts[1]);
        assertEq(list.getValueOf(accounts[0]), 0);
        assertEq(list.getValueOf(accounts[1]), 1);
        assertEq(list.getPrev(accounts[1]), ADDR_ZERO);
        assertEq(list.getNext(accounts[1]), ADDR_ZERO);
    }

    function testShouldRemoveBothAccounts() public {
        list.insertSorted(accounts[0], 2, NDS);
        list.insertSorted(accounts[1], 1, NDS);
        list.remove(accounts[0]);
        list.remove(accounts[1]);

        assertEq(list.getHead(), ADDR_ZERO);
        assertEq(list.getTail(), ADDR_ZERO);
    }

    function testShouldInsertThreeAccountsAndRemoveThem() public {
        list.insertSorted(accounts[0], 3, NDS);
        list.insertSorted(accounts[1], 2, NDS);
        list.insertSorted(accounts[2], 1, NDS);

        assertEq(list.getHead(), accounts[0]);
        assertEq(list.getTail(), accounts[2]);

        // Remove account 0.
        list.remove(accounts[0]);
        assertEq(list.getHead(), accounts[1]);
        assertEq(list.getTail(), accounts[2]);
        assertEq(list.getPrev(accounts[1]), ADDR_ZERO);
        assertEq(list.getNext(accounts[1]), accounts[2]);

        assertEq(list.getPrev(accounts[2]), accounts[1]);
        assertEq(list.getNext(accounts[2]), ADDR_ZERO);

        // Remove account 1.
        list.remove(accounts[1]);
        assertEq(list.getHead(), accounts[2]);
        assertEq(list.getTail(), accounts[2]);
        assertEq(list.getPrev(accounts[2]), ADDR_ZERO);
        assertEq(list.getNext(accounts[2]), ADDR_ZERO);

        // Remove account 2.
        list.remove(accounts[2]);
        assertEq(list.getHead(), ADDR_ZERO);
        assertEq(list.getTail(), ADDR_ZERO);
    }

    function testShouldInsertAccountsAllSorted() public {
        for (uint256 i = 0; i < accounts.length; i++) {
            list.insertSorted(accounts[i], NDS - i, NDS);
        }

        assertEq(list.getHead(), accounts[0]);
        assertEq(list.getTail(), accounts[accounts.length - 1]);

        address nextAccount = accounts[0];
        for (uint256 i = 0; i < accounts.length - 1; i++) {
            nextAccount = list.getNext(nextAccount);
            assertEq(nextAccount, accounts[i + 1]);
        }

        address prevAccount = accounts[accounts.length - 1];
        for (uint256 i = 0; i < accounts.length - 1; i++) {
            prevAccount = list.getPrev(prevAccount);
            assertEq(prevAccount, accounts[accounts.length - i - 2]);
        }
    }

    function testShouldRemoveAllSortedAccount() public {
        for (uint256 i = 0; i < accounts.length; i++) {
            list.insertSorted(accounts[i], NDS - i, NDS);
        }

        for (uint256 i = 0; i < accounts.length; i++) {
            list.remove(accounts[i]);
        }

        assertEq(list.getHead(), ADDR_ZERO);
        assertEq(list.getTail(), ADDR_ZERO);
    }

    function testShouldInsertAccountSortedAtTheBeginningUntilNDS() public {
        uint256 value = 50;
        uint256 newNDS = 10;

        // Add first 10 accounts with decreasing value.
        for (uint256 i = 0; i < 10; i++) {
            list.insertSorted(accounts[i], value - i, newNDS);
        }

        assertEq(list.getHead(), accounts[0]);
        assertEq(list.getTail(), accounts[9]);

        address nextAccount = accounts[0];
        for (uint256 i = 0; i < 9; i++) {
            nextAccount = list.getNext(nextAccount);
            assertEq(nextAccount, accounts[i + 1]);
        }

        address prevAccount = accounts[9];
        for (uint256 i = 0; i < 9; i++) {
            prevAccount = list.getPrev(prevAccount);
            assertEq(prevAccount, accounts[10 - i - 2]);
        }

        // Add last 10 accounts at the same value.
        for (uint256 i = accounts.length - 10; i < NDS; i++) {
            list.insertSorted(accounts[i], 10, newNDS);
        }

        assertEq(list.getHead(), accounts[0]);
        assertEq(list.getTail(), accounts[accounts.length - 1]);

        nextAccount = accounts[0];
        for (uint256 i = 0; i < 9; i++) {
            nextAccount = list.getNext(nextAccount);
            assertEq(nextAccount, accounts[i + 1]);
        }

        prevAccount = accounts[9];
        for (uint256 i = 0; i < 9; i++) {
            prevAccount = list.getPrev(prevAccount);
            assertEq(prevAccount, accounts[10 - i - 2]);
        }
    }
}

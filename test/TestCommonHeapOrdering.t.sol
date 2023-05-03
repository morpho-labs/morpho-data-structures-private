// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import "src/HeapOrdering.sol";
import "./helpers/RandomHeap.sol";

abstract contract TestCommonHeapOrdering is RandomHeap {
    address[] public accounts;
    uint256 public NB_ACCOUNTS = 50;
    uint256 public MAX_SORTED_USERS = 50;
    address public ADDR_ZERO = address(0);

    function update(
        address _id,
        uint256 _formerValue,
        uint256 _newValue
    ) public {
        heap.update(_id, _formerValue, _newValue, MAX_SORTED_USERS);
    }

    function setUp() public {
        accounts = new address[](NB_ACCOUNTS);
        accounts[0] = address(bytes20(keccak256("TestCommonHeapOrdering.accounts")));
        for (uint256 i = 1; i < NB_ACCOUNTS; i++) {
            accounts[i] = address(uint160(accounts[i - 1]) + 1);
        }
    }

    // Should give elements in decreasing order if maxSortedUsers is +infinity.
    function testFullHeapSort() public {
        maxSortedUsers = n;
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

        uint256 lastValue = type(uint256).max;
        uint256 newValue;
        while ((newValue = removeHead()) != 0) {
            require(newValue <= lastValue, "Elements are not given back in a decreasing order.");
            lastValue = newValue;
        }
    }

    function testEmpty() public {
        assertEq(heap.size(), 0);
        assertEq(heap.length(), 0);
        assertEq(heap.getValueOf(accounts[0]), 0);
        assertEq(heap.getHead(), ADDR_ZERO);
        assertEq(heap.getTail(), ADDR_ZERO);
        assertEq(heap.getPrev(accounts[0]), ADDR_ZERO);
        assertEq(heap.getNext(accounts[0]), ADDR_ZERO);
    }

    function testInsertOneSingleAccount() public {
        update(accounts[0], 0, 1);

        assertEq(heap.size(), 1);
        assertEq(heap.length(), 1);
        assertEq(heap.getValueOf(accounts[0]), 1);
        assertEq(heap.getHead(), accounts[0]);
        assertEq(heap.getTail(), accounts[0]);
        assertEq(heap.getPrev(accounts[0]), ADDR_ZERO);
        assertEq(heap.getNext(accounts[0]), ADDR_ZERO);

        assertEq(heap.getValueOf(accounts[1]), 0);
    }

    function testShouldNotInsertAccountWithZeroValue() public {
        update(accounts[0], 0, 0);
        assertEq(heap.size(), 0);
        assertEq(heap.length(), 0);
    }

    function testShouldNotInsertZeroAddress() public {
        vm.expectRevert(abi.encodeWithSignature("AddressIsZero()"));
        update(address(0), 0, 10);
    }

    function testShouldInsertSeveralTimesTheSameAccount() public {
        update(accounts[0], 0, 1);
        update(accounts[0], 1, 2);
        assertEq(heap.size(), 1);
        assertEq(heap.length(), 1);
        assertEq(heap.getValueOf(accounts[0]), 2);
        assertEq(heap.getHead(), accounts[0]);
        assertEq(heap.getTail(), accounts[0]);
        assertEq(heap.getPrev(accounts[0]), ADDR_ZERO);
        assertEq(heap.getNext(accounts[0]), ADDR_ZERO);
    }

    function testShouldHaveTheRightOrder() public {
        update(accounts[0], 0, 20);
        update(accounts[1], 0, 40);
        assertEq(heap.size(), 2);
        assertEq(heap.length(), 2);
        assertEq(heap.getHead(), accounts[1]);
        assertEq(heap.getTail(), accounts[0]);
        assertEq(heap.getPrev(accounts[0]), accounts[1]);
        assertEq(heap.getNext(accounts[1]), accounts[0]);
    }

    function testShouldRemoveOneSingleAccount() public {
        update(accounts[0], 0, 1);
        update(accounts[0], 1, 0);

        assertEq(heap.size(), 0);
        assertEq(heap.length(), 0);
        assertEq(heap.getHead(), ADDR_ZERO);
        assertEq(heap.getTail(), ADDR_ZERO);
        assertEq(heap.getValueOf(accounts[0]), 0);
        assertEq(heap.getPrev(accounts[0]), ADDR_ZERO);
        assertEq(heap.getNext(accounts[0]), ADDR_ZERO);
    }

    function testShouldInsertTwoAccounts() public {
        update(accounts[0], 0, 2);
        update(accounts[1], 0, 1);

        assertEq(heap.size(), 2);
        assertEq(heap.length(), 2);
        assertEq(heap.getHead(), accounts[0]);
        assertEq(heap.getTail(), accounts[1]);
        assertEq(heap.getValueOf(accounts[0]), 2);
        assertEq(heap.getValueOf(accounts[1]), 1);
        assertEq(heap.getPrev(accounts[0]), ADDR_ZERO);
        assertEq(heap.getNext(accounts[0]), accounts[1]);
        assertEq(heap.getPrev(accounts[1]), accounts[0]);
        assertEq(heap.getNext(accounts[1]), ADDR_ZERO);

        assertEq(heap.getNext(accounts[2]), ADDR_ZERO);
        assertEq(heap.getPrev(accounts[2]), ADDR_ZERO);
    }

    function testShouldInsertThreeAccounts() public {
        update(accounts[0], 0, 3);
        update(accounts[1], 0, 2);
        update(accounts[2], 0, 1);

        assertEq(heap.getHead(), accounts[0]);
        assertEq(heap.getTail(), accounts[2]);
        assertEq(heap.getValueOf(accounts[0]), 3);
        assertEq(heap.getValueOf(accounts[1]), 2);
        assertEq(heap.getValueOf(accounts[2]), 1);
        assertEq(heap.getPrev(accounts[0]), ADDR_ZERO);
        assertEq(heap.getNext(accounts[0]), accounts[1]);
        assertEq(heap.getPrev(accounts[1]), accounts[0]);
        assertEq(heap.getNext(accounts[1]), accounts[2]);
        assertEq(heap.getPrev(accounts[2]), accounts[1]);
        assertEq(heap.getNext(accounts[2]), ADDR_ZERO);
    }

    function testShouldRemoveOneAccountOverTwo() public {
        update(accounts[0], 0, 2);
        update(accounts[1], 0, 1);
        update(accounts[0], 2, 0);

        assertEq(heap.size(), 1);
        assertEq(heap.length(), 1);
        assertEq(heap.getHead(), accounts[1]);
        assertEq(heap.getTail(), accounts[1]);
        assertEq(heap.getValueOf(accounts[0]), 0);
        assertEq(heap.getValueOf(accounts[1]), 1);
        assertEq(heap.getPrev(accounts[1]), ADDR_ZERO);
        assertEq(heap.getNext(accounts[1]), ADDR_ZERO);
    }

    function testShouldRemoveBothAccounts() public {
        update(accounts[0], 0, 2);
        update(accounts[1], 0, 1);
        update(accounts[0], 2, 0);
        update(accounts[1], 1, 0);

        assertEq(heap.size(), 0);
        assertEq(heap.length(), 0);
        assertEq(heap.getHead(), ADDR_ZERO);
        assertEq(heap.getTail(), ADDR_ZERO);
    }

    function testShouldInsertThreeAccountsAndRemoveThem() public {
        update(accounts[0], 0, 3);
        update(accounts[1], 0, 2);
        update(accounts[2], 0, 1);

        assertEq(heap.getHead(), accounts[0]);
        assertEq(heap.getTail(), accounts[2]);

        // Remove account 0.
        update(accounts[0], 3, 0);
        assertEq(heap.getHead(), accounts[1]);
        assertEq(heap.getTail(), accounts[2]);
        assertEq(heap.getPrev(accounts[1]), ADDR_ZERO);
        assertEq(heap.getNext(accounts[1]), accounts[2]);

        assertEq(heap.getPrev(accounts[2]), accounts[1]);
        assertEq(heap.getNext(accounts[2]), ADDR_ZERO);

        // Remove account 1.
        update(accounts[1], 2, 0);
        assertEq(heap.getHead(), accounts[2]);
        assertEq(heap.getTail(), accounts[2]);
        assertEq(heap.getPrev(accounts[2]), ADDR_ZERO);
        assertEq(heap.getNext(accounts[2]), ADDR_ZERO);

        // Remove account 2.
        update(accounts[2], 1, 0);
        assertEq(heap.getHead(), ADDR_ZERO);
        assertEq(heap.getTail(), ADDR_ZERO);
    }

    function testShouldRemoveAllSortedAccount() public {
        for (uint256 i = 0; i < accounts.length; i++) {
            update(accounts[i], 0, NB_ACCOUNTS - i);
        }

        for (uint256 i = 0; i < accounts.length; i++) {
            update(accounts[i], NB_ACCOUNTS - i, 0);
        }

        assertEq(heap.getHead(), ADDR_ZERO);
        assertEq(heap.getTail(), ADDR_ZERO);
    }

    function testShouldInsertAccountSortedAtTheBeginningUntilNDS() public {
        uint256 value = 50;

        // Add first 10 accounts with decreasing value.
        for (uint256 i = 0; i < 10; i++) {
            update(accounts[i], 0, value - i);
        }

        assertEq(heap.getHead(), accounts[0]);
        assertEq(heap.getTail(), accounts[9]);

        address nextAccount = accounts[0];
        for (uint256 i = 0; i < 9; i++) {
            nextAccount = heap.getNext(nextAccount);
            assertEq(nextAccount, accounts[i + 1]);
        }

        address prevAccount = accounts[9];
        for (uint256 i = 0; i < 9; i++) {
            prevAccount = heap.getPrev(prevAccount);
            assertEq(prevAccount, accounts[10 - i - 2]);
        }

        // Add last 10 accounts at the same value.
        for (uint256 i = NB_ACCOUNTS - 10; i < NB_ACCOUNTS; i++) {
            update(accounts[i], 0, 10);
        }

        assertEq(heap.getHead(), accounts[0]);
        assertEq(heap.getTail(), accounts[accounts.length - 1]);

        nextAccount = accounts[0];
        for (uint256 i = 0; i < 9; i++) {
            nextAccount = heap.getNext(nextAccount);
            assertEq(nextAccount, accounts[i + 1]);
        }

        prevAccount = accounts[9];
        for (uint256 i = 0; i < 9; i++) {
            prevAccount = heap.getPrev(prevAccount);
            assertEq(prevAccount, accounts[10 - i - 2]);
        }
    }

    function testRemoveLast() public {
        update(accounts[0], 0, 4);
        update(accounts[1], 0, 2);
        update(accounts[2], 0, 3);

        uint256 sizeBefore = heap.size();

        update(accounts[2], 3, 0);

        uint256 sizeAfter = heap.size();

        assertLt(sizeAfter, sizeBefore);
        assertEq(heap.length(), 2);
    }

    function testShouldInsertAccountsAllSorted() public {
        for (uint256 i = 0; i < accounts.length; i++) {
            update(accounts[i], 0, NB_ACCOUNTS - i);
        }

        assertEq(heap.length(), NB_ACCOUNTS);
        assertEq(heap.getHead(), accounts[0]);
        assertEq(heap.getTail(), accounts[accounts.length - 1]);

        address nextAccount = accounts[0];
        for (uint256 i = 0; i < accounts.length - 1; i++) {
            nextAccount = heap.getNext(nextAccount);
            assertEq(nextAccount, accounts[i + 1]);
        }

        address prevAccount = accounts[accounts.length - 1];
        for (uint256 i = 0; i < accounts.length - 1; i++) {
            prevAccount = heap.getPrev(prevAccount);
            assertEq(prevAccount, accounts[accounts.length - i - 2]);
        }
    }

    function testInsertLast() public {
        for (uint256 i; i < 10; i++) update(accounts[i], 0, NB_ACCOUNTS - i);

        for (uint256 i = 10; i < 15; i++) update(accounts[i], 0, i - 9);

        for (uint256 i = 10; i < 15; i++) assertLe(heap.accountsValue(i), 10);
    }

    function testDecreaseIndexChanges() public {
        for (uint256 i = 0; i < 16; i++) update(accounts[i], 0, 20 - i);

        uint256 index0Before = heap.indexOf(accounts[0]);

        update(accounts[0], 20, 2);

        uint256 index0After = heap.indexOf(accounts[0]);

        assertGt(index0After, index0Before);
    }

    function testIncreaseIndexChanges() public {
        for (uint256 i = 0; i < 20; i++) update(accounts[i], 0, 20 - i);

        uint256 index17Before = heap.indexOf(accounts[17]);

        update(accounts[17], 20 - 17, 21);

        uint256 index17After = heap.indexOf(accounts[17]);

        assertLt(index17After, index17Before);
    }

    function testInsertNoSwap() public {
        update(accounts[0], 0, 40);
        update(accounts[1], 0, 30);
        update(accounts[2], 0, 20);

        // Insert does a swap with the same index.
        update(accounts[3], 0, 10);
        assertEq(heap.indexOf(accounts[0]), 0);
        assertEq(heap.indexOf(accounts[1]), 1);
        assertEq(heap.indexOf(accounts[2]), 2);
        assertEq(heap.indexOf(accounts[3]), 3);
    }

    function testOverflowNewValue(uint256 value) public {
        vm.assume(value > type(uint96).max);

        vm.expectRevert("SafeCast: value doesn't fit in 96 bits");
        update(accounts[0], 0, value);
    }

    function testOverflowFormerValue(uint256 value) public {
        vm.assume(value > type(uint96).max);

        vm.expectRevert("SafeCast: value doesn't fit in 96 bits");
        update(accounts[0], value, 0);
    }
}

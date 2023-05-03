// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import "./TestCommonHeapOrdering.t.sol";
import "./mocks/ThreeHeapOrderingMock.sol";

contract TestThreeHeapOrdering is TestCommonHeapOrdering {
    constructor() {
        heap = new ThreeHeapOrderingMock();
    }

    function testComputeSizeSmall() public {
        update(accounts[0], 0, 10);
        update(accounts[1], 0, 20);
        update(accounts[2], 0, 30);
        update(accounts[3], 0, 40);
        update(accounts[4], 0, 50);
        update(accounts[5], 0, 60);

        MAX_SORTED_USERS = 3;

        update(accounts[5], 60, 25);
        assertEq(heap.size(), 2);
    }

    function testComputeSizeBig() public {
        MAX_SORTED_USERS = 45;

        for (uint256 i = 0; i < NB_ACCOUNTS; i++) {
            update(accounts[i], 0, i + 1);
        }
        // Test that the size has been increased to MAX_SORTED_USERS/3 and increased again.
        assertEq(heap.size(), 20);
    }

    function testShiftUpLeft() public {
        update(accounts[0], 0, 4);
        update(accounts[1], 0, 3);
        update(accounts[2], 0, 2);
        update(accounts[3], 0, 1);

        assertEq(heap.accountsValue(0), 4);
        assertEq(heap.accountsValue(1), 3);
        assertEq(heap.accountsValue(2), 2);
        assertEq(heap.accountsValue(3), 1);

        update(accounts[3], 1, 10);

        assertEq(heap.accountsValue(0), 10);
        assertEq(heap.accountsValue(1), 3);
        assertEq(heap.accountsValue(2), 2);
        assertEq(heap.accountsValue(3), 4);
    }

    function testShiftUpTop() public {
        update(accounts[0], 0, 4);
        update(accounts[1], 0, 3);
        update(accounts[2], 0, 2);
        update(accounts[3], 0, 1);

        assertEq(heap.accountsValue(0), 4);
        assertEq(heap.accountsValue(1), 3);
        assertEq(heap.accountsValue(2), 2);
        assertEq(heap.accountsValue(3), 1);

        update(accounts[2], 2, 10);

        assertEq(heap.accountsValue(0), 10);
        assertEq(heap.accountsValue(1), 3);
        assertEq(heap.accountsValue(2), 4);
        assertEq(heap.accountsValue(3), 1);
    }

    function testShiftUpRight() public {
        update(accounts[0], 0, 4);
        update(accounts[1], 0, 3);
        update(accounts[2], 0, 2);
        update(accounts[3], 0, 1);

        assertEq(heap.accountsValue(0), 4);
        assertEq(heap.accountsValue(1), 3);
        assertEq(heap.accountsValue(2), 2);
        assertEq(heap.accountsValue(3), 1);

        update(accounts[3], 1, 10);

        assertEq(heap.accountsValue(0), 10);
        assertEq(heap.accountsValue(1), 3);
        assertEq(heap.accountsValue(2), 2);
        assertEq(heap.accountsValue(3), 4);
    }

    function testShiftUpBig() public {
        update(accounts[0], 0, 20);
        update(accounts[1], 0, 15);
        update(accounts[2], 0, 13);
        update(accounts[3], 0, 11);
        update(accounts[4], 0, 12);
        update(accounts[5], 0, 14);
        update(accounts[6], 0, 5);

        assertEq(heap.accountsValue(0), 20);
        assertEq(heap.accountsValue(1), 15);
        assertEq(heap.accountsValue(2), 13);
        assertEq(heap.accountsValue(3), 11);
        assertEq(heap.accountsValue(4), 12);
        assertEq(heap.accountsValue(5), 14);
        assertEq(heap.accountsValue(6), 5);

        update(accounts[5], 14, 30);

        assertEq(heap.accountsValue(0), 30);
        assertEq(heap.accountsValue(1), 20);
        assertEq(heap.accountsValue(5), 15);
    }

    function testShiftDownLeft() public {
        update(accounts[0], 0, 5);
        update(accounts[1], 0, 4);
        update(accounts[2], 0, 3);
        update(accounts[2], 0, 2);

        assertEq(heap.accountsValue(0), 5);
        assertEq(heap.accountsValue(1), 4);
        assertEq(heap.accountsValue(2), 3);
        assertEq(heap.accountsValue(3), 2);

        update(accounts[0], 5, 1);

        assertEq(heap.accountsValue(0), 4);
        assertEq(heap.accountsValue(1), 1);
        assertEq(heap.accountsValue(2), 3);
        assertEq(heap.accountsValue(3), 2);
    }

    function testShiftDownBot() public {
        update(accounts[0], 0, 5);
        update(accounts[1], 0, 3);
        update(accounts[2], 0, 4);
        update(accounts[2], 0, 2);

        assertEq(heap.accountsValue(0), 5);
        assertEq(heap.accountsValue(1), 3);
        assertEq(heap.accountsValue(2), 4);
        assertEq(heap.accountsValue(3), 2);

        update(accounts[0], 5, 1);

        assertEq(heap.accountsValue(0), 4);
        assertEq(heap.accountsValue(1), 3);
        assertEq(heap.accountsValue(2), 1);
        assertEq(heap.accountsValue(3), 2);
    }

    function testShiftDownRight() public {
        update(accounts[0], 0, 5);
        update(accounts[1], 0, 2);
        update(accounts[2], 0, 3);
        update(accounts[2], 0, 4);

        assertEq(heap.accountsValue(0), 5);
        assertEq(heap.accountsValue(1), 2);
        assertEq(heap.accountsValue(2), 3);
        assertEq(heap.accountsValue(3), 4);

        update(accounts[0], 5, 1);

        assertEq(heap.accountsValue(0), 4);
        assertEq(heap.accountsValue(1), 2);
        assertEq(heap.accountsValue(2), 3);
        assertEq(heap.accountsValue(3), 1);
    }

    function testShiftDownBig() public {
        update(accounts[0], 0, 20);
        update(accounts[1], 0, 15);
        update(accounts[2], 0, 13);
        update(accounts[3], 0, 11);
        update(accounts[4], 0, 12);
        update(accounts[5], 0, 14);
        update(accounts[6], 0, 5);

        assertEq(heap.accountsValue(0), 20);
        assertEq(heap.accountsValue(1), 15);
        assertEq(heap.accountsValue(2), 13);
        assertEq(heap.accountsValue(3), 11);
        assertEq(heap.accountsValue(4), 12);
        assertEq(heap.accountsValue(5), 14);
        assertEq(heap.accountsValue(6), 5);

        update(accounts[0], 20, 1);

        assertEq(heap.accountsValue(0), 15);
        assertEq(heap.accountsValue(1), 14);
        assertEq(heap.accountsValue(5), 1);
    }

    function testDecreaseGuardLimit() public {
        update(accounts[0], 0, 20);
        update(accounts[1], 0, 19);
        update(accounts[2], 0, 18);
        update(accounts[3], 0, 17);
        update(accounts[4], 0, 16);
        update(accounts[5], 0, 15);
        update(accounts[6], 0, 14);
        update(accounts[7], 0, 13);

        assertEq(heap.accountsValue(0), 20);
        assertEq(heap.accountsValue(1), 19);
        assertEq(heap.accountsValue(2), 18);
        assertEq(heap.accountsValue(3), 17);
        assertEq(heap.accountsValue(4), 16);
        assertEq(heap.accountsValue(5), 15);
        assertEq(heap.accountsValue(6), 14);
        assertEq(heap.accountsValue(7), 13);

        update(accounts[2], 18, 1);

        assertEq(heap.accountsValue(2), 13);
        assertEq(heap.accountsValue(7), 1);
    }

    function testInsertWrap() public {
        MAX_SORTED_USERS = 30;
        for (uint256 i = 0; i < 30; i++) update(accounts[i], 0, NB_ACCOUNTS - i);

        update(accounts[30], 0, 1);

        assertEq(heap.accountsValue(10), 1);
    }

    function testIncreaseAndRemoveNoSwap() public {
        MAX_SORTED_USERS = 3;
        update(accounts[0], 0, 60);
        update(accounts[1], 0, 50);
        update(accounts[2], 0, 40);

        // Increase does a swap with the same index.
        update(accounts[1], 50, 55);
        assertEq(heap.indexOf(accounts[0]), 0);
        assertEq(heap.indexOf(accounts[1]), 1);
        assertEq(heap.indexOf(accounts[2]), 2);

        // Remove does a swap with the same index.
        update(accounts[2], 40, 0);
        assertEq(heap.indexOf(accounts[0]), 0);
        assertEq(heap.indexOf(accounts[1]), 1);
    }

    function testRemoveShiftDown() public {
        update(accounts[0], 0, 40);
        update(accounts[1], 0, 10);
        update(accounts[2], 0, 30);
        update(accounts[3], 0, 20);
        update(accounts[4], 0, 8);
        update(accounts[5], 0, 7);
        update(accounts[6], 0, 6);
        update(accounts[7], 0, 2);

        assertEq(heap.accountsValue(0), 40);
        assertEq(heap.accountsValue(1), 10);
        assertEq(heap.accountsValue(2), 30);
        assertEq(heap.accountsValue(3), 20);
        assertEq(heap.accountsValue(4), 8);
        assertEq(heap.accountsValue(5), 7);
        assertEq(heap.accountsValue(6), 6);
        assertEq(heap.accountsValue(7), 2);

        update(accounts[1], 10, 0);

        assertEq(heap.accountsValue(0), 40);
        assertEq(heap.accountsValue(1), 8);
        assertEq(heap.accountsValue(2), 30);
        assertEq(heap.accountsValue(3), 20);
        assertEq(heap.accountsValue(4), 2);
        assertEq(heap.accountsValue(5), 7);
        assertEq(heap.accountsValue(6), 6);
    }

    function testRemoveShiftUp() public {
        update(accounts[0], 0, 40);
        update(accounts[1], 0, 10);
        update(accounts[2], 0, 30);
        update(accounts[3], 0, 20);
        update(accounts[4], 0, 8);
        update(accounts[5], 0, 7);
        update(accounts[6], 0, 6);
        update(accounts[7], 0, 25);

        assertEq(heap.accountsValue(0), 40);
        assertEq(heap.accountsValue(1), 10);
        assertEq(heap.accountsValue(2), 30);
        assertEq(heap.accountsValue(3), 20);
        assertEq(heap.accountsValue(4), 8);
        assertEq(heap.accountsValue(5), 7);
        assertEq(heap.accountsValue(6), 6);
        assertEq(heap.accountsValue(7), 25);

        update(accounts[4], 8, 0);

        assertEq(heap.accountsValue(0), 40);
        assertEq(heap.accountsValue(1), 25);
        assertEq(heap.accountsValue(2), 30);
        assertEq(heap.accountsValue(3), 20);
        assertEq(heap.accountsValue(4), 10);
        assertEq(heap.accountsValue(5), 7);
        assertEq(heap.accountsValue(6), 6);
    }
}

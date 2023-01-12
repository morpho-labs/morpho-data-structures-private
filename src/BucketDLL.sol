// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

library BucketDLL {
    /// STRUCTS ///

    struct Account {
        bytes32 prev;
        bytes32 next;
    }

    struct List {
        mapping(bytes32 => Account) accounts;
    }

    /// INTERNAL ///

    /// @notice Returns the address at the head of the `_list`.
    /// @param _list The list from which to get the head.
    function getHead(List storage _list) internal view returns (bytes32) {
        return _list.accounts[0].next;
    }

    /// @notice Returns the address at the tail of the `_list`.
    /// @param _list The list from which to get the tail.
    function getTail(List storage _list) internal view returns (bytes32) {
        return _list.accounts[0].prev;
    }

    /// @notice Returns the next id address from the current `_id`.
    /// @param _list The list to search in.
    /// @param _id The address of the current account.
    /// @return The address of the next account.
    function getNext(List storage _list, bytes32 _id) internal view returns (bytes32) {
        return _list.accounts[_id].next;
    }

    /// @notice Returns the previous id address from the current `_id`.
    /// @param _list The list to search in.
    /// @param _id The address of the current account.
    /// @return The address of the previous account.
    function getPrev(List storage _list, bytes32 _id) internal view returns (bytes32) {
        return _list.accounts[_id].prev;
    }

    /// @notice Removes an account of the `_list`.
    /// @dev This function should not be called with `_id` equal to address 0.
    /// @param _list The list to search in.
    /// @param _id The address of the account.
    function remove(List storage _list, bytes32 _id) internal returns (bool empty) {
        Account memory account = _list.accounts[_id];
        bytes32 prev = account.prev;
        bytes32 next = account.next;

        empty = (prev == 0 && next == 0);

        _list.accounts[prev].next = next;
        _list.accounts[next].prev = prev;

        delete _list.accounts[_id];
    }

    /// @notice Inserts an account at the tail of the `_list`.
    /// @dev This function should not be called with `_id` equal to address 0.
    /// @param _list The list to search in.
    /// @param _id The address of the account.
    function insert(List storage _list, bytes32 _id) internal returns (bool empty) {
        bytes32 tail = _list.accounts[0].prev;
        empty = tail == 0;

        _list.accounts[0].prev = _id;
        _list.accounts[tail].next = _id;
        _list.accounts[_id].prev = tail;
    }
}

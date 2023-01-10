// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

library DoubleLinkedList {

    /// WARNING: This library assumes the input to be clean from address(0) and 0 values.

    /// STRUCTS ///

    struct Account {
        address prev;
        address next;
    }

    struct List {
        mapping(address => Account) accounts;
    }

    /// INTERNAL ///

    /// @notice Returns the address at the head of the `_list`.
    /// @param _list The list to get the head.
    /// @return The address of the head.
    function getHead(List storage _list) internal view returns (address) {
        return _list.accounts[address(0)].next;
    }

    /// @notice Returns the next id address from the current `_id`.
    /// @param _list The list to search in.
    /// @param _id The address of the account.
    /// @return The address of the next account.
    function getNext(List storage _list, address _id) internal view returns (address) {
        return _list.accounts[_id].next;
    }

    /// @notice Removes an account of the `_list`.
    /// @param _list The list to search in.
    /// @param _id The address of the account.
    function remove(List storage _list, address _id) internal returns (bool empty) {
        Account memory account = _list.accounts[_id];

        address prev = account.prev;
        address next = account.next;

        empty = (prev == address(0) && next == address(0));

        _list.accounts[account.prev].next = next;
        _list.accounts[account.next].prev = prev;

        delete _list.accounts[_id];
    }

    /// @notice Inserts an account at the tail of the `_list`.
    /// @param _list The list to search in.
    /// @param _id The address of the account.
    function insert(List storage _list, address _id) internal returns (bool empty) {
        address tail = _list.accounts[address(0)].prev;
        empty = tail == address(0);

        _list.accounts[address(0)].prev = _id;
        _list.accounts[tail].next = _id;
        _list.accounts[_id].prev = tail;
    }
}

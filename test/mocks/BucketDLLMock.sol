// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import "src/BucketDLL.sol";

library BucketDLLMock {
    function remove(BucketDLL.List storage _list, address _id) internal returns (bool) {
        BucketDLL.Account memory account = _list.accounts[_id];
        address prev = account.prev;
        address next = account.next;

        _list.accounts[prev].next = next;
        _list.accounts[next].prev = prev;

        delete _list.accounts[_id];

        return (prev == address(0) && next == address(0));
    }

    function insert(
        BucketDLL.List storage _list,
        address _id,
        bool _head
    ) internal returns (bool) {
        if (_head) {
            address head = _list.accounts[address(0)].next;
            _list.accounts[address(0)].next = _id;
            _list.accounts[head].prev = _id;
            _list.accounts[_id].next = head;
            return head == address(0);
        } else {
            address tail = _list.accounts[address(0)].prev;
            _list.accounts[address(0)].prev = _id;
            _list.accounts[tail].next = _id;
            _list.accounts[_id].prev = tail;
            return tail == address(0);
        }
    }

    function getNext(BucketDLL.List storage _list, address _id) internal view returns (address) {
        return getNext(_list, _id);
    }

    /// @notice Returns the address at the head of the `_list`.
    /// @param _list The list from which to get the head.
    /// @return The address of the head.
    function getHead(BucketDLL.List storage _list) internal view returns (address) {
        return _list.accounts[address(0)].next;
    }

    /// @notice Returns the address at the tail of the `_list`.
    /// @param _list The list from which to get the tail.
    /// @return The address of the tail.
    function getTail(BucketDLL.List storage _list) internal view returns (address) {
        return _list.accounts[address(0)].prev;
    }

    /// @notice Returns the previous id address from the current `_id`.
    /// @param _list The list to search in.
    /// @param _id The address of the current account.
    /// @return The address of the previous account.
    function getPrev(BucketDLL.List storage _list, address _id) internal view returns (address) {
        return _list.accounts[_id].prev;
    }
}

// SPDX-License-Identifier: GNU AGPLv3
pragma solidity ^0.8.0;

library BucketLib {
    struct Account {
        address id;
        uint96 value;
    }

    struct Bucket {
        Account[] accounts;
        mapping(address => uint256) indexOf;
    }

    function getHead(Bucket storage _bucket) internal view returns (Account memory) {
        return _bucket.accounts[0];
    }

    function getValueOf(Bucket storage _bucket, address _id) internal view returns (uint96) {
        uint256 index = _bucket.indexOf[_id];
        if (index >= _bucket.accounts.length) return 0;
        Account memory account = _bucket.accounts[index];
        if (account.id != _id) return 0;
        else return account.value;
    }

    function getLength(Bucket storage _bucket) internal view returns (uint256) {
        return _bucket.accounts.length;
    }

    function changeValue(
        Bucket storage _bucket,
        address _id,
        uint96 _newValue
    ) internal {
        _bucket.accounts[_bucket.indexOf[_id]].value = _newValue;
    }

    function remove(Bucket storage _bucket, address _id) internal {
        uint256 newIndex = _bucket.indexOf[_id];
        uint256 lastIndex = _bucket.accounts.length - 1;

        if (newIndex != lastIndex) {
            Account memory last = _bucket.accounts[lastIndex];
            _bucket.accounts[newIndex] = last;
            _bucket.indexOf[last.id] = newIndex;
        }

        _bucket.accounts.pop();
        delete _bucket.indexOf[_id];
    }

    function insert(
        Bucket storage _bucket,
        address _id,
        uint96 _value
    ) internal {
        uint256 length = _bucket.accounts.length;
        _bucket.accounts.push(Account(_id, _value));
        _bucket.indexOf[_id] = length;
    }
}

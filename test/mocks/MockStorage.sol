// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MockStorage {
    uint256 numberStorage;

    function getNumberStorage() public view returns(uint256) {
        return numberStorage;
    }

    function setNumberStorage(uint256 _numberStorage) public {
        numberStorage = _numberStorage;
    }
}

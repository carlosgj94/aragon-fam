// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {IL2CrossDomainMessenger} from "src/interfaces/IL2CrossDomainMessenger.sol";

contract DAOProxy {
    IL2CrossDomainMessenger public bridge;
    address public parentDAO;

    uint256 numberStorage;

    modifier onlyParentDAO() {
        require(
            msg.sender == address(bridge)
            && bridge.xDomainMessageSender() == parentDAO,
            "Not parent DAO"
        );
        _;
    }

    constructor(IL2CrossDomainMessenger _bridge, address _parentDAO) {
        bridge = _bridge;
        parentDAO = _parentDAO;
    }

    function setNumberStorage(uint256 _numberStorage) public onlyParentDAO {
        numberStorage = _numberStorage;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IL2CrossDomainMessenger} from "src/interfaces/IL2CrossDomainMessenger.sol";
import { Vm, Test } from "forge-std/Test.sol";
import "forge-std/console2.sol";


contract MockL2CrossDomainMessenger is IL2CrossDomainMessenger, Test {
    address sender;

    function xDomainMessageSender() public view override returns (address) {
        return sender;
    }

    function relayMessage(
        address _target,
        address,
        bytes memory _message,
        uint256
    ) external override {
        sender = msg.sender;

        (bool success, ) = address(_target).call(_message);

        require(success, "cdm call fail");
    }

    function sendMessage(
        address _target,
        bytes calldata _message,
        uint32 _gasLimit
    ) external override {
        sender = msg.sender;

        (bool success, ) = address(_target).call{gas: _gasLimit}(_message);

        require(success, "cdm call fail");
    }
}

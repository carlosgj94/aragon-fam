// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {MockL2CrossDomainMessenger} from "test/mocks/MockL2CrossDomainMessenger.sol";
import {MockStorage} from "test/mocks/MockStorage.sol";

contract DeployMocks is Script {
  MockL2CrossDomainMessenger mockMessenger;
  MockStorage mockStorage;

  function runMocks() public {
    mockMessenger = new MockL2CrossDomainMessenger();
    mockStorage = new MockStorage();
  }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {DAOProxyFactory} from "src/DAOProxyFactory.sol";
import {IL2CrossDomainMessenger} from "src/interfaces/IL2CrossDomainMessenger.sol";

contract Deploy is Script {
  DAOProxyFactory daoFactory;
  IL2CrossDomainMessenger xDomainMessenger;
  uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
  address defaultMessenger = address(0x4200000000000000000000000000000000000007);

  function run(address _xDomainMessenger) public {
    vm.startBroadcast(deployerPrivateKey);

    xDomainMessenger = IL2CrossDomainMessenger(
      _xDomainMessenger == address(0) ? defaultMessenger : _xDomainMessenger
    );

    daoFactory = new DAOProxyFactory(xDomainMessenger);

    vm.stopBroadcast();
  }
}

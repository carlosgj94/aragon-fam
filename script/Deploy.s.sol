// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {DAOProxyFactory} from "src/DAOProxyFactory.sol";
import {IL2CrossDomainMessenger} from "src/interfaces/IL2CrossDomainMessenger.sol";
import {DAOProxy} from "src/DAOProxy.sol";

contract Deploy is Script {
  DAOProxyFactory daoFactory;
  DAOProxy daoProxy;
  uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
  IL2CrossDomainMessenger xDomainMessenger =
    IL2CrossDomainMessenger(0x4200000000000000000000000000000000000007);

  function run() public {
    vm.startBroadcast(deployerPrivateKey);

    daoProxy = new DAOProxy();
    daoFactory = new DAOProxyFactory(xDomainMessenger, address(daoProxy));

    vm.stopBroadcast();
  }

  function runTests(address _xDomainMessenger) public {
    vm.startBroadcast(deployerPrivateKey);

    xDomainMessenger = IL2CrossDomainMessenger(_xDomainMessenger);

    daoProxy = new DAOProxy();
    daoFactory = new DAOProxyFactory(xDomainMessenger, address(daoProxy));

    vm.stopBroadcast();
  }
}

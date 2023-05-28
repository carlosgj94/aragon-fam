// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {Deploy} from "script/Deploy.s.sol";
import {DeployMocks} from "script/DeployMocks.s.sol";
import {DAOProxyFactory} from "src/DAOProxyFactory.sol";
import {DAOProxy} from "src/DAOProxy.sol";

contract DAOProxyFactoryTest is Test, Deploy, DeployMocks {
  function setUp() public {
    DeployMocks.runMessenger();
    Deploy.run(address(mockMessenger));
  }
}

contract CreateProxy is DAOProxyFactoryTest {
    address bob = address(0xB0B);

    function test_CreateProxySuccess() public {
        vm.startPrank(bob);
        vm.recordLogs();
        mockMessenger.relayMessage(
            address(daoFactory),
            bob,
            abi.encodePacked(daoFactory.createDAOProxy.selector),
            0
        );
        vm.stopPrank();

        Vm.Log[] memory entries = vm.getRecordedLogs();
        DAOProxy proxy = DAOProxy(address(uint160(uint256(entries[0].topics[1]))));
        assertEq(entries.length, 1);
        assertEq(proxy.parentDAO(), bob);
  }
}

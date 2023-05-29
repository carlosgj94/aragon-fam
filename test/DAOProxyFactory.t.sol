// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {Deploy} from "script/Deploy.s.sol";
import {DeployMocks} from "script/DeployMocks.s.sol";
import {DAOProxyFactory} from "src/DAOProxyFactory.sol";
import {DAOProxy} from "src/DAOProxy.sol";
import {MockStorage} from "test/mocks/MockStorage.sol";

contract DAOProxyFactoryTest is Test, Deploy, DeployMocks {
  address bob = address(0xB0B);
  DAOProxy proxy;

  struct Action {
    address to;
    uint256 value;
    bytes data;
  }

  function setUp() public {
    DeployMocks.runMocks();
    Deploy.runTests(address(mockMessenger));

    vm.startPrank(bob);
    vm.recordLogs();
    mockMessenger.relayMessage(
      address(daoFactory), bob, abi.encodePacked(daoFactory.createDAOProxy.selector), 0
    );
    vm.stopPrank();

    Vm.Log[] memory entries = vm.getRecordedLogs();
    proxy = DAOProxy(address(uint160(uint256(entries[1].topics[1]))));
  }
}

contract CreateProxy is DAOProxyFactoryTest {
  address dad = address(0xDAD);

  function test_CreateProxySuccess() public {
    vm.startPrank(dad);
    vm.recordLogs();
    mockMessenger.relayMessage(
      address(daoFactory), dad, abi.encodePacked(daoFactory.createDAOProxy.selector), 0
    );
    vm.stopPrank();

    Vm.Log[] memory entries = vm.getRecordedLogs();
    DAOProxy _proxy = DAOProxy(address(uint160(uint256(entries[1].topics[1]))));
    assertEq(entries.length, 2);
    assertEq(_proxy.parentDAO(), dad);
  }

  function test_CallProxyDAO() public {
    uint256 number = mockStorage.getNumberStorage();
    assertEq(number, uint256(0));

    vm.startPrank(bob);

    Action[] memory actions = new Action[](1);
    actions[0] = Action({
      to: address(mockStorage),
      value: uint256(0),
      data: abi.encodePacked(mockStorage.setNumberStorage.selector, uint256(69))
    });

    mockMessenger.relayMessage(
      address(proxy),
      bob,
      abi.encodePacked(proxy.execute.selector, abi.encode(actions), uint256(2)),
      0
    );
    vm.stopPrank();
    number = mockStorage.getNumberStorage();
    assertEq(number, uint256(69));
  }
}

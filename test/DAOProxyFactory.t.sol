// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {Deploy} from "script/Deploy.s.sol";
import {DeployMocks} from "script/DeployMocks.s.sol";
import {DAOProxyFactory} from "src/DAOProxyFactory.sol";
import {DAOProxy} from "src/DAOProxy.sol";

contract DAOProxyFactoryTest is Test, Deploy, DeployMocks {
    address bob = address(0xB0B);
    DAOProxy proxy;

    function setUp() public {
        DeployMocks.runMessenger();
        Deploy.run(address(mockMessenger));

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
        proxy = DAOProxy(address(uint160(uint256(entries[0].topics[1]))));
    }
}

contract CreateProxy is DAOProxyFactoryTest {
    address dad = address(0xDAD);

    function test_CreateProxySuccess() public {
        vm.startPrank(dad);
        vm.recordLogs();
        mockMessenger.relayMessage(
            address(daoFactory),
            dad,
            abi.encodePacked(daoFactory.createDAOProxy.selector),
            0
        );
        vm.stopPrank();

        Vm.Log[] memory entries = vm.getRecordedLogs();
        DAOProxy _proxy = DAOProxy(address(uint160(uint256(entries[0].topics[1]))));
        assertEq(entries.length, 1);
        assertEq(_proxy.parentDAO(), dad);
    }

    function test_CallProxyDAO() public {
        vm.startPrank(bob);

        mockMessenger.relayMessage(
            address(proxy),
            bob,
            abi.encodePacked(proxy.setNumberStorage.selector, uint256(69)),
            0
        );
        vm.stopPrank();
        uint number = proxy.getNumberStorage();
        assertEq(number, uint256(69));
    }
}

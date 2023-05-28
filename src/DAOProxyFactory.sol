// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {IL2CrossDomainMessenger} from "src/interfaces/IL2CrossDomainMessenger.sol";
import {DAOProxy} from "src/DAOProxy.sol";

contract DAOProxyFactory {
   event DAOProxyDeployed(address indexed _proxyDAO, address indexed _parentDAO, uint _chainId);

    IL2CrossDomainMessenger bridge;

    constructor(IL2CrossDomainMessenger _bridge) {
        bridge = _bridge;
    }

     modifier onlyBridge() {
        require(msg.sender == address(bridge), "Not bridge");
        _;
    }

    function createDAOProxy() external payable onlyBridge {
        address _sender = bridge.xDomainMessageSender();

        address daoProxy = address(new DAOProxy{salt: toBytes(_sender)}(bridge, _sender));

        emit DAOProxyDeployed(daoProxy, _sender, 1);
    }

    function toBytes(address a) public pure returns (bytes32){
        return bytes32(uint256(uint160(a)) << 96);
    }
}

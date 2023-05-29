// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {IL2CrossDomainMessenger} from "src/interfaces/IL2CrossDomainMessenger.sol";
import {DAOProxy} from "src/DAOProxy.sol";
import {Clones} from "openzeppelin/proxy/Clones.sol";

contract DAOProxyFactory {
  event DAOProxyDeployed(address indexed _proxyDAO, address indexed _parentDAO, uint256 _chainId);

  IL2CrossDomainMessenger bridge;
  address proxyDAOImplementation;

  constructor(IL2CrossDomainMessenger _bridge, address _proxyDAOImplementation) {
    bridge = _bridge;
    proxyDAOImplementation = _proxyDAOImplementation;
  }

  modifier onlyBridge() {
    require(msg.sender == address(bridge), "Not bridge");
    _;
  }

  function createDAOProxy() external onlyBridge {
    address _sender = bridge.xDomainMessageSender();

    address daoProxy = Clones.cloneDeterministic(proxyDAOImplementation, toBytes(_sender));
    DAOProxy(daoProxy).initialize(bridge, _sender);

    emit DAOProxyDeployed(daoProxy, _sender, 1);
  }

  function toBytes(address a) public pure returns (bytes32) {
    return bytes32(uint256(uint160(a)) << 96);
  }
}

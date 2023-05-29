// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {IL2CrossDomainMessenger} from "src/interfaces/IL2CrossDomainMessenger.sol";
import {hasBit, flipBit} from "src/utils/BitMap.sol";


contract DAOProxy {
    /// @notice Thrown if the action array length is larger than `MAX_ACTIONS`.
    error TooManyActions();

    /// @notice Thrown if action execution has failed.
    /// @param index The index of the action in the action array that failed.
    error ActionFailed(uint256 index);

    /// @notice Thrown if an action has insufficent gas left.
    error InsufficientGas();
    uint256 internal constant MAX_ACTIONS = 256;

    IL2CrossDomainMessenger public bridge;
    address public parentDAO;

    struct Action {
        address to;
        uint256 value;
        bytes data;
    }

    event Executed(
        Action[] actions,
        uint256 allowFailureMap,
        uint256 failureMap,
        bytes[] execResults
    );

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

    // TODO: nonReentrant
    function execute(
        Action[] calldata _actions,
        uint256 _allowFailureMap
    ) external onlyParentDAO {
        if (_actions.length > MAX_ACTIONS) {
            revert TooManyActions();
        }

        bytes[] memory execResults = new bytes[](_actions.length);
        uint256 failureMap;

        uint256 gasBefore;
        uint256 gasAfter;

        for (uint256 i = 0; i < _actions.length; ) {
            gasBefore = gasleft();

            (bool success, bytes memory result) = _actions[i].to.call{value: _actions[i].value}(
                _actions[i].data
            );
            gasAfter = gasleft();

            // Check if failure is allowed
            if (!hasBit(_allowFailureMap, uint8(i))) {
                // Check if the call failed.
                if (!success) {
                    revert ActionFailed(i);
                }
            } else {
                // Check if the call failed.
                if (!success) {
                    // Make sure that the action call did not fail because 63/64 of `gasleft()` was insufficient to execute the external call `.to.call` (see [ERC-150](https://eips.ethereum.org/EIPS/eip-150)).
                    // In specific scenarios, i.e. proposal execution where the last action in the action array is allowed to fail, the account calling `execute` could force-fail this action by setting a gas limit
                    // where 63/64 is insufficient causing the `.to.call` to fail, but where the remaining 1/64 gas are sufficient to successfully finish the `execute` call.
                    if (gasAfter < gasBefore / 64) {
                        revert InsufficientGas();
                    }

                    // Store that this action failed.
                    failureMap = flipBit(failureMap, uint8(i));
                }
            }

            execResults[i] = result;

            unchecked {
                ++i;
            }
        }

        emit Executed({
            actions: _actions,
            allowFailureMap: _allowFailureMap,
            failureMap: failureMap,
            execResults: execResults
        });
    }
}
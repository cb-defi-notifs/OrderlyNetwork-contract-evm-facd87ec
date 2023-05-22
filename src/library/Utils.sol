// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.18;

library Utils {
    function getAccountId(address addr, uint256 brokerSeq) public pure returns (bytes32 accountId) {
        bytes memory brokerEncoded = abi.encodePacked(brokerSeq);
        // brokerId is keccak brokerSeq
        bytes32 brokerId = keccak256(brokerEncoded);
        // data is encode addr + brokerId
        bytes memory data = abi.encode(addr, brokerId);
        // accountId is keccak data
        accountId = keccak256(data);
    }

    function getAccountId(address addr, bytes32 brokerId) internal pure returns (bytes32 accountId) {
        // data is encode addr + brokerId
        bytes memory data = abi.encode(addr, brokerId);
        // accountId is keccak data
        accountId = keccak256(data);
    }
}
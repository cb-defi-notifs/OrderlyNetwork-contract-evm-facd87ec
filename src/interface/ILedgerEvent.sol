// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.18;

interface ILedgerEvent {
    event AccountRegister(bytes32 indexed accountId, bytes32 indexed brokerId, address indexed userAddress);
    event AccountDeposit(
        bytes32 indexed accountId,
        uint64 indexed depositNonce,
        uint64 indexed eventId,
        address userAddress,
        bytes32 tokenHash,
        uint128 tokenAmount,
        uint256 srcChainId,
        uint64 srcChainDepositNonce,
        bytes32 brokerHash
    );
    event AccountWithdrawApprove(
        bytes32 indexed accountId,
        uint64 indexed withdrawNonce,
        uint64 indexed eventId,
        bytes32 brokerHash,
        address sender,
        address receiver,
        uint256 chainId,
        bytes32 tokenHash,
        uint128 tokenAmount,
        uint128 fee
    );
    event AccountWithdrawFinish(
        bytes32 indexed accountId,
        uint64 indexed withdrawNonce,
        uint64 indexed eventId,
        bytes32 brokerHash,
        address sender,
        address receiver,
        uint256 chainId,
        bytes32 tokenHash,
        uint128 tokenAmount,
        uint128 fee
    );
    event AccountWithdrawFail(
        bytes32 indexed accountId,
        uint64 indexed withdrawNonce,
        uint64 indexed eventId,
        bytes32 brokerHash,
        address sender,
        address receiver,
        uint256 chainId,
        bytes32 tokenHash,
        uint128 tokenAmount,
        uint128 fee,
        uint8 failReson
    );

    event SettlementResult(
        uint64 indexed eventId,
        bytes32 indexed accountId,
        int128 settledAmount,
        bytes32 settledAssetHash,
        bytes32 insuranceAccountId,
        uint128 insuranceTransferAmount,
        uint64 settlementExecutionsCount,
        uint64 lastEngineEventId
    );

    event AdlResult(
        uint64 indexed eventId,
        bytes32 indexed accountId,
        bytes32 insuranceAccountId,
        bytes32 symbolHash,
        int128 positionQtyTransfer,
        int128 costPositionTransfer,
        uint128 adlPrice,
        int128 sumUnitaryFundings,
        uint64 lastEngineEventId
    );

    event LiquidationResult(
        uint64 indexed eventId,
        bytes32 indexed liquidatedAccountId,
        bytes32 indexed insuranceAccountId,
        bytes32 liquidatedAssetHash,
        uint128 insuranceTransferAmount,
        uint64 lastEngineEventId
    );

    event ChangeOperatorManager(address oldAddress, address newAddress);
    event ChangeCrossChainManager(address oldAddress, address newAddress);
    event ChangeVaultManager(address oldAddress, address newAddress);
    event ChangeMarketManager(address oldAddress, address newAddress);
    event ChangeFeeManager(address oldAddress, address newAddress);

    // All events below are deprecated
    // Keep them for indexer backward compatibility

    // @deprecated
    event AccountRegister(
        bytes32 indexed accountId, bytes32 indexed brokerId, address indexed userAddress, uint256 blocktime
    );
    // @deprecated
    event AccountDeposit(
        bytes32 indexed accountId,
        uint64 indexed depositNonce,
        uint64 indexed eventId,
        address userAddress,
        bytes32 tokenHash,
        uint128 tokenAmount,
        uint256 srcChainId,
        uint64 srcChainDepositNonce,
        bytes32 brokerHash,
        uint256 blocktime
    );
    // @deprecated
    event AccountWithdrawApprove(
        bytes32 indexed accountId,
        uint64 indexed withdrawNonce,
        uint64 indexed eventId,
        bytes32 brokerHash,
        address sender,
        address receiver,
        uint256 chainId,
        bytes32 tokenHash,
        uint128 tokenAmount,
        uint128 fee,
        uint256 blocktime
    );
    // @deprecated
    event AccountWithdrawFinish(
        bytes32 indexed accountId,
        uint64 indexed withdrawNonce,
        uint64 indexed eventId,
        bytes32 brokerHash,
        address sender,
        address receiver,
        uint256 chainId,
        bytes32 tokenHash,
        uint128 tokenAmount,
        uint128 fee,
        uint256 blocktime
    );
    // @deprecated
    event AccountWithdrawFail(
        bytes32 indexed accountId,
        uint64 indexed withdrawNonce,
        uint64 indexed eventId,
        bytes32 brokerHash,
        address sender,
        address receiver,
        uint256 chainId,
        bytes32 tokenHash,
        uint128 tokenAmount,
        uint128 fee,
        uint256 blocktime,
        uint8 failReson
    );
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.18;

import "../library/types/OperatorTypes.sol";
import "../library/types/AccountTypes.sol";
import "../library/types/PerpTypes.sol";
import "../library/types/EventTypes.sol";
import "../library/types/MarketTypes.sol";

interface IOperatorManager {
    error OnlyOperatorCanCall();
    error InvalidBizType(uint8 bizType);
    error BatchIdNotMatch(uint64 batchId, uint64 futuresUploadBatchId);
    error CountNotMatch(uint256 length, uint256 count);
    error SignatureNotMatch();

    event FuturesTradeUpload(uint64 indexed batchId, uint256 blocktime);
    event EventUpload(uint64 indexed batchId, uint256 blocktime);

    // operator call futures trade upload
    function futuresTradeUpload(PerpTypes.FuturesTradeUploadData calldata data) external;
    // operator call event upload
    function eventUpload(EventTypes.EventUpload calldata data) external;
    // operator call perp market info
    function PerpMarketInfo(MarketTypes.PerpMarketUpload calldata data) external;
    // operator call ping
    function operatorPing() external;

    // check if cefi down
    function checkCefiDown() external returns (bool);

    // admin call
    function setOperator(address _operator) external;
    function setLedger(address _ledger) external;
}

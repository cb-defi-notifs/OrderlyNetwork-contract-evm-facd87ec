// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.18;

import "./interface/ILedger.sol";
import "./interface/IOperatorManager.sol";
import "./library/Signature.sol";
import "openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";

/**
 * OperatorManager is responsible for executing cefi tx, only called by operator.
 * This contract should only have one in main-chain (avalanche)
 */
contract OperatorManager is IOperatorManager, OwnableUpgradeable {
    // operator address
    address public operatorAddress;
    // ledger Interface
    ILedger public ledger;

    // ids
    // futuresUploadBatchId
    uint64 public futuresUploadBatchId;
    // eventUploadBatchId
    uint64 public eventUploadBatchId;
    // last operator interaction timestamp
    uint256 public lastOperatorInteraction;
    // cefi sign address
    // @Rubick move this with operatorAddress when next deployment
    address public cefiSignatureAddress;

    // only operator
    modifier onlyOperator() {
        if (msg.sender != operatorAddress) revert OnlyOperatorCanCall();
        _;
    }

    // set operator
    function setOperator(address _operatorAddress) public override onlyOwner {
        operatorAddress = _operatorAddress;
    }

    // set cefiSignatureAddress
    function setCefiSignatureAddress(address _cefiSignatureAddress) public override onlyOwner {
        cefiSignatureAddress = _cefiSignatureAddress;
    }

    // set ledger
    function setLedger(address _ledger) public override onlyOwner {
        ledger = ILedger(_ledger);
    }

    constructor() {
        _disableInitializers();
    }

    function initialize() public override initializer {
        __Ownable_init();
        futuresUploadBatchId = 1;
        eventUploadBatchId = 1;
        lastOperatorInteraction = block.timestamp;
    }

    // operator ping
    function operatorPing() public onlyOperator {
        _innerPing();
    }

    // futuresTradeUpload
    function futuresTradeUpload(PerpTypes.FuturesTradeUploadData calldata data) public override onlyOperator {
        if (data.batchId != futuresUploadBatchId) revert BatchIdNotMatch(data.batchId, futuresUploadBatchId);
        _innerPing();
        _futuresTradeUploadData(data);
        // emit event
        emit FuturesTradeUpload(data.batchId, block.timestamp);
        // next wanted futuresUploadBatchId
        futuresUploadBatchId += 1;
    }

    // eventUpload
    function eventUpload(EventTypes.EventUpload calldata data) public override onlyOperator {
        if (data.batchId != eventUploadBatchId) revert BatchIdNotMatch(data.batchId, eventUploadBatchId);
        _innerPing();
        _eventUploadData(data);
        // emit event
        emit EventUpload(eventUploadBatchId, block.timestamp);
        // next wanted eventUploadBatchId
        eventUploadBatchId += 1;
    }

    // PerpMarketInfo
    function PerpMarketInfo(MarketTypes.PerpMarketUpload calldata data) public override onlyOperator {
        _innerPing();
        _perpMarketInfo(data);
    }

    // futures trade upload data
    function _futuresTradeUploadData(PerpTypes.FuturesTradeUploadData calldata data) internal {
        PerpTypes.FuturesTradeUpload[] calldata trades = data.trades;
        if (trades.length != data.count) revert CountNotMatch(trades.length, data.count);

        // check cefi signature
        bool succ = Signature.perpUploadEncodeHashVerify(data, cefiSignatureAddress);
        if (!succ) revert SignatureNotMatch();

        _validatePerp(trades);
        // process each validated perp trades
        for (uint256 i = 0; i < data.count; i++) {
            _processValidatedFutures(trades[i]);
        }
    }

    // validate futres trade upload data
    function _validatePerp(PerpTypes.FuturesTradeUpload[] calldata trades) internal pure {
        for (uint256 i = 0; i < trades.length; i++) {
            // check symbol (and maybe other value) is valid
            // TODO
        }
    }

    // process each validated perp trades
    function _processValidatedFutures(PerpTypes.FuturesTradeUpload calldata trade) internal {
        ledger.executeProcessValidatedFutures(trade);
    }

    // event upload data
    function _eventUploadData(EventTypes.EventUpload calldata data) internal {
        EventTypes.EventUploadData[] calldata events = data.events; // gas saving
        if (events.length != data.count) revert CountNotMatch(events.length, data.count);

        // check cefi signature
        bool succ = Signature.eventsUploadEncodeHashVerify(data, cefiSignatureAddress);
        if (!succ) revert SignatureNotMatch();

        // process each event upload
        for (uint256 i = 0; i < data.count; i++) {
            _processEventUpload(events[i]);
        }
    }

    // process each event upload
    function _processEventUpload(EventTypes.EventUploadData calldata data) internal {
        uint8 bizType = data.bizType;
        if (bizType == 1) {
            // withdraw
            ledger.executeWithdrawAction(abi.decode(data.data, (EventTypes.WithdrawData)), data.eventId);
        } else if (bizType == 2) {
            // settlement
            ledger.executeSettlement(abi.decode(data.data, (EventTypes.Settlement)), data.eventId);
        } else if (bizType == 3) {
            // adl
            ledger.executeAdl(abi.decode(data.data, (EventTypes.Adl)), data.eventId);
        } else if (bizType == 4) {
            // liquidation
            ledger.executeLiquidation(abi.decode(data.data, (EventTypes.Liquidation)), data.eventId);
        } else {
            revert InvalidBizType(bizType);
        }
    }

    // perp market info
    function _perpMarketInfo(MarketTypes.PerpMarketUpload calldata data) internal {
        // process perp market info
        ledger.executePerpMarketInfo(data);
    }

    function _innerPing() internal {
        lastOperatorInteraction = block.timestamp;
    }

    function checkCefiDown() public view override returns (bool) {
        return (lastOperatorInteraction + 3 days < block.timestamp);
    }
}

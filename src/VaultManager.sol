// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.18;

import "./interface/IVaultManager.sol";
import "./LedgerComponent.sol";
import "openzeppelin-contracts/contracts/utils/structs/EnumerableSet.sol";

/**
 * VaultManager is responsible for saving vaults' balance, to ensure the cross-chain tx should success
 */
contract VaultManager is IVaultManager, LedgerComponent {
    using EnumerableSet for EnumerableSet.Bytes32Set;

    // crossChainManagerAddress contract address
    address public crossChainManagerAddress;
    // valut balance, used for check if withdraw is valid
    mapping(bytes32 => mapping(uint256 => uint128)) private tokenBalanceOnchain;
    mapping(bytes32 => mapping(uint256 => bool)) private allowedChainToken; // supported token on each chain
    mapping(bytes32 => bool) private _deprecatedA; // @Rubick depracated
    mapping(bytes32 => bool) private _deprecatedB; // @Rubick depracated
    EnumerableSet.Bytes32Set private allowedTokenSet; // supported token
    EnumerableSet.Bytes32Set private allowedBrokerSet; // supported broker
    EnumerableSet.Bytes32Set private allowedSymbolSet; // supported symbol
    mapping(bytes32 => mapping(uint256 => uint128)) private tokenFrozenBalanceOnchain; // @Rubick reorder

    mapping(bytes32 => uint128) private maxWithdrawFee; // default = unlimited

    constructor() {
        _disableInitializers();
    }

    function initialize() public override initializer {
        __Ownable_init();
    }

    // frozen & finish frozen
    function frozenBalance(bytes32 _tokenHash, uint256 _chainId, uint128 _deltaBalance) external override onlyLedger {
        tokenBalanceOnchain[_tokenHash][_chainId] -= _deltaBalance;
        tokenFrozenBalanceOnchain[_tokenHash][_chainId] += _deltaBalance;
    }

    function finishFrozenBalance(bytes32 _tokenHash, uint256 _chainId, uint128 _deltaBalance)
        external
        override
        onlyLedger
    {
        tokenFrozenBalanceOnchain[_tokenHash][_chainId] -= _deltaBalance;
    }

    // get balance
    function getBalance(bytes32 _tokenHash, uint256 _chainId) public view override returns (uint128) {
        return tokenBalanceOnchain[_tokenHash][_chainId];
    }

    // add balance
    function addBalance(bytes32 _tokenHash, uint256 _chainId, uint128 _deltaBalance) external override onlyLedger {
        tokenBalanceOnchain[_tokenHash][_chainId] += _deltaBalance;
    }

    // sub balance
    function subBalance(bytes32 _tokenHash, uint256 _chainId, uint128 _deltaBalance) external override onlyLedger {
        tokenBalanceOnchain[_tokenHash][_chainId] -= _deltaBalance;
    }

    // get frozen balance
    function getFrozenBalance(bytes32 _tokenHash, uint256 _chainId) public view override returns (uint128) {
        return tokenFrozenBalanceOnchain[_tokenHash][_chainId];
    }

    function setAllowedBroker(bytes32 _brokerHash, bool _allowed) public override onlyOwner {
        if (_allowed) {
            allowedBrokerSet.add(_brokerHash);
        } else {
            allowedBrokerSet.remove(_brokerHash);
        }
    }

    function getAllowedBroker(bytes32 _brokerHash) public view override returns (bool) {
        return allowedBrokerSet.contains(_brokerHash);
    }

    function setAllowedChainToken(bytes32 _tokenHash, uint256 _chainId, bool _allowed) public override onlyOwner {
        allowedChainToken[_tokenHash][_chainId] = _allowed;
    }

    function getAllowedChainToken(bytes32 _tokenHash, uint256 _chainId) public view override returns (bool) {
        return allowedTokenSet.contains(_tokenHash) && allowedChainToken[_tokenHash][_chainId];
    }

    function setAllowedSymbol(bytes32 _symbolHash, bool _allowed) public override onlyOwner {
        if (_allowed) {
            allowedSymbolSet.add(_symbolHash);
        } else {
            allowedSymbolSet.remove(_symbolHash);
        }
    }

    function getAllowedSymbol(bytes32 _symbolHash) public view override returns (bool) {
        return allowedSymbolSet.contains(_symbolHash);
    }

    // get all allowed tokenHash
    function getAllAllowedToken() public view override returns (bytes32[] memory) {
        return allowedTokenSet.values();
    }

    // get all allowed brokerIds
    function getAllAllowedBroker() public view override returns (bytes32[] memory) {
        return allowedBrokerSet.values();
    }

    // get all allowed symbolHash
    function getAllAllowedSymbol() public view override returns (bytes32[] memory) {
        return allowedSymbolSet.values();
    }

    function setAllowedToken(bytes32 _tokenHash, bool _allowed) public override onlyOwner {
        if (_allowed) {
            allowedTokenSet.add(_tokenHash);
        } else {
            allowedTokenSet.remove(_tokenHash);
        }
    }

    function getAllowedToken(bytes32 _tokenHash) public view override returns (bool) {
        return allowedTokenSet.contains(_tokenHash);
    }

    // maxWithdrawFee
    function setMaxWithdrawFee(bytes32 _tokenHash, uint128 _maxWithdrawFee) public override onlyOwner {
        maxWithdrawFee[_tokenHash] = _maxWithdrawFee;
    }

    function getMaxWithdrawFee(bytes32 _tokenHash) public view override returns (uint128) {
        return maxWithdrawFee[_tokenHash];
    }

    // every time call `upgradeAndCall` will call this function, to do some data migrate or value init
    function upgradeInit() external {}
}

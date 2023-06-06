// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.18;

import "./interface/IVault.sol";
import "./library/Utils.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

/**
 * Vault is responsible for saving user's USDC (where USDC which is a IERC20 token).
 * EACH CHAIN SHOULD HAVE ONE Vault CONTRACT.
 * User can deposit USDC from Vault.
 * Only crossChainManager can approve withdraw request.
 */
contract Vault is IVault, ReentrancyGuard, Ownable {
    // equal to `Utils.string2HashedBytes32('USDC')`
    bytes32 constant USDC = bytes32(uint256(0x61fc29e9a6b4b52b423e75ca44734454f94ea60ddff3dc47af01a2a646fe9572));
    // cross-chain operator address
    address public crossChainManager;
    // symbol to token address mapping
    mapping(bytes32 => IERC20) public symbol2TokenAddress;
    // deposit id / nonce
    uint256 public depositId;

    // only cross-chain manager can call
    modifier onlyCrossChainManager() {
        require(msg.sender == crossChainManager, "only crossChainManager can call");
        _;
    }

    // change crossChainManager
    function setCrossChainManager(address _crossChainManager) public onlyOwner {
        crossChainManager = _crossChainManager;
    }

    // add token address
    function addTokenAddress(bytes32 _symbol, address _tokenAddress) public onlyOwner {
        symbol2TokenAddress[_symbol] = IERC20(_tokenAddress);
    }

    // call `setCrossChainManager` later
    constructor(address _usdcAddress) {
        symbol2TokenAddress[USDC] = IERC20(_usdcAddress);
    }

    // user deposit USDC
    function deposit(VaultTypes.VaultDeposit calldata data) public override {
        // bytes32 tokenSymbol = Utils.string2HashedBytes32(data.tokenSymbol);
        // bytes32 brokerId = Utils.string2HashedBytes32(data.brokerId);
        IERC20 tokenAddress = symbol2TokenAddress[data.tokenSymbol];
        require(tokenAddress.transferFrom(msg.sender, address(this), data.tokenAmount), "transferFrom failed");
        // emit deposit event
        emit AccountDeposit(data.accountId, msg.sender, _newDepositId(), data.tokenSymbol, data.tokenAmount);
        // TODO @Rubick add whitelist to avoid malicious user
        // TODO @Lewis send cross-chain tx to ledger
    }

    // user withdraw USDC
    function withdraw(VaultTypes.VaultWithdraw calldata data) public override onlyCrossChainManager nonReentrant {
        IERC20 tokenAddress = symbol2TokenAddress[data.tokenSymbol];
        // check balane gt amount
        require(tokenAddress.balanceOf(address(this)) >= data.tokenAmount, "balance not enough");
        // transfer to user
        require(tokenAddress.transfer(data.userAddress, data.tokenAmount), "transfer failed");
        // emit withdraw event
        emit AccountWithdraw(data.accountId, data.userAddress, data.withdrawNonce, data.tokenSymbol, data.tokenAmount);
    }

    function _newDepositId() internal returns (uint256) {
        depositId += 1;
        return depositId;
    }
}

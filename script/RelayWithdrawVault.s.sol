// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.18;

import "forge-std/Script.sol";
import "../lib/crosschain/contracts/CrossChainRelay.sol";
import "../src/VaultCrossChainManager.sol";

contract RelayWithdrawVault is Script{
    function run() external {
        uint256 orderlyPrivateKey = vm.envUint("ORDERLY_PRIVATE_KEY");
        uint256 fujiPrivateKey = vm.envUint("FUJI_PRIVATE_KEY");
        address ledgerRelay = vm.envAddress("LEDGER_RELAY_ADDRESS");
        address vaultRelay = vm.envAddress("VAULT_RELAY_ADDRESS");
        address ledgerCrossChainManager = vm.envAddress("LEDGER_CROSS_CHAIN_MANAGER_ADDRESS");
        address vaultCrossChainManager = vm.envAddress("VAULT_CROSS_CHAIN_MANAGER_ADDRESS");
        uint256 vaultSideChainId = 43113;
        uint256 ledgerSideChainId = 986532;
        uint16 vaultLzChainId = 10106;
        uint16 ledgerLzChainId = 10174;
        // 100 native token
        uint256 ledgerTransferAmount = 100_000_000_000_000_000_000;
        // 2 native token
        uint256 vaultTransferAmount = 1_000_000_000_000_000_000;

        vm.startBroadcast(fujiPrivateKey);

        address signerAddress = vm.addr(fujiPrivateKey);

        CrossChainRelay relay = CrossChainRelay(payable(vaultRelay));

        relay.withdrawNativeToken(payable(signerAddress), vaultTransferAmount);

        vm.stopBroadcast();
    }
}
